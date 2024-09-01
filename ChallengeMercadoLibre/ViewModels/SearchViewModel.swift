//
//  SearchViewModel.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 31/08/2024.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchData: ListItems = .init(results: [])
    @Published var searchedDataSave: [String] = []
    @Published var searched: Bool = false
    
    private let searchServiceManager = SearchServiceManager()
    @Published var searchState: SearchState = .loading
    
    @Published var error: Error = GetErrors.emptyError
    @Published var errorString: String = ""
    @Published var urlErrorForRetry: String = ""
    
    private var cancellableBag = Set<AnyCancellable>()
    
    var isSearching: Bool {
        searchText.isEmpty
    }
    
    init() {
        initService()
    }
    
    func initService() {
        searchServiceManager.searchState.sink { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading, .empty:
                    break
                case let .error(error, errorString, urlErrorForRetry):
                    self?.error = error
                    self?.errorString = errorString
                    self?.urlErrorForRetry = urlErrorForRetry
                case .ready(let data):
                    self?.searchData = data
                }
                self?.searchState = state
            }
        }
        .store(in: &cancellableBag)
    }
    
    func getItemsBySearchText(searchText: String) {
        searchServiceManager.getSearchedData(searchText: searchText)
    }
}

extension SearchViewModel {
    func navigationTitle(focusSearch: Bool) -> String {
        showSearch(focusSearch: focusSearch) ? "Search" : "Categories"
    }
    
    func showSearch(focusSearch: Bool) -> Bool {
        !isSearching || focusSearch
    }
    
    func resetSearch() {
        searchText = ""
        searched = false
        searchData = .init(results: [])
        searchState = .loading
    }
    
    func showCancelButton() -> Bool {
        !isSearching || searchState == .ready(data: searchData)
    }
    
    func setSearchString(text: String) {
        searchText = text
        searched = true
    }
    
    func searchIsStored() -> Bool {
        searchedDataSave.contains(where: { $0.lowercased().contains(searchText.lowercased())})
    }
    
    var searchStored: [String] {
        searchedDataSave.filter({ $0.lowercased().contains(searchText.lowercased())})
    }
    
    func emptyText() -> String {
        "No se encontraron productos para la búsqueda: ‘\(searchText)’."
    }
    
    func search() {
        searched = true
        getItemsBySearchText(searchText: searchText)
        if searchedDataSave.contains(where: {
            $0.lowercased() == searchText.lowercased()
        }) {
            searchedDataSave.removeAll { item in
                searchText.lowercased() == item.lowercased()
            }
            searchedDataSave.insert(searchText, at: 0)
        } else {
            if !isSearching && searchText != " " {
                searchedDataSave.insert(searchText, at: 0)
            }
        }
    }
}

