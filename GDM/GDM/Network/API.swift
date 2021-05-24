//
//  API.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation
import Combine

protocol APIProtocol {
    func followers(for userHandle: String, _ database: DatabaseSavable?, _ defaults: UserDefaults?, _ force: Bool) -> AnyPublisher<[UserResponse], Error>
}

// We handle any network errors with this enum
enum ServiceError: Error, Equatable {
    case url(URLError)
    case urlRequest
    case decode
    case statusCode
    case tooEarly
    case rateLimit
}

class API: APIProtocol {

    /// Endpoint for our service
    /// Get the urls for our endpoint
    enum Endpoint {
        private static let baseUrl = URL(string: "https://api.github.com")!
        //access key
        private static let accessKey = "6c16635ecdf56ac38045dded167ee369"

        case users
        case followers(user: String)

        var url: URL {
            switch self {
            case .users:
                return Endpoint.baseUrl
            case .followers(let user):
                return Endpoint.baseUrl.appendingPathComponent("users").appendingPathComponent(user).appendingPathComponent("followers")
            }
        }
    }

    static let shared = API()
    let networkActivityPublisher = PassthroughSubject<Bool, Never>()

    /// Get a list of quotes from the live service
    ///
    /// - Parameters:
    ///     - database: if provided saves quotes directly to database
    ///     - defaults: if provided saves last update date to defaults
    ///     - force: usually a request can only be performed every 30 min, we can ignore it by force true
    /// - Returns:
    ///     - Decoded quotes or an error

    func followers(for userHandle: String, _ database: DatabaseSavable? = nil, _ defaults: UserDefaults? = nil, _ force: Bool = true) -> AnyPublisher<[UserResponse], Error> {

        //check if we are allowed to query
        //this allows us to limit the time for requests
        if let shouldUpdate = defaults?.shouldUpdateMetaData(), shouldUpdate == false, force == false {
            return Fail(error: ServiceError.tooEarly).eraseToAnyPublisher()
        }

        let url = Endpoint.followers(user: userHandle).url

        //special encoding for timestamp
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return URLSession.shared.dataTaskPublisher(for: url)
            //wait for 2 secs on purpose just so we see the loading screen
            .delay(for: 2, scheduler: RunLoop.main)
            //inform about network activity
            .handleEvents(receiveSubscription: { _ in
                self.networkActivityPublisher.send(true)
                        }, receiveCompletion: { _ in
                            self.networkActivityPublisher.send(false)
                        }, receiveCancel: {
                            self.networkActivityPublisher.send(false)
                        })
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw ServiceError.statusCode
                }
                return output.data
            }
            .decode(type: [UserResponse].self, decoder: decoder)
            .handleEvents(receiveOutput: {
                print($0)
                database?.saveUsers($0)
                defaults?.lastMetaDataDate = Date()
            })
            .eraseToAnyPublisher()
    }
}
