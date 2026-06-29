/**
 * PageSecond - 联系人列表页面
 * 包含搜索框、列表、点击跳转详情
 */

import { router } from '@kit.ArkUI';

interface ContactItem {
  name: string
  phone: string
  avatarColor: string
}

interface ContactNavParams {
  name: string
  phone: string
  color: string
}

@Entry
@Component
struct PageSecond {
  @State searchKeyword: string = ''
  @State contacts: ContactItem[] = [
    { name: '张三', phone: '13800138001', avatarColor: '#FF6B6B' },
    { name: '李四', phone: '13800138002', avatarColor: '#4ECDC4' },
    { name: '王五', phone: '13800138003', avatarColor: '#45B7D1' },
    { name: '赵六', phone: '13800138004', avatarColor: '#96CEB4' },
    { name: '钱七', phone: '13800138005', avatarColor: '#FFEAA7' },
    { name: '孙八', phone: '13800138006', avatarColor: '#DDA0DD' },
    { name: '周九', phone: '13800138007', avatarColor: '#98D8C8' },
    { name: '吴十', phone: '13800138008', avatarColor: '#F7DC6F' },
    { name: '郑十一', phone: '13800138009', avatarColor: '#BB8FCE' },
    { name: '王十二', phone: '13800138010', avatarColor: '#85C1E9' },
  ]
  @State filteredContacts: ContactItem[] = []
  @State sortBy: string = 'name'

  aboutToAppear(): void {
    this.filterContacts()
  }

  filterContacts(): void {
    if (this.searchKeyword === '') {
      this.filteredContacts = [...this.contacts]
    } else {
      this.filteredContacts = this.contacts.filter(c =>
      c.name.includes(this.searchKeyword) || c.phone.includes(this.searchKeyword)
      )
    }
  }

  sortContacts(): void {
    if (this.sortBy === 'name') {
      this.filteredContacts.sort((a, b) => a.name.localeCompare(b.name))
    } else {
      this.filteredContacts.sort((a, b) => a.phone.localeCompare(b.phone))
    }
  }

  build() {
    Column() {
      // 返回按钮 + 标题
      Row() {
        Button('← 返回')
          .onClick(() => { router.back() })
          .fontSize(14)
          .margin({ right: 10 })

        Text('联系人列表')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15 })
      .backgroundColor('#FFD700')

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索联系人...' })
          .width('70%')
          .height(40)
          .onChange((value: string) => {
            this.searchKeyword = value
            this.filterContacts()
          })

        Button('按姓名排序')
          .height(40)
          .fontSize(12)
          .onClick(() => { this.sortBy = 'name'; this.sortContacts() })
          .margin({ left: 5 })

        Button('按号码排序')
          .height(40)
          .fontSize(12)
          .onClick(() => { this.sortBy = 'phone'; this.sortContacts() })
          .margin({ left: 5 })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })

      // 列表
      List() {
        ForEach(this.filteredContacts, (item: ContactItem) => {
          ListItem() {
            Row() {
              // 头像（圆形色块）
              Text(item.name.substring(0, 1))
                .width(40)
                .height(40)
                .borderRadius(20)
                .backgroundColor(item.avatarColor)
                .textAlign(TextAlign.Center)
                .fontSize(18)
                .fontColor('#FFFFFF')
                .margin({ right: 15 })

              Column() {
                Text(item.name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                Text(item.phone)
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .layoutWeight(1)

              Text('详情 →')
                .fontSize(14)
                .fontColor('#FFD700')
            }
            .width('100%')
            .height(70)
            .padding({ left: 15, right: 15 })
            .onClick(() => {
              let detailParams: ContactNavParams = {
                name: item.name,
                phone: item.phone,
                color: item.avatarColor
              }
              router.pushUrl({ url: 'pages/PageDetail', params: detailParams })
            })
          }
        }, (item: ContactItem) => item.name)
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })

      // 添加联系人按钮
      Button('添加新联系人')
        .width('90%')
        .height(50)
        .backgroundColor('#4CAF50')
        .margin({ top: 10, bottom: 10 })
        .onClick(() => {
          let newName: string = '新联系人' + (this.contacts.length + 1)
          let newPhone: string = '138001380' + (this.contacts.length + 1).toString()
          let colors: string[] = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4']
          this.contacts.push({
            name: newName,
            phone: newPhone,
            avatarColor: colors[this.contacts.length % colors.length]
          })
          this.filterContacts()
        })

      // 统计
      Text('共 ' + this.filteredContacts.length + ' 位联系人（总计 ' + this.contacts.length + ' 位）')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
