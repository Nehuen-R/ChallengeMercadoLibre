//
//  Shimmer.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

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
