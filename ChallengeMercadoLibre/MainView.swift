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
                if viewModel.showSearch(focusSearch: focusSearch) {
                    searchState
                } else {
                    mainState
                }
            }
            .navigationDestination(isPresented: $navigationViewModel.navigationIsActive,
                                   destination: { navigationViewModel.navigateTo })
            .navigationTitle(viewModel.navigationTitle(focusSearch: focusSearch))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, content: { searchBar })
            .onAppear(perform: {
                focusSearch = false
            })
            .onSubmit {
                focusSearch = false
                viewModel.search()
            }
            .submitLabel(.search)
            .onChange(of: viewModel.searched, { oldValue, newValue in
                if newValue {
                    focusSearch = false
                    viewModel.search()
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
        switch viewModel.searchState {
        case .loading:
            if viewModel.isSearching {
                    ForEach(viewModel.searchedDataSave, id: \.self) { item in
                        Button(action: {
                            focusSearch = false
                            viewModel.setSearchString(text: item)
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
                if viewModel.searchIsStored() && focusSearch {
                    ForEach(viewModel.searchStored, id: \.self) { item in
                        Button(action: {
                            focusSearch = false
                            viewModel.setSearchString(text: item)
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
                Text(viewModel.emptyText())
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
                                    focusSearch = true
                                    viewModel.resetSearch()
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                }
                                .foregroundColor(.secondary)
                                .padding(.trailing, 4)
                        }
                    }
                }
            if focusSearch || viewModel.showCancelButton() {
                Button(action:{
                    focusSearch = false
                    viewModel.resetSearch()
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
