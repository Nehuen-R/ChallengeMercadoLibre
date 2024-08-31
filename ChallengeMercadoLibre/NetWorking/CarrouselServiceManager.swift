//
//  CarrouselServiceManager.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import Combine
import OSLog

enum CarrouselState: Equatable {
    static func == (lhs: CarrouselState, rhs: CarrouselState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.error(_, _, _), .error(_, _, _)),
            (.ready(_), .ready(_)):
            return true
        default:
            return false
        }
    }
    
    case loading
    case error(error: Error, errorString: String, urlForErrorRetry: String)
    case ready(data: [Item]?)
}

final class CarrouselServiceManager {
    private (set) var carrouselState = CurrentValueSubject<CarrouselState, Never>(.loading)
    
    func processData(data: [Item]?) {
        if data?.count ?? 0 > 0 {
            carrouselState.send(.ready(data: data))
        }
    }
    
    func getCarrouselData(category: Categories) {
        carrouselState.send(.loading)
        Task {
            do {
                let listItems = try await Networking.shared.apiGet(with: ListItems.self, url: "https://api.mercadolibre.com/sites/MLA/search?category=\(category.id)")
                processData(data: listItems.results ?? [])
            } catch let error {
                Logger.GetErrors.fault("Error: \(error)")
                carrouselState.send(.error(error: GetErrors.decodeError,
                                           errorString: " al cargar la informacion \(category.name)",
                                           urlForErrorRetry: "https://api.mercadolibre.com/sites/MLA/search?category=\(category.id)"))
            }
        }
    }
}
