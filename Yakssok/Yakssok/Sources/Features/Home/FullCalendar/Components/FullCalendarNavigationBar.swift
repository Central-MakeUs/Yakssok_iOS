//
//  FullCalendarNavigationBar.swift
//  Yakssok
//
//  Created by 김사랑 on 7/21/25.
//

import SwiftUI
import YakssokDesignSystem

struct FullCalendarNavigationBar: View {
    let onBackTapped: () -> Void
    let onNotificationTapped: () -> Void
    let onMenuTapped: () -> Void

    var body: some View {
        HStack {
            Button(action: onBackTapped) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(YKColor.Neutral.grey900)
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: onNotificationTapped) {
                    Image("notif-nav-bar")
                        .frame(height: 24)
                }

                Button(action: onMenuTapped) {
                    Image("menu-nav-bar")
                        .frame(height: 24)
                }
            }
        }
        .frame(height: 44)
    }
}
