//
//  ProfileImageView.swift
//  Yakssok
//
//  Created by 김사랑 on 8/6/25.
//

import SwiftUI

struct ProfileImageView: View {
    let size: CGFloat

    var body: some View {
        Image(ProfileImageManager.getImageName())
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

