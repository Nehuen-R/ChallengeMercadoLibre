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
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let mainServiceManager = MainServiceManager()
    @Published var mainState: MainState = .loading
    
    @Published var error: Error = GetErrors.emptyError
    @Published var errorString: String = ""
    @Published var urlErrorForRetry: String = ""
    
    init() {
        initService()
        
        getCategories()
    }
    
    func initService() {
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
    }
    
    func getCategories() {
        mainServiceManager.getCategories()
    }
}
