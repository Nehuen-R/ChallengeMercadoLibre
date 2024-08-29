//
//  MainView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 26/08/2024.
//

import SwiftUI
import Combine

struct Categories: Codable {
    let id: String
    let name: String
}

struct ListItems: Codable {
    let results: [Item]?
}
        
struct Item: Codable {
    let id: String
    let title: String
    let seller: Seller?
    let condition: Condition
    let thumbnail: String?
    let price: Double?
    let originalPrice: Double?
    let currency_id: Currency
    let available_quantity: Int
    let shipping: Shipping
    let attributes: [Attributes]
    
    var conditionTraduct: String {
        switch condition {
        case .new:
            return "Nuevo"
        case .used:
            return "Usado"
        }
    }
}

enum Currency: String, Codable {
    case ars = "ARS"
    case usd = "USD"
}

enum Condition: String, Codable {
    case new = "new"
    case used = "used"
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
            (.error, .error),
            (.ready, .ready):
            return true
        default:
            return false
        }
    }
    
    case loading, error
    case ready(data: [Categories])
}

enum SearchState: Equatable {
    static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.error, .error),
            (.ready, .ready):
            return true
        default:
            return false
        }
    }
    
    case loading, error
    case ready(data: ListItems)
}

class Networking {
    static var shared = Networking()
    
    func apiGet<T: Codable>(with: T.Type, url: String) async throws -> T {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data)
    }
}

class NavigationViewModel: ObservableObject {
    static let shared = NavigationViewModel()
    
    @Published var navigateTo: AnyView = AnyView(EmptyView())
    @Published var navigationIsActive: Bool = false
}

class MainServiceManager {
    private (set) var mainState = CurrentValueSubject<MainState, Never>(.loading)
    
    func processData(data: [Categories]) {
        mainState.send(.ready(data: data))
    }
    
    func getCategories() {
        Task {
            do {
                let categories = try await Networking.shared.apiGet(with: [Categories].self, url: "https://api.mercadolibre.com/sites/MLA/categories")
                processData(data: categories)
            } catch {
                mainState.send(.error)
            }
        }
    }
}

class SearchServiceManager {
    private (set) var searchState = CurrentValueSubject<SearchState, Never>(.loading)
    
    func processData(data: ListItems) {
        searchState.send(.ready(data: data))
    }
    
    func getSearchedData(searchText: String) {
        Task {
            do {
                let searchTextSpaced = searchText.replacingOccurrences(of: " ", with: "%20")
                let listItems = try await Networking.shared.apiGet(with: ListItems.self, url: "https://api.mercadolibre.com/sites/MLA/search?q=\(searchTextSpaced)")
                processData(data: listItems)
            } catch {
                searchState.send(.error)
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
                case .error:
                    break
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
                case .loading:
                    break
                case .error:
                    break
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
                            } else {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("Searching...")
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                        
                    case .error:
                        VStack {
                            Spacer()
                            Text("error...")
                            Spacer()
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
                            Spacer()
                            Text("loading...")
                            Spacer()
                        }
                    case .error:
                        VStack {
                            Spacer()
                            Text("error...")
                            Spacer()
                        }
                    case .ready:
                        LazyVStack {
                            ForEach(viewModel.categories, id: \.id) { category in
                                Carrousel(category: category)
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
                        .ignoresSafeArea(edges: .top)
                )
            })
            .onAppear(perform: {
                focusSearch = false
            })
            .onSubmit {
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
            .scrollDismissesKeyboard(.immediately)
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

struct Carrousel: View {
    @Environment(\.colorScheme) var colorScheme
    @State var category: Categories
    @State private var listItems: ListItems = .init(results: [])
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                navigationViewModel.navigateTo = AnyView(ItemsByCategory(title: category.name, listItems: listItems))
                navigationViewModel.navigationIsActive = true
            }) {
                HStack {
                    Text(category.name)
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
                    ForEach(listItems.results ?? [], id: \.id) { item in
                        ItemView(item: item)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
        .background(content: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Material.regular)
        })
        .padding()
        .onAppear {
            Task {
                listItems = await apiGet(with: ListItems.self, url: "https://api.mercadolibre.com/sites/MLA/search?category=\(category.id)")
            }
        }
    }
    
    func apiGet<T: Codable>(with: T.Type, url: String) async -> T {
        let url = URL(string: url)!
        let (data, _) = try! await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data)
    }
}

struct ItemsByCategory: View {
    @State var title: String
    @State var listItems: ListItems
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 2)) {
                ForEach(listItems.results ?? [], id: \.id) { item in
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
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        Button(action: {
            navigationViewModel.navigateTo = AnyView(DetailView(item: item))
            navigationViewModel.navigationIsActive = true
        }) {
            VStack {
                VStack {
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
                    VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.footnote)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.black)
                        if item.originalPrice != nil {
                                if (item.originalPrice?.rounded() ?? 0) - (item.originalPrice ?? 0) > 0 {
                                    Text("\(item.currency_id == .ars ? "$" : "U$D") \(item.originalPrice ?? 0, specifier: "%.2f")")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(height: 1)
                                        }
                                } else {
                                    Text("\(item.currency_id == .ars ? "$" : "U$D") \(Int(item.originalPrice ?? 0))")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(height: 1)
                                        }
                                }
                        }
                        if (item.price?.rounded() ?? 0) - (item.price ?? 0) > 0 {
                            Text("\(item.currency_id == .ars ? "$" : "U$D") \(item.price ?? 0, specifier: "%.2f")")
                                .foregroundStyle(.black)
                        } else {
                            Text("\(item.currency_id == .ars ? "$" : "U$D") \(Int(item.price ?? 0))")
                                .foregroundStyle(.black)
                        }
                        if item.shipping.free_shipping {
                            Text("Envio gratis")
                                .bold()
                                .font(.footnote)
                                .foregroundStyle(Color(uiColor: UIColor(red: 0.1, green: 0.8, blue: 0.4, alpha: 1)))
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(minWidth: 160, minHeight: 220)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
            )
            .frame(width: 160, height: 220)
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
                    Text(item.conditionTraduct)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 3)
                    
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
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.regular)
                )
            }
            .padding(.horizontal)
        }
    }
}
