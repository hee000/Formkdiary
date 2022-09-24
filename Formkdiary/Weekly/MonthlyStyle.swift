//
//  MonthlyStyle.swift
//  Formkdiary
//
//  Created by cch on 2022/09/20.
//

import Foundation

enum MonthlyStyle: Int {
  case defaultStyle = 2
  case twoColumnStyle = 1
//  case
}

func layoutToMonthlyStyle(_ style: String?) -> MonthlyStyle {
  switch(style) {
  case "twoColumnStyle":
    return MonthlyStyle.twoColumnStyle
  default:
    return MonthlyStyle.defaultStyle
  }
}
