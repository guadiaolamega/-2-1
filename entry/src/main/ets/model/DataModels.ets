/**
 * 任务数据模型
 */

export interface TaskItem {
  id: number
  title: string
  description: string
  priority: 'high' | 'medium' | 'low'
  status: 'todo' | 'doing' | 'done'
  createdAt: string
}

export interface NoteItem {
  id: number
  content: string
  timestamp: string
  color: string
}

export function createDefaultTasks(): TaskItem[] {
  return [
    { id: 1, title: '完成项目报告', description: '撰写软件学报格式论文', priority: 'high', status: 'todo', createdAt: '2026-06-25' },
    { id: 2, title: '环境搭建', description: '配置 DevEco Studio 和 HapTest', priority: 'medium', status: 'done', createdAt: '2026-06-26' },
    { id: 3, title: '设计改进方案', description: '覆盖率驱动事件生成策略', priority: 'high', status: 'doing', createdAt: '2026-06-27' },
    { id: 4, title: '复现基准实验', description: '用 random 和 greedy 策略各跑一遍', priority: 'medium', status: 'todo', createdAt: '2026-06-28' },
    { id: 5, title: '阅读文献', description: 'AFL、ACTEve、Stoat 等覆盖率引导论文', priority: 'low', status: 'todo', createdAt: '2026-06-29' },
  ]
}
