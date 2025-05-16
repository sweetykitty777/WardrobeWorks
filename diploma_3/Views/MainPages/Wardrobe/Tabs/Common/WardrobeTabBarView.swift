//
//  WardrobeTabBarView.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation
import SwiftUI

struct WardrobeTabBarView: View {
    @Binding var selectedTab: WardrobeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WardrobeTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue)
                                        .matchedGeometryEffect(id: "tabBackground", in: namespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.9))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    @Namespace private var namespace
}
