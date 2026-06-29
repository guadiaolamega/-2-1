/**
 * PageTaskDetail - 任务详情页
 */

import { router } from '@kit.ArkUI';

interface TaskParams {
  taskId: number
  taskTitle: string
  taskDesc: string
  taskStatus: string
  taskPriority: string
}

@Entry
@Component
struct PageTaskDetail {
  @State taskId: number = 0
  @State taskTitle: string = ''
  @State taskDesc: string = ''
  @State taskStatus: string = 'todo'
  @State taskPriority: string = 'medium'
  @State isEditing: boolean = false
  @State editTitle: string = ''
  @State editDesc: string = ''
  @State showHistory: boolean = false
  @State statusHistory: string[] = []

  aboutToAppear(): void {
    const params = router.getParams() as TaskParams
    if (params) {
      this.taskId = params.taskId
      this.taskTitle = params.taskTitle
      this.taskDesc = params.taskDesc
      this.taskStatus = params.taskStatus
      this.taskPriority = params.taskPriority
      this.editTitle = params.taskTitle
      this.editDesc = params.taskDesc
      this.statusHistory = ['创建任务 → ' + this.taskStatus]
    }
  }

  build() {
    Column() {
      Row() {
        Button('← 返回')
          .onClick(() => { router.back() })
          .fontSize(14)
        Text('任务详情')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#2196F3')

      Scroll() {
        Column() {
          // 任务标题
          Text(this.taskTitle)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 10 })

          // 状态标签
          Row() {
            Text('状态: ')
              .fontSize(16)
            Text(this.taskStatus)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.taskStatus === 'done' ? '#4CAF50' :
                this.taskStatus === 'doing' ? '#FF9800' : '#FF0000')
          }
          .margin({ bottom: 10 })

          // 优先级标签
          Row() {
            Text('优先级: ')
              .fontSize(16)
            Text(this.taskPriority)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.taskPriority === 'high' ? '#FF0000' :
                this.taskPriority === 'medium' ? '#FF9800' : '#4CAF50')
          }
          .margin({ bottom: 15 })

          // 描述
          Text('描述:')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 5 })
          Text(this.taskDesc)
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 20 })

          // 操作按钮组
          Row() {
            Button('开始执行')
              .backgroundColor('#4CAF50')
              .onClick(() => {
                this.taskStatus = 'doing'
                this.statusHistory.push('→ doing')
              })
              .layoutWeight(1)
              .margin({ right: 10 })

            Button('标记完成')
              .backgroundColor('#9C27B0')
              .onClick(() => {
                this.taskStatus = 'done'
                this.statusHistory.push('→ done')
              })
              .layoutWeight(1)
              .margin({ right: 10 })

            Button('编辑')
              .backgroundColor('#FF9800')
              .onClick(() => { this.isEditing = true })
              .layoutWeight(1)
          }
          .margin({ bottom: 20 })

          // 编辑区域
          if (this.isEditing) {
            Column() {
              TextInput({ placeholder: '任务标题', text: this.editTitle })
                .width('100%')
                .height(45)
                .onChange((value: string) => { this.editTitle = value })
                .margin({ bottom: 10 })

              TextArea({ placeholder: '任务描述', text: this.editDesc })
                .width('100%')
                .height(100)
                .onChange((value: string) => { this.editDesc = value })
                .margin({ bottom: 10 })

              Row() {
                Button('保存')
                  .backgroundColor('#4CAF50')
                  .onClick(() => {
                    this.taskTitle = this.editTitle
                    this.taskDesc = this.editDesc
                    this.isEditing = false
                  })
                  .margin({ right: 15 })
                Button('取消')
                  .backgroundColor('#FF6600')
                  .onClick(() => { this.isEditing = false })
              }
            }
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ bottom: 20 })
          }

          // 状态历史
          Button('查看状态历史 ▼')
            .width('100%')
            .height(40)
            .backgroundColor('#E0E0E0')
            .onClick(() => { this.showHistory = !this.showHistory })
            .margin({ bottom: 10 })

          if (this.showHistory) {
            Column() {
              ForEach(this.statusHistory, (entry: string) => {
                Text(entry)
                  .fontSize(14)
                  .margin({ bottom: 5 })
              }, (entry: string, index: number) => entry + index)
            }
            .padding(15)
            .backgroundColor('#FFF8E1')
            .borderRadius(10)
          }
        }
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
