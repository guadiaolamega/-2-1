/*
 * Coverage-Guided Event Generation Strategy
 *
 * Improvement over HapTest's Greedy DFS:
 * - Uses CoverageReport data to guide event selection
 * - Maps Component.debugLine to CoverageReport files
 * - Prioritizes UI components whose source code is uncovered
 * - Falls back to Greedy DFS behavior when coverage unavailable
 *
 * Copyright (c) 2024 Huawei Device Co., Ltd. (base framework)
 * Modified for coverage-guided EGM improvement.
 */

import { Hap } from '../model/hap';
import { MAX_NUM_RESTARTS, PTGPolicy } from './ptg_policy';
import { Device } from '../device/device';
import { Event } from '../event/event';
import { InputTextEvent } from '../event/ui_event';
import { ExitEvent } from '../event/system_event';
import { BACK_KEY_EVENT } from '../event/key_event';
import { RandomUtils } from '../utils/random_utils';
import { Component, ComponentType } from '../model/component';
import { EventBuilder } from '../event/event_builder';
import { Page } from '../model/page';
import { Rank } from '../model/rank';
import { PolicyName } from './policy';
import { getLogger } from 'log4js';

const logger = getLogger();

/**
 * Coverage-Guided Event Generation Strategy (CovGuided).
 *
 * This policy extends PTGPolicy and improves upon Greedy DFS by incorporating
 * real-time code coverage feedback into the event selection process.
 *
 * Key Innovation:
 *   Component.debugLine (source location) <-> CoverageReport.files (coverage data)
 *
 * Algorithm:
 *   1. After each event, collect CoverageReport from the page's snapshot
 *   2. Build a set of covered/uncovered source file:function pairs
 *   3. When ranking UI components, assign higher scores to components
 *      whose debugLine maps to uncovered source code
 *   4. Select unexplored events from highest-scored components first
 *   5. If no coverage data available, fall back to Greedy DFS ranking
 */
export class PtgCovGuidedPolicy extends PTGPolicy {
    private pageComponentMap: Map<string, Component[]>;
    private isNewPage: boolean;
    private inputComponents: string[] = [];

    // === Coverage tracking state ===
    /** Last seen CoverageReport (any-typed for flexible field access) */
    private lastCoverage?: any;
    /** Set of "relPath:funcName" strings for covered functions */
    private coveredFuncs: Set<string>;
    /** Set of "relPath:funcName" strings for uncovered functions */
    private uncoveredFuncs: Set<string>;
    /** Map from relative file path -> uncovered function count */
    private fileUncoveredCount: Map<string, number>;
    /** Map from relative file path -> total function count */
    private fileTotalCount: Map<string, number>;
    /** Cumulative coverage delta (percentage points gained) */
    private totalCovDelta: number;
    /** Number of events that produced coverage improvement */
    private covEffectiveEvents: number;
    /** Total events generated */
    private totalEvents: number;

    constructor(device: Device, hap: Hap, name: PolicyName) {
        super(device, hap, name, true);
        this.retryCount = 0;
        this.isNewPage = false;
        this.pageComponentMap = new Map();
        this.inputComponents = [];

        this.coveredFuncs = new Set();
        this.uncoveredFuncs = new Set();
        this.fileUncoveredCount = new Map();
        this.fileTotalCount = new Map();
        this.totalCovDelta = 0;
        this.covEffectiveEvents = 0;
        this.totalEvents = 0;
    }

    /**
     * Main entry point: generate the next event based on PTG + coverage.
     */
    generateEventBasedOnPtg(): Event {
        this.totalEvents++;
        this.updateCoverageTracking();
        this.updateState();

        let possibleEvent = this.getCoverageGuidedEvent();

        if (possibleEvent === undefined) {
            if (this.retryCount > MAX_NUM_RESTARTS) {
                this.stop();
                logger.info(
                    `CovGuided finished. Events: ${this.totalEvents}, ` +
                    `CovDelta: ${this.totalCovDelta.toFixed(1)}%, ` +
                    `CovEffective: ${this.covEffectiveEvents}`
                );
                return new ExitEvent();
            }
            this.retryCount++;
            return EventBuilder.createRandomTouchEvent(this.device);
        }
        this.retryCount = 0;
        return possibleEvent;
    }

    // ===================== Coverage Tracking =====================

    /**
     * Update coverage tracking state from the current page's snapshot.
     * Builds coveredFuncs / uncoveredFuncs sets from CoverageReport.
     */
    private updateCoverageTracking(): void {
        let snapshot = this.currentPage?.getSnapshot();
        let coverage: any = snapshot?.coverage;
        if (!coverage) return;

        // Track coverage delta
        let currentPct = coverage.summary?.functions?.pct ?? 0;
        let lastPct = this.lastCoverage?.summary?.functions?.pct ?? 0;
        if (currentPct > lastPct) {
            let delta = currentPct - lastPct;
            this.totalCovDelta += delta;
            this.covEffectiveEvents++;
            logger.debug(
                `Coverage improved: ${lastPct.toFixed(1)}% -> ${currentPct.toFixed(1)}% ` +
                `(+${delta.toFixed(1)}%), total delta: ${this.totalCovDelta.toFixed(1)}%`
            );
        }
        this.lastCoverage = coverage;

        // Rebuild function coverage sets
        this.coveredFuncs.clear();
        this.uncoveredFuncs.clear();
        this.fileUncoveredCount.clear();
        this.fileTotalCount.clear();

        let files = coverage.files || [];
        for (let file of files) {
            let filePath: string = file.path || '';
            let relPath = this.extractRelPath(filePath);

            let uncovered = 0;
            let total = 0;
            for (let fn of (file.functions || [])) {
                total++;
                let key = `${relPath}:${fn.name}`;
                if (fn.count > 0) {
                    this.coveredFuncs.add(key);
                } else {
                    this.uncoveredFuncs.add(key);
                    uncovered++;
                }
            }
            this.fileUncoveredCount.set(relPath, uncovered);
            this.fileTotalCount.set(relPath, total);
        }

        logger.debug(
            `Coverage: ${this.coveredFuncs.size} covered, ${this.uncoveredFuncs.size} uncovered functions, ` +
            `files: ${this.fileTotalCount.size}`
        );
    }

    /**
     * Extract a relative path from an absolute path.
     * e.g. "/private/tmp/huawei_fresh/entry/src/main/ets/pages/Index.ets"
     *   -> "entry/src/main/ets/pages/Index.ets"
     */
    private extractRelPath(absPath: string): string {
        const markers = ['entry/src/main/', 'entry/src/', 'src/main/'];
        for (let marker of markers) {
            let idx = absPath.indexOf(marker);
            if (idx >= 0) {
                return absPath.substring(idx);
            }
        }
        // Fallback: use the last 3 path segments
        let parts = absPath.split('/');
        return parts.slice(-3).join('/');
    }

    // ===================== Event Selection =====================

    /**
     * Select the next event using coverage-guided component ranking.
     */
    private getCoverageGuidedEvent(): Event | undefined {
        let components: Component[] = this.currentPage!.getComponents();

        // Always re-rank components with latest coverage info
        // (do NOT cache ranking, since coverage changes after each event)
        components = this.getCoverageRankedComponents(components);

        let events: Event[] = EventBuilder.createPossibleUIEvents(components);
        if (events.length === 0) {
            return undefined;
        }

        // Shuffle for randomness among equally-scored components
        if (this.randomInput) {
            RandomUtils.shuffle(events);
        }

        // DFS behavior: append BACK_KEY_EVENT for new pages
        if (this.isNewPage) {
            events.push(BACK_KEY_EVENT);
        }

        // Find first unexplored event
        for (const event of events) {
            // Skip already-input components
            if (event instanceof InputTextEvent && event.getComponentId() !== undefined) {
                const componentId = event.getComponentId();
                if (componentId !== undefined && this.inputComponents.includes(componentId)) {
                    continue;
                }
                if (componentId !== undefined) {
                    this.inputComponents.push(componentId);
                }
            }

            if (!this.ptg.isEventExplored(event, this.currentPage!)) {
                // Log coverage-guided selection
                if (event instanceof InputTextEvent || event.constructor.name === 'TouchEvent') {
                    let comp = (event as any).getComponet?.() as Component | undefined;
                    if (comp?.debugLine) {
                        let score = this.getComponentCoverageScore(comp);
                        if (score >= 8) {
                            logger.debug(
                                `Selecting high-priority component (score=${score}): ` +
                                `debugLine=${comp.debugLine}, type=${comp.type}`
                            );
                        }
                    }
                }
                return event;
            }
        }

        return undefined;
    }

    // ===================== Coverage-Guided Ranking =====================

    /**
     * Rank components by coverage priority, then by interaction ability.
     *
     * Coverage scoring:
     *   10 = Component's file has uncovered functions (high priority)
     *    8 = Component's file has some uncovered functions
     *    5 = Component's file not in coverage report (unknown)
     *    3 = Component's file functions all covered
     *    1 = No debugLine available
     *
     * Interaction scoring (same as Greedy DFS):
     *   checkable/clickable/longClickable/scrollable = 2 each
     *   inputable = 1
     */
    private getCoverageRankedComponents(components: Component[]): Component[] {
        const filtered = components.filter((c) => c.enabled);

        const scored = filtered.map((c) => ({
            component: c,
            covScore: this.getComponentCoverageScore(c),
            intScore: this.getInteractionScore(c),
        }));

        // Sort: coverage score (desc) → interaction score (desc)
        scored.sort((a, b) => {
            if (b.covScore !== a.covScore) return b.covScore - a.covScore;
            return b.intScore - a.intScore;
        });

        return scored
            .filter((s) => s.component.hasUIEvent())
            .map((s) => s.component);
    }

    /**
     * Score a component based on whether its source code is covered.
     * Uses Component.debugLine -> CoverageReport.files mapping.
     */
    private getComponentCoverageScore(component: Component): number {
        if (!component.debugLine) return 1;

        // Parse debugLine: "file/path.ets:line:column"
        let parts = component.debugLine.split(':');
        if (parts.length < 2) return 1;

        let filePath = parts[0];
        let relPath = this.extractRelPath(filePath);

        // Check coverage status of this file
        let total = this.fileTotalCount.get(relPath) || 0;
        let uncovered = this.fileUncoveredCount.get(relPath) || 0;

        if (total === 0) return 5;  // File not in coverage report

        if (uncovered === 0) return 3;  // All functions covered

        // File has uncovered functions
        let uncoveredRatio = uncovered / total;
        if (uncoveredRatio > 0.5) return 10;  // Most functions uncovered
        return 8;                               // Some functions uncovered
    }

    /**
     * Score a component by its interaction capabilities.
     * Same scoring as Greedy DFS getRankedComponent().
     */
    private getInteractionScore(component: Component): number {
        let score = 0;
        if (component.checkable) score += 2;
        if (component.clickable) score += 2;
        if (component.longClickable) score += 2;
        if (component.scrollable) score += 2;
        if (component.inputable) score += 1;
        return score;
    }

    // ===================== State Management =====================

    private updateState(): void {
        if (!this.currentPage!.isForeground()) {
            return;
        }

        let pageSig = this.currentPage!.getContentSig();
        if (!this.pageComponentMap.has(pageSig)) {
            this.isNewPage = true;
            let components: Component[] = [];
            this.updatePreferableComponentRank(this.currentPage!);
            for (const component of this.currentPage!.getComponents()) {
                if (component.hasUIEvent()) {
                    components.push(component);
                }
            }
            this.pageComponentMap.set(pageSig, components);
        }
    }

    private updatePreferableComponentRank(page: Page): void {
        for (const component of page.selectComponentsByType([ComponentType.Dialog])) {
            Page.collectComponent(component, (item) => {
                if (item.hasUIEvent()) {
                    item.rank = Rank.HIGH;
                }
                return item.hasUIEvent();
            });
        }
    }
}
