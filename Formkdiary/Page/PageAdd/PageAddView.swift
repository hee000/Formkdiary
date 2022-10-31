//
//  PageAddView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData
import Combine

func yearArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  for i in -10...10 {
    arr.append(cal.date(byAdding: .year, value: i, to: now)!)
  }

  return arr
}


func monthArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  let year = cal.component(.year, from: now)

  let yearDate1 = cal.date(from: DateComponents(year: year))!
  let yearDate2 = cal.date(byAdding: .day, value: 1, to: yearDate1)!
  
  for i in 0...11 {
    arr.append(cal.date(byAdding: .month, value: i, to: yearDate2)!)
  }
  
  return arr
}

struct PageAddView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var note: NoteMO

  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
      if let note = try? context.existingObject(with: objectID) as? NoteMO {
          self.note = note
      } else {
          // if there is no object with that id, create new one
          self.note = NoteMO(context: context)
          try? context.save()
      }
  }
  
  @State var category = 0
  
  @State var monthIndex: Int = (Calendar.current.component(.month, from: Date()) - 1)
  @State var yearIndex: Int = 10
  
  
  @State var weekDate: Date? = nil
  @State var date: Date? = nil
  
  @State var monthlyStyle: String? = nil
  
  @State var memoNameString = ""
  
  let years = yearArray()
  let months = monthArray()
  
  var body: some View {
    NavigationView{
      VStack{
        HStack{
          Button{
            self.category = 0
          } label: {
            Text("Monthly")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            self.category = 1
          } label: {
            Text("Weekly")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            self.category = 2
          } label: {
            Text("Daily")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            self.category = 3
          } label: {
            Text("Memo")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
        } //h
        .frame(height: 50)
        .foregroundColor(Color.customText)
//          ScrollView{
          VStack{
            if self.category == 0 {
              Text("Monthly")
                .bold()
              
              HStack(spacing: 0) {
                YearSelect(20)
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 100)
                MonthSelect(20)
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 100)
                crashX2
                  .opacity(0)
                crashX
                  .opacity(0)
              }
              
              Spacer()
              
              Button{
                
                let newPage = PageMO(context: viewContext)
                let newMonthly = MonthlyMO(context: viewContext)

                newMonthly.date = intToDate(year: yearIndex, month: monthIndex)
                
                
                newPage.monthly = newMonthly
                newPage.index = Int32(note.pages.count)
                //                print("count", note.pages.count)
                newPage.title = createTitle(type: .monthly, date: newMonthly.date)
                
                note.addToPages(newPage)
                note.lastIndex = Int32(note.pages.count - 1)
                
                CoreDataSave()
                
                presentationMode.wrappedValue.dismiss()
              } label: {
                Text("만들기")
              }
              
            } else if self.category == 1{
              Text("Weekly")
                .bold()
              
              HStack(spacing: 0) {
                
                YearSelect(14)
                  .frame(width: 80,height: 200/6)
                  .id(0)
                
                Spacer()
                
                MonthSelect(12)
                  .frame(width: 80,height: 200/6)
                  .id(0)
                
                crashX2
                  .opacity(0)
                  .id(0)
                  .frame(width: 0, height: 0)
                
                crashX
                  .opacity(0)
                  .id(0)
                  .frame(width: 0, height: 0)
              }
              .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              PageAddCalView(date: intToDate(year: yearIndex, month: monthIndex), weekDate: $weekDate)
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Text("스타일 설정")
                .bold()
                .frame(width:2*UIScreen.main.bounds.size.width/3, alignment: .center)
                .padding([.top, .bottom])
                .padding(.top)
              
              HStack{
                Button{
                } label: {
                  VStack{
                    VStack{
                      HStack{
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                      }
                      HStack{
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                        Rectangle()
                          .fill(Color.clear)
                          .cornerRadius(5)
                      }
                    }
                    .padding([.leading, .trailing])
                    .padding([.leading, .trailing])
                    Text("두줄보기")
                  }
                }
                .frame(height: 60)
                
                Button{
                  monthlyStyle = "twoColumnStyle"
                } label: {
                  VStack{
                    VStack{
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                    }
                    .padding([.leading, .trailing])
                    .padding([.leading, .trailing])
                    Text("한줄보기")
                  }
                }
              }
              .frame(height: 60)
              .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Spacer()
              
              Button{
                if weekDate != nil {
                  let newPage = PageMO(context: viewContext)
                  let newWeekly = WeeklyMO(context: viewContext)
                  
                  newWeekly.date = weekDate!
                  newWeekly.layout = monthlyStyle
                  
                  newPage.weekly = newWeekly
                  newPage.index = Int32(note.pages.count)
                  newPage.title = createTitle(type: .weekly, date: newWeekly.date)
                  
                  note.addToPages(newPage)
                  
                  CoreDataSave()
                  
                  presentationMode.wrappedValue.dismiss()
                }
              } label: {
                Text("만들기")
              }
            } else if self.category == 2{
              Text("Daily")
                .bold()
              
              HStack(spacing: 0) {
                YearSelect(14)
                  .frame(width: 80,height: 200/6)
                  .id(1)
                
                Spacer()
                
                MonthSelect(12)
                  .frame(width: 80,height: 200/6)
                  .id(1)
                
                crashX2
                  .opacity(0)
                  .id(1)
                  .frame(width: 0, height: 0)
                
                crashX
                  .opacity(0)
                  .id(1)
                  .frame(width: 0, height: 0)
              }
              .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              PageAddCalView(date: intToDate(year: yearIndex, month: monthIndex), weekDate: $date, pageType: .daily)
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Spacer()
              
              Button{
                if date != nil {
//                    print(createTitle(type: .daily, date: date!))
                  let newPage = PageMO(context: viewContext)
                  let newDaily = DailyMO(context: viewContext)

                  newDaily.date = date!

                  newPage.daily = newDaily
                  newPage.index = Int32(note.pages.count)
                  newPage.title = createTitle(type: .daily, date: newDaily.date)

                  note.addToPages(newPage)

                  CoreDataSave()

                  presentationMode.wrappedValue.dismiss()
                }
              } label: {
                Text("만들기")
              }
            } else if self.category == 3{
              Text("Memo")
                .bold()
              
              Text("메모 이름 설정")
              
              VStack{
                TextField("제목 없음", text: $memoNameString)
                  .disableAutocorrection(true)
                  .textCase(.none)
                Divider()
              }.frame(width: UIScreen.main.bounds.size.width/3*2)
              
              Spacer()
              
              Button{
                if memoNameString == "" {
                  memoNameString = "제목없음"
                }
                
                let newPage = PageMO(context: viewContext)
                let newMemo = MemoMO(context: viewContext)
                
                newPage.memo = newMemo
                newPage.index = Int32(note.pages.count)
                newPage.title = memoNameString
                
                note.addToPages(newPage)
                
                CoreDataSave()
                
                presentationMode.wrappedValue.dismiss()
              } label: {
                Text("만들기")
              }
            }
          }
          
        } // v
      .background(Color.customBg)
      .foregroundColor(Color.customText)
//        }//scroll
      .navigationTitle("페이지 만들기")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(Color.customIc)
          }
        }
        
      }//tool
    }//navi
  }
  
  @ViewBuilder
  var crashX: some View {
    Menu {
      ForEach(years.indices, id:\.self) { index in
        Button{
         yearIndex = index
        } label: {
          Text(years[index].toString(dateFormat: "yyyy"))
        }
      }
    } label: {
      Text(years[yearIndex].toString(dateFormat: "yyyy"))
    }
  }
  
  @ViewBuilder
  var crashX2: some View {
    Menu {
      ForEach(months.indices, id:\.self) { index in
        Button{
          monthIndex = index
        } label: {
          Text(months[index].toString(dateFormat: "MM"))
        }
      }
    } label: {
      Text(months[monthIndex].toString(dateFormat: "MM"))
    }
  }
  
  @ViewBuilder
  func YearSelect(_ fontsize: Int) -> some View {
      Picker(selection: self.$yearIndex, label: Text("")) {
        ForEach(years.indices, id:\.self) { index in
          Text(years[index].toString(dateFormat: "yyyy"))
            .font(.system(size: CGFloat(fontsize), weight: .bold))
        }
      }
      .pickerStyle(WheelPickerStyle())
  }
  
  @ViewBuilder
  func MonthSelect(_ fontsize: Int) -> some View {
    Picker(selection: self.$monthIndex, label: Text("")) {
      ForEach(months.indices, id:\.self) { index in
        Text(months[index].toString(dateFormat: "MM"))
          .font(.system(size: CGFloat(fontsize), weight: .bold))
      }
    }
    .pickerStyle(WheelPickerStyle())
  }
  
  func intToDate(year: Int, month: Int) -> Date{
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    dateComponent.year = calendar.component(.year, from: years[year])
    dateComponent.month = calendar.component(.month, from: months[month])
    return calendar.date(from: dateComponent)!
  }
  
}

enum PageType {
  case monthly
  case weekly
  case daily
  case memo
}


func createTitle(type: PageType, date: Date) -> String {
  var calendar = Calendar(identifier: .gregorian)
  if UserDefaults.standard.bool(forKey: "StartMonday") {
    calendar.firstWeekday = 2
  } else {
    calendar.firstWeekday = 1
  }
  
  switch(type) {
  case .monthly:
    let dateComponent = calendar.dateComponents([.year, .month], from: date)
    return "\(dateComponent.month!), \(dateComponent.year!)"
    
  case .weekly:
    let dateComponent = calendar.dateComponents([.year, .month, .weekOfMonth], from: date)
    return "\(dateComponent.month!)-\(dateComponent.weekOfMonth!)주, \(dateComponent.year!)"
    
  case .daily:
    let dateComponent = calendar.dateComponents([.year, .month, .day], from: date)
    return "\(dateComponent.month!)-\(dateComponent.day!), \(dateComponent.year!)"
  default:
    return ""
      
  }
  
}
