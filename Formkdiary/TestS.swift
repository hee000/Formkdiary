//
//  ImageSlider.swift
//  DormitoryDelivery
//
//  Created by cch on 2022/05/12.
//

import SwiftUI

struct ImageSlider: View {
    
    // 1
  let pages: [PageMO]
    
    var body: some View {
        // 2
      if !pages.isEmpty{
        TabView {
            ForEach(pages, id: \.self) { page in
                 //3
              if let monthly = page.monthly {
                Text("\(monthly.monthlyId)")
              }
            }
        }
        .tabViewStyle(PageTabViewStyle())
      }
    }
}
