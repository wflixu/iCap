//
//  OverlayerView.swift
//  iCap
//
//  Created by 李旭 on 2025/1/18.
//

import SwiftUI

struct OverlayerView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Button("close") {
                    dismiss()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.5))
        }
    }
}
