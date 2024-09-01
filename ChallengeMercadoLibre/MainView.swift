//
//  MainView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 26/08/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var searchViewModel = SearchViewModel()
    @StateObject var navigationViewModel = NavigationViewModel.shared
    @FocusState var focusSearch: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if searchViewModel.showSearch(focusSearch: focusSearch) {
                    searchState
                } else {
                    mainState
                }
            }
            .navigationDestination(isPresented: $navigationViewModel.navigationIsActive,
                                   destination: { navigationViewModel.navigateTo })
            .navigationTitle(searchViewModel.navigationTitle(focusSearch: focusSearch))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, content: { searchBar })
            .onAppear(perform: {
                focusSearch = false
            })
            .onSubmit {
                focusSearch = false
                searchViewModel.search()
            }
            .submitLabel(.search)
            .onChange(of: searchViewModel.searched, { oldValue, newValue in
                if newValue {
                    focusSearch = false
                    searchViewModel.search()
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
    
    @ViewBuilder var searchState: some View {
        switch searchViewModel.searchState {
        case .loading:
            if searchViewModel.isSearching {
                    ForEach(searchViewModel.searchedDataSave, id: \.self) { item in
                        Button(action: {
                            focusSearch = false
                            searchViewModel.setSearchString(text: item)
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
            } else if !searchViewModel.isSearching {
                if searchViewModel.searchIsStored() && focusSearch {
                    ForEach(searchViewModel.searchStored, id: \.self) { item in
                        Button(action: {
                            focusSearch = false
                            searchViewModel.setSearchString(text: item)
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
                } else if searchViewModel.searched {
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
                Text(searchViewModel.emptyText())
            }
            .padding()
        case .error:
            ErrorView(error: viewModel.error) {
                searchViewModel.getItemsBySearchText(searchText: viewModel.urlErrorForRetry)
            }
        case .ready:
            LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 170), spacing: 5), count: 2)) {
                ForEach(searchViewModel.searchData.results ?? [], id: \.id) { item in
                    ItemView(viewModel: ItemViewModel(item: item))
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder var mainState: some View {
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
    
    @ViewBuilder var searchBar: some View {
        HStack {
            TextField("Search", text: $searchViewModel.searchText, prompt: Text("Search..."))
                .focused($focusSearch)
                .onLongPressGesture(minimumDuration: 0.0) {
                    focusSearch = true
                }
                .autocorrectionDisabled()
                .overlay {
                        HStack {
                            if !searchViewModel.isSearching {
                                Spacer()
                                Button {
                                    focusSearch = true
                                    searchViewModel.resetSearch()
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                }
                                .foregroundColor(.secondary)
                                .padding(.trailing, 4)
                        }
                    }
                }
            if focusSearch || searchViewModel.showCancelButton() {
                Button(action:{
                    focusSearch = false
                    searchViewModel.resetSearch()
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
    }
}

#Preview {
    MainView()
}
