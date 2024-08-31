//
//  NavigationViewModel.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

final class NavigationViewModel: ObservableObject {
    static let shared = NavigationViewModel()
    
    @Published var navigateTo: AnyView = AnyView(EmptyView())
    @Published var navigationIsActive: Bool = false
}
