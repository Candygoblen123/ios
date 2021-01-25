//
//  AuthService.swift
//  ios
//
//  Created by Mason Phillips on 1/11/21.
//

import Foundation
import UIKit.UIViewController
import RxCocoa
import SafariServices
import RxSwift

struct AuthService {
//    private let oauth  : OAuth2Swift
//    private let keychain: Keychain
//
//    var loggedIn: BehaviorRelay<Bool>
//    var oauthToken: String? {
//        return keychain[Keys.token.rawValue]
//    }
//
//    enum Keys: String {
//        case service = "app.livetl.ios"
//
//        case token   = "GOOGLE_USER_OAUTH_TOKEN"
//        case refresh = "GOOGLE_USER_OAUTH_REFRESH"
//    }
//
//    init() {
//        oauth = OAuth2Swift(consumerKey: "626233357823-jtj6utuafd26bej9ut001prqtlndrs8q.apps.googleusercontent.com",
//                            consumerSecret: "RUAHD9ElvhN-IJBTwyetzdhC",
//                            authorizeUrl: "https://accounts.google.com/o/oauth2/auth",
//                            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
//                            responseType: "token")
//        oauth.allowMissingStateCheck = true
//
//
//        keychain = Keychain(service: Keys.service.rawValue)
//
//        let isLoggedIn = (keychain[Keys.token.rawValue] != nil)
//        loggedIn = BehaviorRelay(value: isLoggedIn)
//    }
//
//    @discardableResult
//    func authorize(_ view: UIViewController) -> OAuthSwiftRequestHandle? {
//        oauth.authorizeURLHandler = SafariURLHandler(viewController: view, oauthSwift: oauth)
//
//        return oauth.authorize(withCallbackURL: "https://livetl.syqen.dev/authorize", scope: "https://www.googleapis.com/auth/youtube.readonly", state: "") { result in
//            switch result {
//            case .success(let token):
//                keychain[Keys.token.rawValue] = token.credential.oauthToken
//                keychain[Keys.refresh.rawValue] = token.credential.oauthRefreshToken
//                loggedIn.accept(true)
//
//                print(token.credential.oauthToken)
//
//            case .failure(let error):
//                print(error)
//            }
//        }
//
//        return Single<Void>.create { observer -> Disposable in
//            oauth.authorize(withCallbackURL: "", scope: "", state: "") { [keychain] result in
//                switch result {
//                case .success(let token):
//                    keychain[Keys.token.rawValue] = token.credential.oauthToken
//                    keychain[Keys.refresh.rawValue] = token.credential.oauthRefreshToken
//                    observer(.success(()))
//
//                case .failure(let error):
//                    observer(.failure(error))
//                }
//            }
//
//            return Disposables.create()
//        }
//    }
}
