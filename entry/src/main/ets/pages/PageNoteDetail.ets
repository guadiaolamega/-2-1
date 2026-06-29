/**
 * PageNoteDetail - 笔记详情页
 */

import { router } from '@kit.ArkUI';

interface NoteParams {
  noteId: number
  noteContent: string
  noteTime: string
  noteColor: string
}

@Entry
@Component
struct PageNoteDetail {
  @State noteContent: string = ''
  @State noteTime: string = ''
  @State noteColor: string = '#FFEAA7'
  @State isEditing: boolean = false
  @State editContent: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as NoteParams
    if (params) {
      this.noteContent = params.noteContent
      this.noteTime = params.noteTime
      this.noteColor = params.noteColor
      this.editContent = params.noteContent
    }
  }

  build() {
    Column() {
      Row() {
        Button('← 返回')
          .onClick(() => { router.back() })
          .fontSize(14)
        Text('笔记详情')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#FF9800')

      Column() {
        // 笔记色块背景
        Column() {
          Text(this.noteContent)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 15 })

          Text('记录时间: ' + this.noteTime)
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.noteColor)
        .borderRadius(10)
        .margin({ top: 20, bottom: 20 })

        // 操作按钮
        Row() {
          Button('编辑笔记')
            .layoutWeight(1)
            .backgroundColor('#FF9800')
            .onClick(() => { this.isEditing = true })
            .margin({ right: 10 })

          Button('分享')
            .layoutWeight(1)
            .backgroundColor('#2196F3')
            .margin({ right: 10 })

          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#FF6600')
            .onClick(() => { router.back() })
        }
        .margin({ bottom: 20 })

        // 编辑区域
        if (this.isEditing) {
          TextArea({ placeholder: '编辑笔记内容', text: this.editContent })
            .width('100%')
            .height(150)
            .onChange((value: string) => { this.editContent = value })
            .margin({ bottom: 10 })

          Row() {
            Button('保存')
              .backgroundColor('#4CAF50')
              .onClick(() => {
                this.noteContent = this.editContent
                this.isEditing = false
              })
              .margin({ right: 15 })
            Button('取消')
              .backgroundColor('#FF6600')
              .onClick(() => { this.isEditing = false })
          }
        }
      }
      .padding({ left: 20, right: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
