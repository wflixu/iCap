//
//  AboutTabView.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import SwiftUI

struct AboutTabView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .frame(maxWidth: 128, maxHeight: 128)
                Spacer()
            }
            HStack {
                Spacer()
                Text("iCap").font(.title)
                Text("\(getAppVersion())（\(getBuildVersion())）")
                Spacer()
            }
            HStack {
                Spacer()
                Text("iCap is a powerful screen capture and recording tool for macOS, featuring instant screenshot capabilities, screen recording, and easy sharing options.").font(.title3).multilineTextAlignment(.leading)
                Spacer()
            }
            Spacer()
            Divider()
            HStack(alignment: .center) {
                Image("github")

                Text(verbatim: "https://github.com/wflixu/iCap")
                Spacer()
            }
        }.padding([.top], 40)
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }

    func getBuildVersion() -> String {
        if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildVersion
        }
        return "Unknown"
    }
}

#Preview {
    AboutTabView()
}
