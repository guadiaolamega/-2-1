/**
 * Complex Test App - 任务管理+笔记+购物清单+设置
 * bundleName: com.test.complexapp
 *
 * 5个页面，使用 Tabs 导航：
 * - Index: Tab 主页（任务、笔记、购物、设置 4个Tab）
 * - PageTaskDetail: 任务详情页
 * - PageNoteDetail: 笔记详情页
 * - PageShopping: 购物清单页
 * - PageProfile: 个人资料页
 */

import { router } from '@kit.ArkUI';
import { TaskItem, NoteItem, createDefaultTasks } from '../model/DataModels'

interface TaskNavParams {
  taskId: number
  taskTitle: string
  taskDesc: string
  taskStatus: string
  taskPriority: string
}

interface NoteNavParams {
  noteId: number
  noteContent: string
  noteTime: string
  noteColor: string
}

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0
  @State tasks: TaskItem[] = createDefaultTasks()
  @State notes: NoteItem[] = [
    { id: 1, content: '今天的会议笔记', timestamp: '10:30', color: '#FFEAA7' },
    { id: 2, content: 'HapTest 源码阅读笔记', timestamp: '14:20', color: '#DDA0DD' },
    { id: 3, content: '改进方案初步想法', timestamp: '16:00', color: '#98D8C8' },
  ]
  @State shoppingItems: string[] = ['键盘', '显示器', 'USB-C 数据线', '鼠标垫', '笔记本支架']
  @State shoppingChecked: boolean[] = [false, false, false, false, false]
  @State newShoppingItem: string = ''
  @State filterStatus: string = 'all'
  @State showDialog: boolean = false
  @State dialogMessage: string = ''

  // 统计
  @State todoCount: number = 0
  @State doingCount: number = 0
  @State doneCount: number = 0

  aboutToAppear(): void {
    this.updateCounts()
  }

  updateCounts(): void {
    this.todoCount = this.tasks.filter(t => t.status === 'todo').length
    this.doingCount = this.tasks.filter(t => t.status === 'doing').length
    this.doneCount = this.tasks.filter(t => t.status === 'done').length
  }

  getFilteredTasks(): TaskItem[] {
    if (this.filterStatus === 'all') return this.tasks
    return this.tasks.filter(t => t.status === this.filterStatus)
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('复杂测试应用')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('个人资料')
          .fontSize(12)
          .height(35)
          .onClick(() => {
            router.pushUrl({ url: 'pages/PageProfile' })
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#2196F3')

      Tabs({ index: this.currentTabIndex }) {
        // Tab 1: 任务管理
        TabContent() {
          this.TaskTab()
        }
        .tabBar('任务')

        // Tab 2: 笔记
        TabContent() {
          this.NoteTab()
        }
        .tabBar('笔记')

        // Tab 3: 购物清单
        TabContent() {
          this.ShoppingTab()
        }
        .tabBar('购物')

        // Tab 4: 统计
        TabContent() {
          this.StatsTab()
        }
        .tabBar('统计')
      }
      .layoutWeight(1)
      .onChange((index: number) => { this.currentTabIndex = index })
    }
    .width('100%')
    .height('100%')
  }

  // ===== 任务 Tab =====
  @Builder
  TaskTab() {
    Column() {
      // 过滤按钮
      Row() {
        Button('全部')
          .fontSize(12)
          .height(35)
          .backgroundColor(this.filterStatus === 'all' ? '#2196F3' : '#E0E0E0')
          .onClick(() => { this.filterStatus = 'all' })
          .margin({ right: 5 })

        Button('待办 (' + this.todoCount + ')')
          .fontSize(12)
          .height(35)
          .backgroundColor(this.filterStatus === 'todo' ? '#FF9800' : '#E0E0E0')
          .onClick(() => { this.filterStatus = 'todo' })
          .margin({ right: 5 })

        Button('进行中 (' + this.doingCount + ')')
          .fontSize(12)
          .height(35)
          .backgroundColor(this.filterStatus === 'doing' ? '#4CAF50' : '#E0E0E0')
          .onClick(() => { this.filterStatus = 'doing' })
          .margin({ right: 5 })

        Button('完成 (' + this.doneCount + ')')
          .fontSize(12)
          .height(35)
          .backgroundColor(this.filterStatus === 'done' ? '#9C27B0' : '#E0E0E0')
          .onClick(() => { this.filterStatus = 'done' })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 10 })

      // 任务列表
      List() {
        ForEach(this.getFilteredTasks(), (task: TaskItem) => {
          ListItem() {
            Row() {
              // 优先级色条
              Text('')
                .width(5)
                .height(60)
                .backgroundColor(task.priority === 'high' ? '#FF0000' :
                  task.priority === 'medium' ? '#FF9800' : '#4CAF50')
                .margin({ right: 10 })

              Column() {
                Text(task.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(task.description)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)

              // 状态切换按钮
              Button(task.status === 'done' ? '✓' : '→')
                .width(35)
                .height(35)
                .fontSize(16)
                .backgroundColor(task.status === 'done' ? '#4CAF50' : '#2196F3')
                .onClick(() => {
                  if (task.status === 'todo') task.status = 'doing'
                  else if (task.status === 'doing') task.status = 'done'
                  else task.status = 'todo'
                  this.updateCounts()
                })

              Text('详情 →')
                .fontSize(12)
                .fontColor('#2196F3')
                .margin({ left: 10 })
                .onClick(() => {
                  let taskParams: TaskNavParams = {
                    taskId: task.id,
                    taskTitle: task.title,
                    taskDesc: task.description,
                    taskStatus: task.status,
                    taskPriority: task.priority
                  }
                  router.pushUrl({ url: 'pages/PageTaskDetail', params: taskParams })
                })
            }
            .width('100%')
            .height(70)
            .padding({ left: 15, right: 15 })
          }
        }, (task: TaskItem) => task.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })

      // 添加任务
      Row() {
        TextInput({ placeholder: '新任务标题...' })
          .width('60%')
          .height(40)
          .onChange((value: string) => { this.newShoppingItem = value })
          .margin({ right: 10 })

        Button('添加')
          .height(40)
          .backgroundColor('#2196F3')
          .onClick(() => {
            if (this.newShoppingItem.length > 0) {
              this.tasks.push({
                id: this.tasks.length + 1,
                title: this.newShoppingItem,
                description: '新创建的任务',
                priority: 'medium',
                status: 'todo',
                createdAt: '2026-06-27'
              })
              this.newShoppingItem = ''
              this.updateCounts()
            }
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    }
    .width('100%')
    .height('100%')
  }

  // ===== 笔记 Tab =====
  @Builder
  NoteTab() {
    Column() {
      Grid() {
        ForEach(this.notes, (note: NoteItem) => {
          GridItem() {
            Column() {
              Text(note.content)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .maxLines(3)
              Text(note.timestamp)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 10 })
            }
            .width('100%')
            .height(120)
            .padding(12)
            .backgroundColor(note.color)
            .borderRadius(10)
            .onClick(() => {
              let noteParams: NoteNavParams = {
                noteId: note.id,
                noteContent: note.content,
                noteTime: note.timestamp,
                noteColor: note.color
              }
              router.pushUrl({ url: 'pages/PageNoteDetail', params: noteParams })
            })
          }
        }, (note: NoteItem) => note.id.toString())
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 15, right: 15, top: 10 })

      // 添加笔记
      Row() {
        TextInput({ placeholder: '新笔记内容...' })
          .width('60%')
          .height(40)
          .margin({ right: 10 })
          .onChange((value: string) => { this.newShoppingItem = value })

        Button('添加笔记')
          .height(40)
          .backgroundColor('#FF9800')
          .onClick(() => {
            if (this.newShoppingItem.length > 0) {
              let colors: string[] = ['#FFEAA7', '#DDA0DD', '#98D8C8', '#FF6B6B', '#45B7D1']
              this.notes.push({
                id: this.notes.length + 1,
                content: this.newShoppingItem,
                timestamp: new Date().getHours().toString() + ':' + new Date().getMinutes().toString(),
                color: colors[this.notes.length % colors.length]
              })
              this.newShoppingItem = ''
            }
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, bottom: 10 })
    }
    .width('100%')
    .height('100%')
  }

  // ===== 购物 Tab =====
  @Builder
  ShoppingTab() {
    Column() {
      List() {
        ForEach(this.shoppingItems, (item: string, index?: number) => {
          ListItem() {
            Row() {
              Checkbox()
                .select(this.shoppingChecked[index ?? 0])
                .onChange((checked: boolean) => {
                  if (index !== undefined) this.shoppingChecked[index] = checked
                })
                .margin({ right: 15 })

              Text(item)
                .fontSize(16)
                .fontColor(this.shoppingChecked[index ?? 0] ? '#999999' : '#333333')
                .decoration({ type: this.shoppingChecked[index ?? 0] ? TextDecorationType.LineThrough : TextDecorationType.None })
                .layoutWeight(1)

              Button('删除')
                .height(30)
                .fontSize(12)
                .backgroundColor('#FF6600')
                .onClick(() => {
                  if (index !== undefined) {
                    this.shoppingItems.splice(index, 1)
                    this.shoppingChecked.splice(index, 1)
                  }
                })
            }
            .width('100%')
            .height(55)
            .padding({ left: 15, right: 15 })
          }
        }, (item: string, index?: number) => item + (index ?? 0))
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })

      Row() {
        TextInput({ placeholder: '添加购物项...' })
          .width('60%')
          .height(40)
          .onChange((value: string) => { this.newShoppingItem = value })
          .margin({ right: 10 })

        Button('添加')
          .height(40)
          .backgroundColor('#4CAF50')
          .onClick(() => {
            if (this.newShoppingItem.length > 0) {
              this.shoppingItems.push(this.newShoppingItem)
              this.shoppingChecked.push(false)
              this.newShoppingItem = ''
            }
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })

      Text('已购买 ' + this.shoppingChecked.filter(c => c).length + '/' + this.shoppingItems.length + ' 项')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 10 })
    }
    .width('100%')
    .height('100%')
  }

  // ===== 统计 Tab =====
  @Builder
  StatsTab() {
    Column() {
      Text('任务统计概览')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      // 进度条
      Row() {
        Text('完成进度')
          .fontSize(16)
          .layoutWeight(1)
        Text(this.doneCount + '/' + this.tasks.length)
          .fontSize(16)
          .fontColor('#4CAF50')
      }
      .width('90%')
      .margin({ bottom: 5 })

      Progress({ value: this.doneCount, total: this.tasks.length, type: ProgressType.Linear })
        .width('90%')
        .color('#4CAF50')
        .margin({ bottom: 30 })

      // 状态分布
      Row() {
        Column() {
          Text('待办')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Text(this.todoCount.toString())
            .fontSize(28)
            .fontColor('#FF9800')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('进行中')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Text(this.doingCount.toString())
            .fontSize(28)
            .fontColor('#4CAF50')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('完成')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Text(this.doneCount.toString())
            .fontSize(28)
            .fontColor('#9C27B0')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('90%')
      .height(100)
      .backgroundColor('#F5F5F5')
      .borderRadius(10)
      .margin({ bottom: 30 })

      // 优先级分布
      Text('优先级分布')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 })

      Row() {
        Text('高优先级: ' + this.tasks.filter(t => t.priority === 'high').length)
          .fontSize(14)
          .fontColor('#FF0000')
          .layoutWeight(1)
        Text('中优先级: ' + this.tasks.filter(t => t.priority === 'medium').length)
          .fontSize(14)
          .fontColor('#FF9800')
          .layoutWeight(1)
        Text('低优先级: ' + this.tasks.filter(t => t.priority === 'low').length)
          .fontSize(14)
          .fontColor('#4CAF50')
          .layoutWeight(1)
      }
      .width('90%')
      .margin({ bottom: 30 })

      // 购物统计
      Text('购物清单统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 })

      Progress({ value: this.shoppingChecked.filter(c => c).length, total: this.shoppingItems.length, type: ProgressType.Linear })
        .width('90%')
        .color('#2196F3')
        .margin({ bottom: 10 })

      Text('已购买 ' + this.shoppingChecked.filter(c => c).length + ' 项，共 ' + this.shoppingItems.length + ' 项')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}
