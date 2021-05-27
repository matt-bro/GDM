//
//  Response.swift
//  GDM
//
//  Created by Matt on 23.05.21.
//

import Foundation

struct MessageResponse: Codable {
    var message: String
}

struct UserResponse: Decodable {
    var login: String
    var id: Int
    var node_id: String = ""
    var avatar_url: String = ""
    var gravatar_id: String = ""
    var url: String = ""
    var html_url: String = ""
    var followers_url: String = ""
    var following_url: String = ""
    var gists_url: String = ""
    var subscriptions_url: String = ""
    var organizations_url: String = ""
    var repos_url: String = ""
    var events_url: String = ""
    var received_events_url: String = ""
    var type: String = ""
    var site_admin: Bool = false
    var name: String? = ""
    var me: Bool? = false
    var followers: Int? = 0
    var following: Int? = 0
}
/*
{
    "login": "mojombo",
    "id": 1,
    "node_id": "MDQ6VXNlcjE=",
    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/mojombo",
    "html_url": "https://github.com/mojombo",
    "followers_url": "https://api.github.com/users/mojombo/followers",
    "following_url": "https://api.github.com/users/mojombo/following{/other_user}",
    "gists_url": "https://api.github.com/users/mojombo/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/mojombo/subscriptions",
    "organizations_url": "https://api.github.com/users/mojombo/orgs",
    "repos_url": "https://api.github.com/users/mojombo/repos",
    "events_url": "https://api.github.com/users/mojombo/events{/privacy}",
    "received_events_url": "https://api.github.com/users/mojombo/received_events",
    "type": "User",
    "site_admin": false
  }
*/

struct SingleUserResponse {
    var login: String
}
/*
 {
   "login": "matt-bro",
   "id": 18646247,
   "node_id": "MDQ6VXNlcjE4NjQ2MjQ3",
   "avatar_url": "https://avatars.githubusercontent.com/u/18646247?v=4",
   "gravatar_id": "",
   "url": "https://api.github.com/users/matt-bro",
   "html_url": "https://github.com/matt-bro",
   "followers_url": "https://api.github.com/users/matt-bro/followers",
   "following_url": "https://api.github.com/users/matt-bro/following{/other_user}",
   "gists_url": "https://api.github.com/users/matt-bro/gists{/gist_id}",
   "starred_url": "https://api.github.com/users/matt-bro/starred{/owner}{/repo}",
   "subscriptions_url": "https://api.github.com/users/matt-bro/subscriptions",
   "organizations_url": "https://api.github.com/users/matt-bro/orgs",
   "repos_url": "https://api.github.com/users/matt-bro/repos",
   "events_url": "https://api.github.com/users/matt-bro/events{/privacy}",
   "received_events_url": "https://api.github.com/users/matt-bro/received_events",
   "type": "User",
   "site_admin": false,
   "name": "Matthias Brodalka",
   "company": null,
   "blog": "",
   "location": "Frankfurt",
   "email": null,
   "hireable": null,
   "bio": null,
   "twitter_username": null,
   "public_repos": 4,
   "public_gists": 0,
   "followers": 6,
   "following": 9,
   "created_at": "2016-04-24T17:13:12Z",
   "updated_at": "2021-05-26T09:49:41Z"
 }
 */
