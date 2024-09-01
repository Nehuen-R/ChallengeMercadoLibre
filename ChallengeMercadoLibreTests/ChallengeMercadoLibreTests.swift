//
//  ChallengeMercadoLibreTests.swift
//  ChallengeMercadoLibreTests
//
//  Created by nehuen roth on 28/08/2024.
//

import Combine
import XCTest
@testable import ChallengeMercadoLibre

final class ChallengeMercadoLibreTests: XCTestCase {
    var mainViewModel = MainViewModel()
    var searchViewModel = SearchViewModel()
    
    
    func testTryToLoadCategories() throws {
        var cancellableBag = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "Categories should load successfully")
        
        mainViewModel.getCategories()
        
        let errorForCompare = " al cargar la informacion de las categorias"

        mainViewModel.$mainState.sink { state in
            switch state {
            case .loading:
                print("Loading")
            case let .error(error, errorForString, url):
                print("Error")
                XCTAssertThrowsError(error)
                XCTAssertEqual(errorForString, errorForCompare)
                XCTAssertNotNil(url)
            case .ready(let data):
                print("Ready")
                XCTAssertTrue(self.mainViewModel.categories.count > 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellableBag)

        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTryToSearch() throws {
        var cancellableBag = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "Search should load data successfully")
        
        searchViewModel.getItemsBySearchText(searchText: "Motorola")
        
        let errorForCompare = " al realizar la busqueda de \(searchViewModel.searchText)"
        
        searchViewModel.$searchState.sink { state in
            switch state {
            case .empty:
                print("Empty")
            case .loading:
                print("Loading")
            case let .error(error, errorForString, url):
                print("Error")
                XCTAssertThrowsError(error)
                XCTAssertEqual(errorForString, errorForCompare)
                XCTAssertNotNil(url)
            case .ready(let data):
                print("Ready")
                XCTAssertTrue(self.searchViewModel.searchData.results?.count ?? 0 > 0)
                expectation.fulfill()
            }
        }
        .store(in: &cancellableBag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTryToLoadCategoriesData() throws {
        var cancellableBag = Set<AnyCancellable>()
        var categoriesLoaded: [Categories] = []
        let expectationCategoriesLoaded = XCTestExpectation(description: "Categories should load successfully")
        
        mainViewModel.getCategories()
        
        mainViewModel.$mainState.sink { state in
            switch state {
            case .loading:
                print("Loading")
            case let .error(error, _, url):
                print("Error")
                XCTAssertThrowsError(error)
                XCTAssertNotNil(url)
            case let .ready(data):
                print("Ready")
                categoriesLoaded = data
                expectationCategoriesLoaded.fulfill()
            }
        }
        .store(in: &cancellableBag)
        
        wait(for: [expectationCategoriesLoaded], timeout: 15.0)
        
        for category in categoriesLoaded {
            let expectationCarrouselLoaded = XCTestExpectation(description: "Carrousel should load categories data")
            let carrouselViewModel = CarrouselViewModel(category: category)
            carrouselViewModel.getCarrouselData(category: category)
            print(category)
            let errorForCompare = " al cargar la informacion \(category.name)"
            
            carrouselViewModel.$carrouselState.sink { state in
                switch state {
                case .loading:
                    print("Loading Carrousel Data")
                case let .error(error, errorForString, url):
                    print("Error")
                    XCTAssertThrowsError(error)
                    XCTAssertEqual(errorForString, errorForCompare)
                    XCTAssertNotNil(url)
                case let .ready(carrouselData):
                    print("Ready")
                    XCTAssertTrue(carrouselData?.count ?? 0 > 0)
                    expectationCarrouselLoaded.fulfill()
                }
            }
            .store(in: &cancellableBag)

            wait(for: [expectationCarrouselLoaded], timeout: 15.0)
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
