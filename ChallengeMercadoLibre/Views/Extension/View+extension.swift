//
//  View+extension.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

extension View {
    func shimmer(configuration: ShimmerConfiguration = .defaultConfiguration) -> some View {
        modifier(ShimmerModifier(configuration: configuration))
    }
}
