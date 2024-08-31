//
//  ErrorView.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import SwiftUI

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

#Preview {
    ErrorView(error: GetErrors.decodeError) {}
}
