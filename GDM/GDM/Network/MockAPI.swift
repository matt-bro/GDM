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

            defaults?.lastMetaDataDate = Date()
            database?.saveUsers(jsonResult)

            return Just(jsonResult).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            fatalError("could not load")
        }
    }



}
