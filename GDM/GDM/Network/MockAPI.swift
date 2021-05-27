//
//  MockAPI.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation
import Combine

class MockAPI: API {

    override func followers(for userHandle: String, _ database: DatabaseSavable?, _ defaults: UserDefaults?, _ force: Bool) -> AnyPublisher<[UserResponse], Error> {
        let  jsonPath = Bundle.main.path(forResource: "followers", ofType: "json")

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
            let jsonResult = try decoder.decode([UserResponse].self, from: data)

            return Just(jsonResult)
                .delay(for: 3.0, scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                //.tryMap({ _ in throw ServiceError.rateLimit })
                .handleEvents(receiveSubscription: {_ in}, receiveOutput: {_ in }, receiveCompletion: { _ in
                    defaults?.lastMetaDataDate = Date()
                    database?.saveUsers(jsonResult)
                }).eraseToAnyPublisher()
        } catch {
            fatalError("could not load")
        }
    }

    override func userDetail(for userHandle: String, _ database: DatabaseSavable? = nil, _ defaults: UserDefaults? = nil, _ session: AppSession? = nil) -> AnyPublisher<UserResponse, Error> {
        let  jsonPath = Bundle.main.path(forResource: "user", ofType: "json")

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath!), options: .mappedIfSafe)
            let jsonResult = try decoder.decode(UserResponse.self, from: data)

            return Just(jsonResult)
                .delay(for: 1.0, scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                .handleEvents(receiveSubscription: {_ in}, receiveOutput: {_ in }, receiveCompletion: { _ in
                    defaults?.lastMetaDataDate = Date()
                }).eraseToAnyPublisher()
        } catch {
            fatalError("could not load")
        }
    }

}
