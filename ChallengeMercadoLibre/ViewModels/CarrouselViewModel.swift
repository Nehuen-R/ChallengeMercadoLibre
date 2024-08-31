//
//  CarrouselViewModel.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import Combine

final class CarrouselViewModel: ObservableObject {
    var category: Categories
    @Published var listItems: [Item]?
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let carrouselServiceManager = CarrouselServiceManager()
    @Published var carrouselState: CarrouselState = .loading
    
    @Published var error: Error = GetErrors.emptyError
    @Published var errorString: String = ""
    @Published var urlForErrorRetry: String = ""
    
    init(category: Categories) {
        self.category = category
        
        initServices()
        
        getCarrouselData(category: category)
    }
    
    func initServices() {
        carrouselServiceManager.carrouselState.sink { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    break
                case let .error(error, errorString, urlForErrorRetry):
                    self?.error = error
                    self?.errorString = errorString
                    self?.urlForErrorRetry = urlForErrorRetry
                case let .ready(data):
                    self?.listItems = data
                }
                self?.carrouselState = state
            }
        }
        .store(in: &cancellableBag)
    }
    
    func getCarrouselData(category: Categories) {
        carrouselServiceManager.getCarrouselData(category: category)
    }
}
