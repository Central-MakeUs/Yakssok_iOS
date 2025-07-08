//
//  MockUserData.swift
//  Yakssok
//
//  Created by 김사랑 on 7/8/25.
//

import Foundation

#if DEBUG
struct MockUserData {
    enum DataType: CaseIterable {
        case onlyMe
        case sample
        case many
    }

    static func users(for type: DataType) -> [User] {
        switch type {
        case .onlyMe: return onlyMeUser
        case .sample: return sampleUsers
        case .many: return manyUsers
        }
    }

    /// 나 혼자만 있는 상태 (메이트 없음)
    private static let onlyMeUser: [User] = [
        User(id: "me", name: "나", profileImage: nil)
    ]

    /// 샘플 사용자 데이터 (기본 테스트용)
    private static let sampleUsers: [User] = [
        User(id: "me", name: "나", profileImage: nil),
        User(id: "mate1", name: "일이삼사오", profileImage: "https://randomuser.me/api/portraits/med/women/75.jpg"),
        User(id: "mate2", name: "신짱구", profileImage: nil),
        User(id: "mate3", name: "신영식", profileImage: "https://randomuser.me/api/portraits/med/men/11.jpg"),
        User(id: "mate4", name: "봉미선", profileImage: "https://randomuser.me/api/portraits/med/women/2.jpg")
    ]

    /// 많은 사용자 데이터 (스크롤 테스트용)
    private static let manyUsers: [User] = [
        User(id: "me", name: "나", profileImage: nil),
        User(id: "mate1", name: "일이삼사오", profileImage: "https://randomuser.me/api/portraits/med/women/75.jpg"),
        User(id: "mate2", name: "신짱구", profileImage: nil),
        User(id: "mate3", name: "신영식", profileImage: "https://randomuser.me/api/portraits/med/men/11.jpg"),
        User(id: "mate4", name: "봉미선", profileImage: "https://randomuser.me/api/portraits/med/women/2.jpg"),
        User(id: "mate5", name: "신짱아", profileImage: nil),
        User(id: "mate6", name: "흰둥이", profileImage: "https://picsum.photos/id/1/200/300"),
        User(id: "mate7", name: "김철수", profileImage: "https://fastly.picsum.photos/id/699/100/100.jpg?hmac=CNGj_rh6dLPIhP9XoHwZ9VFiKbLEdNFc_WJR6D2lboU"),
        User(id: "mate8", name: "한유리", profileImage: nil),
        User(id: "mate9", name: "이맹구", profileImage: "https://randomuser.me/api/portraits/med/men/30.jpg"),
        User(id: "mate10", name: "이훈이", profileImage: nil),
        User(id: "mate11", name: "채성아", profileImage: "https://randomuser.me/api/portraits/med/women/30.jpg"),
        User(id: "mate12", name: "나미리", profileImage: nil)
    ]
}
#endif
