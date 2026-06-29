/**
 * PageSettings - 设置页面
 * 包含开关、滑块、下拉选择、复选框等交互组件
 */

import { router } from '@kit.ArkUI';

interface LangOption {
  value: string
  icon: string
}

@Entry
@Component
struct PageSettings {
  @State isDarkMode: boolean = false
  @State fontSize: number = 16
  @State volume: number = 50
  @State selectedLanguage: number = 0
  @State notificationsEnabled: boolean = true
  @State autoUpdate: boolean = false
  @State showAdvanced: boolean = false
  @State selectedTheme: string = '默认'
  @State cacheSize: string = '0 MB'
  @State clearCacheProgress: number = 0

  languages: string[] = ['中文', '英文', '日文', '韩文']

  private getLangOptions(): Array<LangOption> {
    let options: Array<LangOption> = []
    for (let i = 0; i < this.languages.length; i++) {
      let opt: LangOption = { value: this.languages[i], icon: '' }
      options.push(opt)
    }
    return options
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('← 返回首页')
          .onClick(() => { router.back() })
          .fontSize(14)
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#FFD700')

      Scroll() {
        Column() {
          // 外观设置组
          Text('外观设置')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 10 })

          // 深色模式
          Row() {
            Text('深色模式')
              .fontSize(16)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
              .onChange((isOn: boolean) => { this.isDarkMode = isOn })
          }
          .width('90%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ bottom: 10 })

          // 字体大小滑块
          Row() {
            Text('字体大小: ' + this.fontSize)
              .fontSize(16)
              .layoutWeight(1)
          }
          .width('90%')
          .margin({ bottom: 5 })

          Slider({
            value: this.fontSize,
            min: 12,
            max: 30,
            step: 2,
            style: SliderStyle.OutSet
          })
            .width('90%')
            .onChange((value: number) => { this.fontSize = value })
            .margin({ bottom: 15 })

          // 主题选择
          Row() {
            Text('主题: ' + this.selectedTheme)
              .fontSize(16)
              .layoutWeight(1)

            Button('默认')
              .height(35)
              .fontSize(12)
              .onClick(() => { this.selectedTheme = '默认' })
              .margin({ right: 5 })

            Button('蓝色')
              .height(35)
              .fontSize(12)
              .onClick(() => { this.selectedTheme = '蓝色' })
              .margin({ right: 5 })

            Button('绿色')
              .height(35)
              .fontSize(12)
              .onClick(() => { this.selectedTheme = '绿色' })
          }
          .width('90%')
          .padding({ left: 15, right: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ bottom: 20 })

          // 功能设置组
          Text('功能设置')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })

          // 通知开关
          Row() {
            Text('推送通知')
              .fontSize(16)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.notificationsEnabled })
              .onChange((isOn: boolean) => { this.notificationsEnabled = isOn })
          }
          .width('90%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ bottom: 10 })

          // 自动更新
          Row() {
            Text('自动更新')
              .fontSize(16)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.autoUpdate })
              .onChange((isOn: boolean) => { this.autoUpdate = isOn })
          }
          .width('90%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ bottom: 10 })

          // 音量滑块
          Row() {
            Text('音量: ' + this.volume + '%')
              .fontSize(16)
              .layoutWeight(1)
          }
          .width('90%')
          .margin({ bottom: 5 })

          Slider({
            value: this.volume,
            min: 0,
            max: 100,
            step: 5,
            style: SliderStyle.InSet
          })
            .width('90%')
            .onChange((value: number) => { this.volume = value })
            .margin({ bottom: 15 })

          // 语言选择
          Row() {
            Text('语言')
              .fontSize(16)
              .layoutWeight(1)
            Select(this.getLangOptions())
              .selected(this.selectedLanguage)
              .value(this.languages[this.selectedLanguage])
              .onSelect((index: number) => { this.selectedLanguage = index })
          }
          .width('90%')
          .height(50)
          .padding({ left: 15, right: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ bottom: 20 })

          // 高级设置（折叠）
          Button('展开高级设置 ▼')
            .width('90%')
            .height(45)
            .backgroundColor('#E0E0E0')
            .onClick(() => { this.showAdvanced = !this.showAdvanced })
            .margin({ bottom: 10 })

          if (this.showAdvanced) {
            Column() {
              Text('高级设置')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })

              Row() {
                Text('缓存大小: ' + this.cacheSize)
                  .fontSize(16)
                  .layoutWeight(1)
                Button('清除缓存')
                  .height(35)
                  .backgroundColor('#FF6600')
                  .onClick(() => {
                    this.clearCacheProgress = 0
                    // 模拟清除进度
                    for (let i = 0; i < 100; i += 20) {
                      this.clearCacheProgress = i
                    }
                    this.cacheSize = '0 MB'
                    this.clearCacheProgress = 100
                  })
              }
              .width('100%')
              .margin({ bottom: 10 })

              Progress({ value: this.clearCacheProgress, total: 100, type: ProgressType.Linear })
                .width('100%')
                .color('#4CAF50')
                .margin({ bottom: 15 })

              Text('开发者模式')
                .fontSize(16)
                .margin({ bottom: 5 })

              Text('版本信息: v1.0.0-beta')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ bottom: 10 })
            }
            .width('90%')
            .padding(15)
            .backgroundColor('#FFF8E1')
            .borderRadius(10)
            .margin({ bottom: 20 })
          }
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#333333' : '#FFFFFF')
  }
}
