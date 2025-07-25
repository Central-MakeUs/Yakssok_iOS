//
//  WebView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/20/25.
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 업데이트 로직 필요시 추가
    }
}
