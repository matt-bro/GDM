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
    let receivedMessagePublisher = PassthroughSubject<String, Never>()
    @Published var receivedDate: Date?

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
                //print($0)
                database?.saveUsers($0)
                defaults?.lastMetaDataDate = Date()
            })
            .eraseToAnyPublisher()
    }

    func send(message: String, toId: Int, date:Date = Date(), _ database: DatabaseSavable? = nil) -> AnyPublisher<String, Error> {
        //self.receivedMessagePublisher.send(self.randomString(length: 5))
        return Just("")
            //.delay(for: 2, scheduler: RunLoop.main)
            .handleEvents(receiveSubscription: { _ in
                database?.saveMessage(message: message, fromId: AppSession.shared.currentUserId, toId: toId, date: date)
                self.receivedMessagePublisher.send(message)
                self.receivedDate = Date()
            }).flatMap({ _ in
                self.receivedMessage(message, toId: toId, date: date, database)
            }).map({ $0.message }).eraseToAnyPublisher()
    }

    func receivedMessage(_ message: String = "",  toId: Int, date:Date = Date(), _ database: DatabaseSavable? = nil) -> AnyPublisher<MessageResponse, Error> {
        return Just(self.dummyReplyJSONString(message: message))
            .compactMap({$0.data(using: .utf8)})
            .delay(for: 3, scheduler: RunLoop.main)
            .decode(type: MessageResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveSubscription: {
                _ in
            }).map({
                Database.shared.saveMessage(message: $0.message, fromId:toId , toId: AppSession.shared.currentUserId, date: Date())
                return $0
            })
            .eraseToAnyPublisher()
        //return self.receivedMessagePublisher.eraseToAnyPublisher()
    }

    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func dummyReplyJSONString(message: String = "") -> String {

    //    let m = MessageResponse.init(message: "\(message) \(message)")

        #warning("fix, might break with special chars")
        return """
        {
            "message": "\(message) \(message)"
        }
        """


    }
}
