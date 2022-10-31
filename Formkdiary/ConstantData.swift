//
//  ConstantData.swift
//  Formkdiary
//
//  Created by cch on 2022/09/17.
//

import Foundation


let week = ["일", "월", "화", "수", "목", "금", "토"]

let sunWeekKor = ["일", "월", "화", "수", "목", "금", "토"]
let sunWeekEng = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Satr"]

let monWeekKor = ["월", "화", "수", "목", "금", "토", "일"]
let monWeekEng = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


let asdsad = { return ":123"}


var sunWeek = !UserDefaults.standard.bool(forKey: "EnglishDay") ? monWeekKor : monWeekEng
var monWeek = !UserDefaults.standard.bool(forKey: "EnglishDay") ? monWeekKor : monWeekEng

func startWeekRefresh() {
  sunWeek = !UserDefaults.standard.bool(forKey: "EnglishDay") ? monWeekKor : monWeekEng
  monWeek = !UserDefaults.standard.bool(forKey: "EnglishDay") ? monWeekKor : monWeekEng
}
