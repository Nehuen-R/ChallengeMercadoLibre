//
//  SplashScreen.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

struct SplashScreen: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Color.white
                    .ignoresSafeArea(edges: .all)
            } else {
                Color.black
                    .ignoresSafeArea(edges: .all)
            }
            Image("SplashScreen")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    SplashScreen()
}
