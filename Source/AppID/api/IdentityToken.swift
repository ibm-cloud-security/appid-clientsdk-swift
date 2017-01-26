import Foundation

public protocol IdentityToken: Token{
	var name: String {get}
	var email: String {get}
	var gender: String {get}
	var locale: String {get}
	var picture: String {get}
	var identities: Array<Dictionary<String, Any>> {get}
	var oauthClient: OAuthClient {get}
}
