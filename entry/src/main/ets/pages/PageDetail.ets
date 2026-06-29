/**
 * PageDetail - 联系人详情页
 * 从 PageSecond 传入参数，展示详情 + 编辑 + 删除
 */

import { router } from '@kit.ArkUI';

interface DetailParams {
  name: string
  phone: string
  color: string
}

@Entry
@Component
struct PageDetail {
  @State contactName: string = ''
  @State contactPhone: string = ''
  @State contactColor: string = '#FF6B6B'
  @State isEditing: boolean = false
  @State editName: string = ''
  @State editPhone: string = ''
  @State callCount: number = 0
  @State messageCount: number = 0

  private getCallRecordList(): number[] {
    let result: number[] = []
    let count: number = Math.min(this.callCount, 5)
    for (let i = 1; i <= count; i++) {
      result.push(i)
    }
    return result
  }

  aboutToAppear(): void {
    const params = router.getParams() as DetailParams
    if (params) {
      this.contactName = params.name
      this.contactPhone = params.phone
      this.contactColor = params.color
      this.editName = params.name
      this.editPhone = params.phone
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('← 返回列表')
          .onClick(() => { router.back() })
          .fontSize(14)
        Text('联系人详情')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#FFD700')

      // 头像区
      Column() {
        Text(this.contactName.substring(0, 1))
          .width(80)
          .height(80)
          .borderRadius(40)
          .backgroundColor(this.contactColor)
          .textAlign(TextAlign.Center)
          .fontSize(36)
          .fontColor('#FFFFFF')
          .margin({ top: 30, bottom: 10 })

        Text(this.contactName)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 5 })

        Text(this.contactPhone)
          .fontSize(18)
          .fontColor('#666666')
          .margin({ bottom: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 操作按钮
      Row() {
        Button('拨号')
          .layoutWeight(1)
          .height(45)
          .backgroundColor('#4CAF50')
          .onClick(() => { this.callCount++ })
          .margin({ right: 10 })

        Button('发消息')
          .layoutWeight(1)
          .height(45)
          .backgroundColor('#2196F3')
          .onClick(() => { this.messageCount++ })
          .margin({ right: 10 })

        Button('编辑')
          .layoutWeight(1)
          .height(45)
          .backgroundColor('#FF9800')
          .onClick(() => { this.isEditing = true })
      }
      .width('90%')
      .margin({ top: 20, bottom: 15 })

      // 交互统计
      Text('拨号 ' + this.callCount + ' 次 | 消息 ' + this.messageCount + ' 条')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 20 })

      // 编辑区域
      if (this.isEditing) {
        Column() {
          Text('编辑联系人信息')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          TextInput({ placeholder: '姓名', text: this.editName })
            .width('90%')
            .height(45)
            .onChange((value: string) => { this.editName = value })
            .margin({ bottom: 10 })

          TextInput({ placeholder: '电话号码', text: this.editPhone })
            .width('90%')
            .height(45)
            .onChange((value: string) => { this.editPhone = value })
            .margin({ bottom: 15 })

          Row() {
            Button('保存修改')
              .backgroundColor('#4CAF50')
              .onClick(() => {
                this.contactName = this.editName
                this.contactPhone = this.editPhone
                this.isEditing = false
              })
              .margin({ right: 15 })

            Button('取消')
              .backgroundColor('#FF6600')
              .onClick(() => { this.isEditing = false })
          }
        }
        .width('90%')
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
      }

      // 通话记录（模拟）
      Column() {
        Text('最近通话记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })

        if (this.callCount > 0) {
          ForEach(this.getCallRecordList(), (idx: number) => {
            Row() {
              Text('通话 #' + idx)
                .fontSize(16)
                .layoutWeight(1)
              Text('时长 ' + (idx * 2 + 1) + '分钟')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .height(40)
            .padding({ left: 15, right: 15 })
          }, (idx: number) => idx.toString())
        } else {
          Text('暂无通话记录')
            .fontSize(14)
            .fontColor('#999999')
        }
      }
      .width('90%')
      .margin({ top: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
