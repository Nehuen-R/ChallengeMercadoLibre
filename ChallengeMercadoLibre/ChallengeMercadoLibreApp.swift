//
//  ChallengeMercadoLibreApp.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 28/08/2024.
//

import SwiftUI

@main
struct ChallengeMercadoLibreApp: App {
    @State var showMainView: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if showMainView {
                MainView()
            } else {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.showMainView = true                                
                            }
                        }
                    }
            }
        }
    }
}
