//
//  ListItems.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation

struct ListItems: Codable {
    let results: [Item]?
}
        
struct Item: Codable {
    var id: String
    var title: String
    var seller: Seller?
    var condition: Condition?
    var thumbnail: String?
    var price: Double?
    var originalPrice: Double?
    var currency: Currency?
    var availableQuantity: Int
    var shipping: Shipping
    var attributes: [Attributes]
    
    init(id: String, title: String, seller: Seller?, condition: Condition?, thumbnail: String?, price: Double?, originalPrice: Double?, currency: Currency?, availableQuantity: Int, shipping: Shipping, attributes: [Attributes]) {
        self.id = id
        self.title = title
        self.seller = seller
        self.condition = condition
        self.thumbnail = thumbnail
        self.price = price
        self.originalPrice = originalPrice
        self.currency = currency
        self.availableQuantity = availableQuantity
        self.shipping = shipping
        self.attributes = attributes
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case seller
        case condition
        case thumbnail
        case price
        case originalPrice = "original_price"
        case currency = "currency_id"
        case availableQuantity = "available_quantity"
        case shipping
        case attributes
    }
    
    var conditionTraduct: String {
        switch condition {
        case .new:
            return "Nuevo"
        case .used:
            return "Usado"
        case .notSpecified:
            return "No especificado"
        default:
            return ""
        }
    }
    
    static let emptyItem: Item = Item(id: "1",
                                      title: "Skeleton",
                                      seller: Seller(id: 1, nickname: "Skeleton"),
                                      condition: Condition.notSpecified,
                                      thumbnail: "https://placehold.co/100x100",
                                      price: 100000,
                                      originalPrice: nil,
                                      currency: Currency.ars,
                                      availableQuantity: 10,
                                      shipping: Shipping(free_shipping: true),
                                      attributes: [])
    
    static let emptyItems: [Item] = [
        Item(id: "1",
            title: "Skeleton",
            seller: Seller(id: 1, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
        Item(id: "2",
            title: "Skeleton",
            seller: Seller(id: 2, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
        Item(id: "3",
            title: "Skeleton",
            seller: Seller(id: 3, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
        Item(id: "4",
            title: "Skeleton",
            seller: Seller(id: 3, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
        Item(id: "5",
            title: "Skeleton",
            seller: Seller(id: 5, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
        Item(id: "6",
            title: "Skeleton",
            seller: Seller(id: 6, nickname: "Skeleton"),
            condition: Condition.notSpecified,
            thumbnail: "https://placehold.co/100x100",
            price: 100000,
            originalPrice: nil,
            currency: Currency.ars,
            availableQuantity: 10,
            shipping: Shipping(free_shipping: true),
            attributes: []),
    ]
    
    var percentage: Int {
        guard let originalPrice = originalPrice, originalPrice > 0, let price = price else {
            return 0
        }
        
        let discount = originalPrice - price
        let discountPercentage = (discount / originalPrice) * 100
        return Int(discountPercentage)
    }
}

enum Currency: String, Codable {
    case ars = "ARS"
    case usd = "USD"
}

enum Condition: String, Codable {
    case new = "new"
    case used = "used"
    case notSpecified = "not_specified"
}

struct Shipping: Codable {
    let free_shipping: Bool
}

struct Seller: Codable {
    let id: Int
    let nickname: String?
}

struct Attributes: Codable {
    let id: String
    let name: String
    let value_name: String?
}
