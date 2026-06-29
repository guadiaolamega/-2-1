/**
 * PageProfile - 个人资料页
 * 包含头像编辑、信息修改、偏好设置
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct PageProfile {
  @State userName: string = '测试用户'
  @State userEmail: string = 'test@example.com'
  @State userBio: string = 'OpenHarmony 开发者，正在进行 HapTest 动态分析实验'
  @State selectedAvatar: number = 0
  @State isEditingProfile: boolean = false
  @State editName: string = ''
  @State editEmail: string = ''
  @State editBio: string = ''
  @State themePreference: string = 'light'
  @State languagePreference: string = 'zh'
  @State taskCount: number = 5
  @State noteCount: number = 3
  @State completedCount: number = 1

  avatarColors: string[] = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD']

  build() {
    Column() {
      Row() {
        Button('← 返回主页')
          .onClick(() => { router.back() })
          .fontSize(14)
        Text('个人资料')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#9C27B0')

      Scroll() {
        Column() {
          // 头像选择
          Row() {
            ForEach(this.avatarColors, (color: string, index?: number) => {
              Text(this.userName.substring(0, 1))
                .width(45)
                .height(45)
                .borderRadius(22)
                .backgroundColor(color)
                .textAlign(TextAlign.Center)
                .fontSize(20)
                .fontColor('#FFFFFF')
                .margin({ right: 8 })
                .border(this.selectedAvatar === (index ?? 0) ? { width: 3, color: '#000000', style: BorderStyle.Solid } : { width: 0 })
                .onClick(() => { if (index !== undefined) this.selectedAvatar = index })
            }, (color: string, index?: number) => color + (index ?? 0))
          }
          .margin({ top: 20, bottom: 15 })

          // 基本信息
          Column() {
            Text(this.userName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5 })
            Text(this.userEmail)
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 5 })
            Text(this.userBio)
              .fontSize(14)
              .fontColor('#999999')
              .maxLines(3)
          }
          .margin({ bottom: 20 })

          // 统计卡片
          Row() {
            Column() {
              Text('任务')
                .fontSize(14)
              Text(this.taskCount.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .height(60)
            .backgroundColor('#E3F2FD')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)

            Column() {
              Text('笔记')
                .fontSize(14)
              Text(this.noteCount.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .height(60)
            .backgroundColor('#FFF3E0')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
            .margin({ left: 10 })

            Column() {
              Text('完成')
                .fontSize(14)
              Text(this.completedCount.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
            }
            .layoutWeight(1)
            .height(60)
            .backgroundColor('#E8F5E9')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
            .margin({ left: 10 })
          }
          .margin({ bottom: 20 })

          // 编辑按钮
          Button('编辑资料')
            .width('90%')
            .height(45)
            .backgroundColor('#9C27B0')
            .onClick(() => {
              this.editName = this.userName
              this.editEmail = this.userEmail
              this.editBio = this.userBio
              this.isEditingProfile = true
            })
            .margin({ bottom: 15 })

          // 编辑区域
          if (this.isEditingProfile) {
            Column() {
              TextInput({ placeholder: '姓名', text: this.editName })
                .width('100%')
                .height(45)
                .onChange((value: string) => { this.editName = value })
                .margin({ bottom: 10 })

              TextInput({ placeholder: '邮箱', text: this.editEmail })
                .width('100%')
                .height(45)
                .onChange((value: string) => { this.editEmail = value })
                .margin({ bottom: 10 })

              TextArea({ placeholder: '简介', text: this.editBio })
                .width('100%')
                .height(80)
                .onChange((value: string) => { this.editBio = value })
                .margin({ bottom: 10 })

              Row() {
                Button('保存')
                  .backgroundColor('#4CAF50')
                  .onClick(() => {
                    this.userName = this.editName
                    this.userEmail = this.editEmail
                    this.userBio = this.editBio
                    this.isEditingProfile = false
                  })
                  .margin({ right: 15 })
                Button('取消')
                  .backgroundColor('#FF6600')
                  .onClick(() => { this.isEditingProfile = false })
              }
            }
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ bottom: 20 })
          }

          // 偏好设置
          Text('偏好设置')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })

          Row() {
            Text('主题模式')
              .fontSize(16)
              .layoutWeight(1)
            Button('浅色')
              .height(35)
              .fontSize(12)
              .backgroundColor(this.themePreference === 'light' ? '#9C27B0' : '#E0E0E0')
              .onClick(() => { this.themePreference = 'light' })
              .margin({ right: 5 })
            Button('深色')
              .height(35)
              .fontSize(12)
              .backgroundColor(this.themePreference === 'dark' ? '#9C27B0' : '#E0E0E0')
              .onClick(() => { this.themePreference = 'dark' })
          }
          .margin({ bottom: 10 })

          Row() {
            Text('语言偏好')
              .fontSize(16)
              .layoutWeight(1)
            Button('中文')
              .height(35)
              .fontSize(12)
              .backgroundColor(this.languagePreference === 'zh' ? '#9C27B0' : '#E0E0E0')
              .onClick(() => { this.languagePreference = 'zh' })
              .margin({ right: 5 })
            Button('英文')
              .height(35)
              .fontSize(12)
              .backgroundColor(this.languagePreference === 'en' ? '#9C27B0' : '#E0E0E0')
              .onClick(() => { this.languagePreference = 'en' })
          }
          .margin({ bottom: 20 })
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themePreference === 'dark' ? '#333333' : '#FFFFFF')
  }
}
