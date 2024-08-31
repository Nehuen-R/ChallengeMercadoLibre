//
//  ItemViewModel.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

final class ItemViewModel: ObservableObject {
    @Published var item: Item
    @Published var isMock: Bool
    
    let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    init(item: Item, isMock: Bool = false) {
        self.item = item
        self.isMock = isMock
    }
    
    func showCondition() -> Bool {
        item.condition != .notSpecified || item.conditionTraduct != ""
    }
    
    func hasOriginalPrice() -> Bool {
        item.originalPrice != nil
    }
    
    func numberRounded(number: Double) -> Int {
        Int(number.rounded())
    }
    
    func showDecimal(numberRounded: Int, number: Double) -> Bool {
        Double(numberRounded) - number > 0
    }
    
    func getCurrency() -> String {
        item.currency == .ars ? "$" : "U$D"
    }
    
    func getTitle() -> String {
        item.title
    }
    
    func getImage() -> String {
        item.thumbnail ?? ""
    }
    
    func getOriginalPrice() -> Double {
        guard let originalPrice = item.originalPrice else { return 0 }
        
        return originalPrice
    }
    
    func getPrice() -> Double {
        guard let price = item.price else { return 0 }
        
        return price
    }
    
    func getPercentage() -> Int {
        item.percentage
    }
    
    func hasFreeShipping() -> Bool {
        item.shipping.free_shipping
    }
    
    func getSellerNickname() -> String {
        item.seller?.nickname ?? ""
    }
    
    func getAttributes() -> [Attributes] {
        item.attributes
    }
}
