//
//  HomeView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/5/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        YKColor.Neutral.grey50
            .ignoresSafeArea()
    }
}
