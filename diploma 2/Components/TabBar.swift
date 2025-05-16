//
//  TabBar.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: WardrobeTab

    var body: some View {
        HStack(spacing: 16) {
            ForEach(WardrobeTab.allCases, id: \.self) { tab in
                Button(action: { withAnimation { selectedTab = tab } }) {
                    VStack {
                        Text(tab.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                        
                        Rectangle()
                            .frame(height: selectedTab == tab ? 2 : 0)
                            .foregroundColor(.gray)
                            .animation(.easeInOut, value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

