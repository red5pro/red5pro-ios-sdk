import Foundation
import UIKit
import PubNubSDK
import Red5WebRTCKit

class Red5PubNubClientListenerImpl: Red5PubNubClientListener {
    var delegate: Red5ProWebrtcEventDelegate?
    
    init(_ delegate: Red5ProWebrtcEventDelegate) {
        self.delegate = delegate
    }
    
    func onMessageReceived(channel: String, message: Any) {
        print("Received chat message on channel: \(channel)")

        // Convert the message to JSONCodable format
        if let jsonCodableMessage = convertToJSONCodable(message) {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.onChatMessageReceived(channel: channel, message: jsonCodableMessage)
            }
        } else {
            print("Failed to convert message to JSONCodable format")
        }
    }

    func onStatusChanged(status: PubNubConnectionStatus) {
        print("PubNub connection status changed - Connected: \(status.isConnected), Active: \(status.isActive)")
    }

    func onConnected() {
        print("Connected to PubNub chat")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onChatConnected()
        }
    }

    func onDisconnected() {
        print("Disconnected from PubNub chat")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onChatDisconnected()
        }
    }

    func onSendError(channel: String, errorMessage: String) {
        print("Failed to send message to channel \(channel): \(errorMessage)")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onChatSendError(channel: channel, errorMessage: errorMessage)
        }
    }

    func onSendSuccess(channel: String, timetoken: NSNumber) {
        print("Successfully sent message to channel \(channel) with timetoken: \(timetoken)")
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onChatSendSuccess(channel: channel, timetoken: timetoken)
        }
    }

    // Helper method to convert various message types to JSONCodable
    private func convertToJSONCodable(_ message: Any) -> JSONCodable? {
        if let jsonCodable = message as? JSONCodable {
            return jsonCodable
        }

        if let string = message as? String {
            return string
        }

        if let dict = message as? [String: Any] {
            // Convert dictionary to JSONCodable
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                return try JSONDecoder().decode(AnyJSON.self, from: data)
            } catch {
                print("Failed to convert dictionary to JSONCodable: \(error)")
            }
        }

        if let array = message as? [Any] {
            // Convert array to JSONCodable
            do {
                let data = try JSONSerialization.data(withJSONObject: array, options: [])
                return try JSONDecoder().decode(AnyJSON.self, from: data)
            } catch {
                print("Failed to convert array to JSONCodable: \(error)")
            }
        }

        // For other types, try to convert through JSON serialization
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: [])
            return try JSONDecoder().decode(AnyJSON.self, from: data)
        } catch {
            print("Failed to convert message to JSONCodable: \(error)")
            return nil
        }
    }
}

/// Protocol for handling PubNub client events
public protocol Red5PubNubClientListener: AnyObject {
    
    /// Called when a message is received on a subscribed channel
    /// - Parameters:
    ///   - channel: The channel name where the message was received
    ///   - message: The message content as Any (can be String, Dictionary, Array, etc.)
    func onMessageReceived(channel: String, message: Any)
    
    /// Called when connection status changes
    /// - Parameter status: The connection status information
    func onStatusChanged(status: PubNubConnectionStatus)
    
    /// Called when successfully connected to PubNub
    func onConnected()
    
    /// Called when disconnected from PubNub
    func onDisconnected()
    
    /// Called when a message fails to send
    /// - Parameters:
    ///   - channel: The channel where send failed
    ///   - errorMessage: The error message
    func onSendError(channel: String, errorMessage: String)
    
    /// Called when a message is successfully sent
    /// - Parameters:
    ///   - channel: The channel where message was sent
    ///   - timetoken: The timetoken of the sent message
    func onSendSuccess(channel: String, timetoken: NSNumber)
}

/// Connection status information for PubNub
public struct PubNubConnectionStatus {
    let isConnected: Bool
    let isActive: Bool
    
    init(isConnected: Bool, isActive: Bool) {
        self.isConnected = isConnected
        self.isActive = isActive
    }
}
