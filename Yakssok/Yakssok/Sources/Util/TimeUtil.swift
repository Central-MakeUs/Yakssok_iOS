//
//  TimeUtil.swift
//  Yakssok
//
//  Created by 김사랑 on 8/3/25.
//

import Foundation

struct TimeUtil {
    static func timeString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        if timeInterval < 60 { // 1분 미만
            return "방금전"
        } else if timeInterval < 3600 { // 1시간 미만
            let minutes = Int(timeInterval / 60)
            return "\(minutes)분전"
        } else if timeInterval < 86400 { // 24시간 미만
            let hours = Int(timeInterval / 3600)
            return "\(hours)시간전"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)일전"
        }
    }
}
