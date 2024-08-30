//
//  MainView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 26/08/2024.
//

import SwiftUI
import Combine
import OSLog

struct Categories: Codable {
    let id: String
    let name: String
}

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

enum getErrors: Error {
    case invalidUrl
    case invalidResponse
    case decodeError
    case emptyError
}

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let getErrors = Logger(subsystem: subsystem, category: "API_GET_ERRORS")
}

class Networking {
    static var shared = Networking()
    
    func apiGet<T: Codable>(with: T.Type, url: String) async throws -> T {
        guard let url = URL(string: url) else {
            Logger.getErrors.fault("Invalid URL")
            throw getErrors.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.getErrors.fault("Invalid Response for \(url)")
            throw getErrors.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            Logger.getErrors.fault("Invalid Response: \(httpResponse.statusCode)")
            throw getErrors.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            Logger.getErrors.debug("\(url)")
            Logger.getErrors.fault("dataCorrupted \(context.debugDescription)")
            throw getErrors.decodeError
        } catch let DecodingError.keyNotFound(key, context) {
            Logger.getErrors.debug("\(url)")
            Logger.getErrors.fault("Key '\(key.stringValue)' not found \(context.debugDescription)")
            throw getErrors.decodeError
        } catch let DecodingError.valueNotFound(value, context) {
            Logger.getErrors.debug("\(url)")
            Logger.getErrors.fault("Value '\(value)' not found \(context.debugDescription)")
            throw getErrors.decodeError
        } catch let DecodingError.typeMismatch(type, context) {
            Logger.getErrors.fault("Type '\(type)' mismatch: \(context.debugDescription)")
            throw getErrors.decodeError
        } catch {
            Logger.getErrors.fault("error: \(error)")
            throw getErrors.decodeError
        }
        
    }
}

class NavigationViewModel: ObservableObject {
    static let shared = NavigationViewModel()
    
    @Published var navigateTo: AnyView = AnyView(EmptyView())
    @Published var navigationIsActive: Bool = false
}

struct ShimmerConfiguration {
    public let gradient: Gradient
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    public let duration: TimeInterval
    
    static let defaultConfiguration: ShimmerConfiguration = .init(gradient: Gradient.init(colors: [.black.opacity(0.1), .black, .black.opacity(0.1)]),
                                                                  initialLocation: (start: UnitPoint(x: -1, y: 0.5), end: .leading),
                                                                  finalLocation: (start: .trailing, end: UnitPoint(x: 2, y: 0.5)),
                                                                  duration: 2)
}

struct ShimmeringView<Content: View>: View {
  private let content: () -> Content
  private let configuration: ShimmerConfiguration
  @State private var startPoint: UnitPoint
  @State private var endPoint: UnitPoint
  init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
    self.configuration = configuration
    self.content = content
      _startPoint = .init(wrappedValue: configuration.initialLocation.start)
    _endPoint = .init(wrappedValue: configuration.initialLocation.end)
  }
  var body: some View {
      content()
          .mask {
              LinearGradient(
                gradient: configuration.gradient,
                startPoint: startPoint,
                endPoint: endPoint
              )
              .blendMode(.screen)
          }
          .onAppear {
              withAnimation(Animation.linear(duration: configuration.duration).repeatForever(autoreverses: false)) {
                  startPoint = configuration.finalLocation.start
                  endPoint = configuration.finalLocation.end
              }
          }
  }
}

struct ShimmerModifier: ViewModifier {
  let configuration: ShimmerConfiguration
  public func body(content: Content) -> some View {
    ShimmeringView(configuration: configuration) { content }
  }
}


extension View {
    func shimmer(configuration: ShimmerConfiguration = .defaultConfiguration) -> some View {
        modifier(ShimmerModifier(configuration: configuration))
    }
}

class MainServiceManager {
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
                Logger.getErrors.fault("Error: \(error)")
                mainState.send(.error(error: error,
                                      errorString: " al cargar la informacion de las categorias",
                                      url: "https://api.mercadolibre.com/sites/MLA/categories"))
            }
        }
    }
}

class SearchServiceManager {
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
                Logger.getErrors.fault("Error: \(error)")
                searchState.send(.error(error: error,
                                        errorString: " al realizar la busqueda",
                                        url: "https://api.mercadolibre.com/sites/MLA/search?q=\(searchTextSpaced)"))
            }
        }
    }
}

class MainViewModel: ObservableObject {
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
    
    @Published var error: Error = getErrors.emptyError
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

struct ErrorView: View {
    var error: Error
    var errorString: String = ""
    var retryAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.primary)
                Text("Ocurrio un error inesperado\( errorString)")
            }
            Text("Por favor intenta de nuevo mas tarde")
            Button(action:{
                retryAction()
            }){
                Text("Reintentar")
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Material.thick)
                    }
            }
            Spacer()
        }
    }
}

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var navigationViewModel = NavigationViewModel.shared
    @FocusState var focusSearch: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !viewModel.isSearching || focusSearch {
                    switch viewModel.searchState {
                    case .loading:
                        if viewModel.isSearching {
                                ForEach(viewModel.searchedDataSave, id: \.self) { item in
                                    Button(action: {
                                        viewModel.searchText = item
                                        viewModel.searched = true
                                        focusSearch = false
                                    }) {
                                        HStack {
                                            Text(item)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                    .padding()
                                }
                        } else if !viewModel.isSearching {
                            if viewModel.searchedDataSave.contains(where: { $0.lowercased().contains(viewModel.searchText.lowercased())}) && focusSearch {
                                ForEach(viewModel.searchedDataSave.filter({ $0.lowercased().contains(viewModel.searchText.lowercased())}), id: \.self) { item in
                                    Button(action: {
                                        viewModel.searchText = item
                                        viewModel.searched = true
                                        focusSearch = false
                                    }) {
                                        HStack {
                                            Text(item)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                    .padding()
                                }
                            } else if viewModel.searched {
                                VStack {
                                    ProgressView()
                                        .tint(.primary)
                                        .scaleEffect(2)
                                }
                                .padding()
                            }
                        }
                    case .empty:
                        VStack {
                            Text("No se encontraron productos para la búsqueda: ‘\(viewModel.searchText)’. ")
                        }
                        .padding()
                    case .error:
                        ErrorView(error: viewModel.error) {
                            viewModel.getItemsBySearchText(searchText: viewModel.urlErrorForRetry)
                        }
                    case .ready:
                        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 2)) {
                            ForEach(viewModel.searchData.results ?? [], id: \.id) { item in
                                ItemView(item: item)
                            }
                        }
                        .padding()
                    }
                } else {
                    switch viewModel.mainState {
                    case .loading:
                        VStack {
                            ProgressView()
                                .tint(.primary)
                                .scaleEffect(2)
                        }
                        .padding()
                    case .error:
                        ErrorView(error: viewModel.error, errorString: viewModel.errorString) {
                            viewModel.getCategories()
                        }
                        .padding()
                    case .ready:
                        LazyVStack {
                            ForEach(viewModel.categories, id: \.id) { category in
                                Carrousel(viewModel: CarrouselViewModel(category: category))
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigationViewModel.navigationIsActive, destination: {
                navigationViewModel.navigateTo
            })
            .navigationTitle(!viewModel.isSearching || focusSearch ? "Search" : "Categories")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, content: {
                HStack {
                    TextField("Search", text: $viewModel.searchText, prompt: Text("Search..."))
                        .focused($focusSearch)
                        .onLongPressGesture(minimumDuration: 0.0) {
                            focusSearch = true
                        }
                        .autocorrectionDisabled()
                        .overlay {
                                HStack {
                                    if !viewModel.isSearching {
                                        Spacer()
                                        Button {
                                            viewModel.searchText = ""
                                            focusSearch = true
                                            viewModel.searched = false
                                            viewModel.searchData = .init(results: [])
                                            viewModel.searchState = .loading
                                        } label: {
                                            Image(systemName: "multiply.circle.fill")
                                        }
                                        .foregroundColor(.secondary)
                                        .padding(.trailing, 4)
                                }
                            }
                        }
                    if focusSearch || !viewModel.isSearching || viewModel.searchState == .ready(data: viewModel.searchData) {
                        Button(action:{
                            viewModel.searchText = ""
                            focusSearch = false
                            viewModel.searchData = .init(results: [])
                            viewModel.searchState = .loading
                            viewModel.searched = false
                        }){
                            Text("Cancel")
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                        .ignoresSafeArea(edges: .all)
                )
            })
            .onAppear(perform: {
                focusSearch = false
            })
            .onSubmit {
                viewModel.searched = true
                focusSearch = false
                viewModel.getItemsBySearchText(searchText: viewModel.searchText)
                if !viewModel.searchedDataSave.contains(where: {
                    $0.lowercased() == viewModel.searchText.lowercased()
                }) {
                    if !viewModel.isSearching && viewModel.searchText != " " {
                        viewModel.searchedDataSave.append(viewModel.searchText)
                    }
                }
            }
            .submitLabel(.search)
            .onChange(of: viewModel.searched, { oldValue, newValue in
                if newValue {
                    focusSearch = false
                    viewModel.getItemsBySearchText(searchText: viewModel.searchText)
                    if !viewModel.searchedDataSave.contains(where: {
                        $0.lowercased() == viewModel.searchText.lowercased()
                    }) {
                        if !viewModel.isSearching && viewModel.searchText != " " {
                            viewModel.searchedDataSave.append(viewModel.searchText)
                        }
                    }
                }
            })
            .scrollDismissesKeyboard(.interactively)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Material.thin)
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    MainView()
}

class CarrouselViewModel: ObservableObject {
    var category: Categories
    @Published var listItems: [Item]?
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let carrouselServiceManager = CarrouselServiceManager()
    @Published var carrouselState: CarrouselState = .loading
    
    @Published var error: Error = getErrors.emptyError
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

class CarrouselServiceManager {
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
                Logger.getErrors.fault("Error: \(error)")
                carrouselState.send(.error(error: getErrors.decodeError,
                                           errorString: " al cargar la informacion \(category.name)",
                                           urlForErrorRetry: "https://api.mercadolibre.com/sites/MLA/search?category=\(category.id)"))
            }
        }
    }
}

struct Carrousel: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CarrouselViewModel
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        switch viewModel.carrouselState {
        case .loading:
            section(isMock: true, listItems: Item.emptyItems)
        case .error:
            section(error: true)
        case .ready:
            section()
        }
    }
    
    @ViewBuilder func section(isMock: Bool = false, error: Bool = false, listItems: [Item]? = []) -> some View {
        VStack(alignment: .leading) {
            if isMock {
                    HStack {
                        Text(viewModel.category.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                            .redacted(reason: .placeholder)
                            .shimmer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                            .redacted(reason: .placeholder)
                            .shimmer()
                    }
                    .font(.headline)
                    .bold()
                    .padding(.bottom)
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(listItems ?? [], id: \.id) { item in
                            ItemView(item: item, isMock: isMock)
                                .disabled(isMock)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else if !isMock && !error {
                Button(action: {
                    navigationViewModel.navigateTo = AnyView(ItemsByCategory(title: viewModel.category.name, listItems: viewModel.listItems))
                    navigationViewModel.navigationIsActive = true
                }) {
                    HStack {
                        Text(viewModel.category.name)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .font(.headline)
                    .bold()
                    .padding(.bottom)
                }
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.listItems ?? [], id: \.id) { item in
                            ItemView(item: item)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else if error {
                HStack {
                    Text(viewModel.category.name)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
                .font(.headline)
                .bold()
                .padding(.bottom)
                ErrorView(error: viewModel.error, errorString: viewModel.errorString) {
                    viewModel.getCarrouselData(category: viewModel.category)
                }
            }
        }
        .padding()
        .background(content: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Material.regular)
        })
        .padding()
    }
}

struct ItemsByCategory: View {
    @State var title: String
    @State var listItems: [Item]?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 2)) {
                ForEach(listItems ?? [], id: \.id) { item in
                    ItemView(item: item)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ItemView: View {
    @State var item: Item
    var isMock: Bool = false
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        if isMock {
                VStack(alignment: .leading) {
                    VStack(alignment: .center) {
                        ProgressView()
                            .tint(.black)
                            .frame(width: 160, height: 100)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.footnote)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.black)
                                .redacted(reason: .placeholder)
                                .shimmer()
                            if item.originalPrice != nil {
                                if (item.originalPrice?.rounded() ?? 0) - (item.originalPrice ?? 0) > 0 {
                                    Text("\(item.currency == .ars ? "$" : "U$D") \(item.originalPrice ?? 0, specifier: "%.2f")")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(height: 1)
                                        }
                                        .redacted(reason: .placeholder)
                                        .shimmer()
                                } else {
                                    Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.originalPrice ?? 0))")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(height: 1)
                                        }
                                        .redacted(reason: .placeholder)
                                        .shimmer()
                                }
                            }
                            if (item.price?.rounded() ?? 0) - (item.price ?? 0) > 0 {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(item.price ?? 0, specifier: "%.2f")")
                                    .foregroundStyle(.black)
                                    .redacted(reason: .placeholder)
                                    .shimmer()
                            } else {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.price ?? 0))")
                                    .foregroundStyle(.black)
                                    .redacted(reason: .placeholder)
                                    .shimmer()
                            }
                            if item.shipping.free_shipping {
                                Text("Envio gratis")
                                    .bold()
                                    .font(.footnote)
                                    .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                                    .redacted(reason: .placeholder)
                                    .shimmer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding()
                .frame(minWidth: 160, minHeight: 220)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                )
                .frame(width: 160, height: 220)
        } else {
            Button(action: {
                navigationViewModel.navigateTo = AnyView(DetailView(item: item))
                navigationViewModel.navigationIsActive = true
            }) {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                ProgressView()
                                    .tint(.black)
                                    .frame(width: 100, height: 100)
                            }
                            Spacer()
                        }
                        Text(item.title)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.black)
                            .frame(height: 35)
                        if item.originalPrice != nil {
                            if (item.originalPrice?.rounded() ?? 0) - (item.originalPrice ?? 0) > 0 {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(item.originalPrice ?? 0, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .overlay {
                                        Rectangle()
                                            .fill(.gray)
                                            .frame(height: 1)
                                    }
                            } else {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.originalPrice ?? 0))")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .overlay {
                                        Rectangle()
                                            .fill(.gray)
                                            .frame(height: 1)
                                    }
                            }
                        }
                        if (item.price?.rounded() ?? 0) - (item.price ?? 0) > 0 {
                            HStack {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(item.price ?? 0, specifier: "%.0f")")
                                    .foregroundStyle(.black)
                                if item.originalPrice != nil {
                                    Text("\(item.percentage)%")
                                        .font(.footnote)
                                        .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                                }
                            }
                        } else {
                            HStack {
                                Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.price ?? 0))")
                                    .foregroundStyle(.black)
                                if item.originalPrice != nil {
                                    Text("\(item.percentage)%")
                                        .font(.footnote)
                                        .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                                }
                            }
                        }
                        if item.shipping.free_shipping {
                            Text("Envio gratis")
                                .bold()
                                .font(.footnote)
                                .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                        }
                        Spacer()
                    }
                    .padding([.horizontal, .top])
                    .frame(minWidth: 160, minHeight: 240)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .frame(width: 160, height: 240)
            }
        }
    }
}

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    var item: Item
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    if item.condition != .notSpecified || item.conditionTraduct != "" {
                        Text(item.conditionTraduct)
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .padding(.bottom, 3)
                    }
                    
                    HStack {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                )
                
                AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Material.regular)
                        )
                } placeholder: {
                    ProgressView()
                        .tint(.black)
                        .frame(height: 300)
                }
                
                VStack(alignment: .leading) {
                    if item.originalPrice != nil {
                        if (item.originalPrice?.rounded() ?? 0) - (item.originalPrice ?? 0) > 0 {
                            Text("\(item.currency == .ars ? "$" : "U$D") \(item.originalPrice ?? 0, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Rectangle()
                                        .fill(.gray)
                                        .frame(height: 1)
                                }
                        } else {
                            Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.originalPrice ?? 0))")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Rectangle()
                                        .fill(.gray)
                                        .frame(height: 1)
                                }
                        }
                    }
                    if (item.price?.rounded() ?? 0) - (item.price ?? 0) > 0 {
                        HStack {
                            Text("\(item.currency == .ars ? "$" : "U$D") \(item.price ?? 0, specifier: "%.0f")")
                                .font(.title)
                                .foregroundStyle(.white)
                            if item.originalPrice != nil {
                                Text("\(item.percentage)%")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                            }
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("\(item.currency == .ars ? "$" : "U$D") \(Int(item.price ?? 0))")
                                .font(.title)
                                .foregroundStyle(.white)
                            if item.originalPrice != nil {
                                Text("\(item.percentage)%")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                            }
                            Spacer()
                        }
                    }
                    if item.shipping.free_shipping {
                        Text("Envio gratis")
                            .bold()
                            .font(.footnote)
                            .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                )
                
                
                HStack {
                    Text("Vendido por \(item.seller?.nickname ?? "")")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                )
                
                VStack(alignment: .leading) {
                    Text("Caracteristicas generales")
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .font(.headline)
                        .bold()
                        .padding()
                    
                    ForEach(item.attributes, id: \.id) { attributes in
                        HStack {
                            Text(attributes.name)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text(attributes.value_name ?? "")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Material.regular)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                )
            }
            .padding(.horizontal)
        }
    }
}
