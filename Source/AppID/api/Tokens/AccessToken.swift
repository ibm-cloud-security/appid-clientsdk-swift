import Foundation

public protocol AccessToken: Token{
	var scope: String {get}
}
