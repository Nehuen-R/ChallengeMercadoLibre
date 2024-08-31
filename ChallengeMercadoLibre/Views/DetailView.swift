//
//  DetailView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.verticalSizeClass) var verticalSize
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ItemViewModel
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.25)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        if viewModel.showCondition() {
                            Text(viewModel.item.conditionTraduct)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                                .padding(.bottom, 3)
                        }
                        
                        HStack {
                            Text(viewModel.item.title)
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
                    
                    if verticalSize == .regular {
                        imageAndPrice
                        
                        attributes
                    } else {
                        LazyVGrid(columns: viewModel.columns) {
                            VStack {
                                imageAndPrice
                                Spacer()
                            }
                            VStack {
                                attributes
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder var imageAndPrice: some View {
        VStack {
            AsyncImage(url: URL(string: viewModel.getImage())) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
                PriceView(style: .detail,
                          hasOriginalPrice: viewModel.hasOriginalPrice(),
                          originalPrice: viewModel.getOriginalPrice(),
                          roundedOriginalPrice: viewModel.numberRounded(number: viewModel.getOriginalPrice()),
                          showDecimalForOriginalPrice: viewModel.showDecimal(numberRounded: viewModel.numberRounded(number: viewModel.getOriginalPrice()), number: viewModel.getOriginalPrice()),
                          price: viewModel.getPrice(),
                          roundedPrice: viewModel.numberRounded(number: viewModel.getPrice()),
                          showDecimalForPrice: viewModel.showDecimal(numberRounded: viewModel.numberRounded(number: viewModel.getPrice()), number: viewModel.getPrice()),
                          currency: viewModel.getCurrency(),
                          percentage: viewModel.getPercentage(),
                          freeShipping: viewModel.hasFreeShipping())
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Material.regular)
            )
            
            HStack {
                Text("Vendido por \(viewModel.getSellerNickname())")
                    .font(.subheadline)
                    .bold()
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Material.regular)
            )
        }
    }
    
    @ViewBuilder var attributes: some View {
        VStack(alignment: .leading) {
            Text("Caracteristicas generales")
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .font(.headline)
                .bold()
                .padding()
            
            ForEach(viewModel.getAttributes(), id: \.id) { attributes in
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.gray.opacity(0.1))
                    HStack {
                        Text(attributes.name)
                            .font(.subheadline)
                            .bold()
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(attributes.value_name ?? "")
                            .font(.subheadline)
                    }
                    .padding()
                }
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
}

#Preview {
    DetailView(viewModel: ItemViewModel(item: Item.emptyItem))
}
