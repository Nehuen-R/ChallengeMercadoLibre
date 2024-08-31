//
//  NetWorking.swift
//  ChallengeMercadoLibre
//
//  Created by nehuen roth on 30/08/2024.
//

import Foundation
import OSLog

final class Networking {
    static var shared = Networking()
    
    func apiGet<T: Codable>(with: T.Type, url: String) async throws -> T {
        guard let url = URL(string: url) else {
            Logger.GetErrors.fault("Invalid URL")
            throw GetErrors.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.GetErrors.fault("Invalid Response for \(url)")
            throw GetErrors.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            Logger.GetErrors.fault("Invalid Response: \(httpResponse.statusCode)")
            throw GetErrors.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            Logger.GetErrors.debug("\(url)")
            Logger.GetErrors.fault("dataCorrupted \(context.debugDescription)")
            throw GetErrors.decodeError
        } catch let DecodingError.keyNotFound(key, context) {
            Logger.GetErrors.debug("\(url)")
            Logger.GetErrors.fault("Key '\(key.stringValue)' not found \(context.debugDescription)")
            throw GetErrors.decodeError
        } catch let DecodingError.valueNotFound(value, context) {
            Logger.GetErrors.debug("\(url)")
            Logger.GetErrors.fault("Value '\(value)' not found \(context.debugDescription)")
            throw GetErrors.decodeError
        } catch let DecodingError.typeMismatch(type, context) {
            Logger.GetErrors.fault("Type '\(type)' mismatch: \(context.debugDescription)")
            throw GetErrors.decodeError
        } catch {
            Logger.GetErrors.fault("error: \(error)")
            throw GetErrors.decodeError
        }
        
    }
}
