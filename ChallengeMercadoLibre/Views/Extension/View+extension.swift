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
    
    func styleText(font: Font, color: Color, bold: Bool = false, lineLimit: Int? = nil) -> some View {
        modifier(StyleTextModifier(font: font, color: color, bold: bold, lineLimit: lineLimit))
    }
}
