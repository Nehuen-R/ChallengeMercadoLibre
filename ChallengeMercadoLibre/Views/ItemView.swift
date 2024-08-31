//
//  ItemView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

struct ItemView: View {
    @StateObject var viewModel: ItemViewModel
    @StateObject var navigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        if viewModel.isMock {
            mockView
        } else {
            readyView
        }
    }
    
    @ViewBuilder var mockView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                ProgressView()
                    .tint(.black)
                    .frame(width: 175, height: 100)
            }
            Text(viewModel.getTitle())
                .styleText(font: .caption, color: .black, lineLimit: 2)
                .multilineTextAlignment(.leading)
                .frame(height: 35)
                .redacted(reason: .placeholder)
                .padding(.horizontal)
                .shimmer()
            HStack {
                PriceView(style: .item,
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
                .redacted(reason: .placeholder)
                .shimmer()
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .frame(minWidth: 175, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
        )
        .frame(width: 175, height: 220)
    }
    
    @ViewBuilder var readyView: some View {
        Button(action: {
            navigationViewModel.navigateTo = AnyView(DetailView(viewModel: viewModel))
            navigationViewModel.navigationIsActive = true
        }) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: viewModel.getImage())) { image in
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
                    Text(viewModel.getTitle())
                        .styleText(font: .caption, color: .black, lineLimit: 2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 35, alignment: .topLeading)
                    PriceView(style: .item,
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
                .padding([.horizontal, .top])
                .frame(minWidth: 175, minHeight: 240)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                )
                .frame(width: 175, height: 240)
        }
    }
}

#Preview {
    ItemView(viewModel: ItemViewModel(item: Item.emptyItem))
}
