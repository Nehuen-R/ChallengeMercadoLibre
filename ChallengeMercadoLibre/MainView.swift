//
//  MainView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 26/08/2024.
//

import SwiftUI

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
                        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 170), spacing: 5), count: 2)) {
                            ForEach(viewModel.searchData.results ?? [], id: \.id) { item in
                                ItemView(viewModel: ItemViewModel(item: item))
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
                                CarrouselView(viewModel: CarrouselViewModel(category: category))
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
                    .fill(.gray.opacity(0.25))
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    MainView()
}
