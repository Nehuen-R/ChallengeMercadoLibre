//
//  Error+extension.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation

enum GetErrors: Error {
    case invalidUrl
    case invalidResponse
    case decodeError
    case emptyError
    case noData
}
