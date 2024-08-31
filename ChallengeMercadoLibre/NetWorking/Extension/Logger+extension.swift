//
//  Logger+extension.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let GetErrors = Logger(subsystem: subsystem, category: "API_GET_ERRORS")
}
