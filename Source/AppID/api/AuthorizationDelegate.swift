import Foundation

public protocol AuthorizationDelegate{
	func onAuthorizationFailure(error: AuthorizationError)
	func onAuthorizationCanceled()
	func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken)
}
