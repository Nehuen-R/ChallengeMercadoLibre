//
//  PriceView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

enum PriceViewStyle {
    case detail
    case item
}

struct PriceView: View {
    @Environment(\.colorScheme) var colorScheme
    var style: PriceViewStyle
    var hasOriginalPrice: Bool
    var originalPrice: Double
    var roundedOriginalPrice: Int
    var showDecimalForOriginalPrice: Bool
    
    var price: Double
    var roundedPrice: Int
    var showDecimalForPrice: Bool
    
    var currency: String
    var percentage: Int
    var freeShipping: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            if hasOriginalPrice {
                var priceText: Text {
                    if showDecimalForOriginalPrice {
                        return Text("\(currency) \(originalPrice, specifier: "%.2f")")
                    } else {
                        return Text("\(currency) \(roundedOriginalPrice)")
                    }
                }

                priceText
                    .styleText(font: style == .detail ? .subheadline : .caption,
                               color: .gray)
                    .overlay {
                        Rectangle()
                            .fill(.gray)
                            .frame(height: 1)
                    }
            }
            HStack {
                var priceText: Text {
                    if showDecimalForPrice {
                        return Text("\(currency) \(price, specifier: "%.2f")")
                    } else {
                        return Text("\(currency) \(roundedPrice)")
                    }
                }
                
                priceText
                    .styleText(font: style == .detail ? .title : .body,
                               color: style == .detail ? colorScheme == .light ? .black : .white : .black)
                
                if hasOriginalPrice {
                    Text("\(percentage)%")
                        .styleText(font: style == .detail ? .subheadline : .caption,
                                   color: Color("Green"))
                }
            }
            if freeShipping {
                Text("Envio gratis")
                    .styleText(font: .footnote, color: Color("Green"), bold: true)
            }
        }
    }
}

#Preview {
    PriceView(style: .detail,
              hasOriginalPrice: false,
              originalPrice: 0,
              roundedOriginalPrice: 0,
              showDecimalForOriginalPrice: false,
              price: 0,
              roundedPrice: 0,
              showDecimalForPrice: false,
              currency: "$",
              percentage: 0,
              freeShipping: false)
}
