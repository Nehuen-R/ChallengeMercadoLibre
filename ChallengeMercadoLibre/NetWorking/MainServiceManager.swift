//
//  MainServiceManager.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import Combine
import OSLog

enum MainState: Equatable {
    static func == (lhs: MainState, rhs: MainState) -> Bool {
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
    case error(error: Error, errorString: String, url: String)
    case ready(data: [Categories])
}

final class MainServiceManager {
    private (set) var mainState = CurrentValueSubject<MainState, Never>(.loading)
    
    func processData(data: [Categories]) {
        mainState.send(.ready(data: data))
    }
    
    func getCategories() {
        mainState.send(.loading)
        Task {
            do {
                let categories = try await Networking.shared.apiGet(with: [Categories].self, url: "https://api.mercadolibre.com/sites/MLA/categories")
                processData(data: categories)
            } catch let error {
                Logger.GetErrors.fault("Error: \(error)")
                mainState.send(.error(error: error,
                                      errorString: " al cargar la informacion de las categorias",
                                      url: "https://api.mercadolibre.com/sites/MLA/categories"))
            }
        }
    }
}
