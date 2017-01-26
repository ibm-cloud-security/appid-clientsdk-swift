import Foundation

public protocol OAuthClient {
	var type: String {get}
	var name: String {get}
	var softwareId: String {get}
	var softwareVersion: String {get}
	var deviceId: String {get}
	var devideModel: String {get}
	var deviceOS: String {get}
}
