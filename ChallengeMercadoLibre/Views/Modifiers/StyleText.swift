//
//  StyleText.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 31/08/2024.
//

import SwiftUI

struct StyleTextView<Content: View>: View {
    private let content: () -> Content
    var font: Font
    var color: Color
    var bold: Bool = false
    var lineLimit: Int? = nil
    
    init(font: Font, color: Color, bold: Bool, lineLimit: Int? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.font = font
        self.color = color
        self.bold = bold
        self.lineLimit = lineLimit
        self.content = content
    }
    
    var body: some View {
        content()
            .font(font)
            .foregroundStyle(color)
            .bold(bold)
            .lineLimit(lineLimit)
    }
}

struct StyleTextModifier: ViewModifier {
    var font: Font
    var color: Color
    var bold: Bool = false
    var lineLimit: Int? = nil
    public func body( content: Content) -> some View {
        StyleTextView(font: font, color: color, bold: bold, lineLimit: lineLimit, content: {
            content
        })
    }
}
