//
//  MainViewModel.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var categories: [Categories] = []
    
    @Published var searchText: String = ""
    @Published var searchData: ListItems = .init(results: [])
    @Published var searchedDataSave: [String] = []
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let mainServiceManager = MainServiceManager()
    @Published var mainState: MainState = .loading
    
    private let searchServiceManager = SearchServiceManager()
    @Published var searchState: SearchState = .loading
    
    @Published var searched: Bool = false
    
    @Published var error: Error = GetErrors.emptyError
    @Published var errorString: String = ""
    @Published var urlErrorForRetry: String = ""
    
    var isSearching: Bool {
        searchText.isEmpty
    }
    
    init() {
        initServices()
        
        getCategories()
    }
    
    func initServices() {
        mainServiceManager.mainState.sink { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    break
                case let .error(error, errorString, urlErrorForRetry):
                    self?.error = error
                    self?.errorString = errorString
                    self?.urlErrorForRetry = urlErrorForRetry
                case .ready(let data):
                    self?.categories = data
                }
                self?.mainState = state
            }
        }
        .store(in: &cancellableBag)
        
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
    
    func getCategories() {
        mainServiceManager.getCategories()
    }
    
    func getItemsBySearchText(searchText: String) {
        searchServiceManager.getSearchedData(searchText: searchText)
    }
}
