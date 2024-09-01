//
//  SearchServiceManager.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import Combine
import OSLog

enum SearchState: Equatable {
    static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.empty, .empty),
            (.error(_, _, _), .error(_, _, _)),
            (.ready(_), .ready(_)):
            return true
        default:
            return false
        }
    }
    
    case loading, empty
    case error(error: Error, errorString: String, url: String)
    case ready(data: ListItems)
}

final class SearchServiceManager {
    private (set) var searchState = CurrentValueSubject<SearchState, Never>(.loading)
    
    func processData(data: ListItems) {
        if data.results?.count ?? 0 > 0 {
            searchState.send(.ready(data: data))
        } else {
            searchState.send(.empty)
        }
    }
    
    func getSearchedData(searchText: String) {
        searchState.send(.loading)
        Task {
            let searchTextSpaced = searchText.replacingOccurrences(of: " ", with: "%20")
            do {
                let listItems = try await Networking.shared.apiGet(with: ListItems.self, url: "https://api.mercadolibre.com/sites/MLA/search?q=\(searchTextSpaced)")
                processData(data: listItems)
            } catch let error {
                Logger.GetErrors.fault("Error: \(error)")
                searchState.send(.error(error: error,
                                        errorString: " al realizar la busqueda de \(searchText)",
                                        url: "https://api.mercadolibre.com/sites/MLA/search?q=\(searchTextSpaced)"))
            }
        }
    }
}
