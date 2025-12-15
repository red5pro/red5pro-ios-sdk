import Foundation
import UIKit
import PubNubSDK
import Red5WebRTCKit

public class Red5PubNubClient {
    
    private var pubnub: PubNub?
    private var client: Red5WebrtcClient?
    private var connected = false
    private var subscriptions: [String: Subscription] = [:]
    private var statusListener: CoreListener?
    private weak var pubnubClientListener: Red5PubNubClientListener?
    
    public init(config: Red5WebrtcClientConfig, webrtcClientListener: Red5ProWebrtcEventDelegate) {
        
        guard isPubnubAvailable() else {
            print("PubNub dependency not found. Please add PubNubSwift to your project")
            fatalError("PubNub dependency not found. Please add PubNubSwift to your project")
        }
        
         guard let publishKey = config.pubnubPublishKey,
               let subscribeKey = config.pubnubSubscribeKey,
               !publishKey.isEmpty,
               !subscribeKey.isEmpty else {
             print("PubNub keys not configured - chat functions will not be available")
             return
         }
        
        client = Red5WebrtcClientBuilder()
            .setPubnubPublishKey(publishKey)
            .setPubnubSubscribeKey(subscribeKey)
            .setLicenseKey(config.licenseKey ?? "")
            .setEventListener(webrtcClientListener)
            .build()
        
        self.pubnubClientListener = Red5PubNubClientListenerImpl(webrtcClientListener)
        
        // Get device identifier (equivalent to Android ID)
        let deviceId = getDeviceIdentifier()
        
        // Create PubNub configuration
        var config = PubNubConfiguration(
            publishKey: publishKey,
            subscribeKey: subscribeKey,
            userId: deviceId
        )
        config.useSecureConnections = true
        
        // Initialize PubNub
        pubnub = PubNub(configuration: config)
        
        // Create and add status listener
        statusListener = CoreListener()
        statusListener?.didReceiveStatus = { [weak self] statusResult in
            switch statusResult {
            case .success(let status):
                self?.handleConnectionStatus(status)
            case .failure(let error):
                self?.handleConnectionError(error)
            }
        }
        
        if let listener = statusListener {
            pubnub?.add(listener)
        }

        print("PubNub client initialized with userId: \(deviceId)")
            
    }
    
    /// Send JSON message to a channel
    /// - Parameters:
    ///   - channelName: Channel to send message to
    ///   - jsonObject: JSON object to send
    ///   - metaData: Optional metadata
    public func sendJsonMessage(channelName: String, jsonObject: JSONCodable, metaData: JSONCodable? = nil) {
        guard let pubnub = pubnub else {
            print("Cannot send JSON message because PubNub client not initialized")
            return
        }
        
        guard connected else {
            print("Cannot send JSON message because PubNub client not connected")
            return
        }
        
        pubnub.publish(
            channel: channelName,
            message: jsonObject,
            customMessageType: "json-message", meta: metaData
        ) { [weak self] result in
            switch result {
            case .success(let response):
                print("Message sent successfully with timetoken: \(response.timetokenDate)")
                self?.pubnubClientListener?.onSendSuccess(
                    channel: channelName,
                    timetoken: NSNumber(value: 1)//value: response.timetokenDate.)
                )
                
            case .failure(let error):
                print("Message send failed: \(error.localizedDescription)")
                self?.pubnubClientListener?.onSendError(
                    channel: channelName,
                    errorMessage: error.localizedDescription
                )
            }
        }
    }
    
    /// Send text message to a channel
    /// - Parameters:
    ///   - channelName: Channel to send message to
    ///   - message: Text message to send
    ///   - metaData: Optional metadata
    public func sendTextMessage(channelName: String, message: String, metaData: JSONCodable? = nil) {
        guard let pubnub = pubnub else {
            print("Cannot send text message because PubNub client not initialized")
            return
        }
        
        guard connected else {
            print("Cannot send text message because PubNub client not connected")
            return
        }
        
        pubnub.publish(
            channel: channelName,
            message: message,
            customMessageType: "text-message", meta: metaData
        ) { [weak self] result in
            switch result {
            case .success(let response):
                print("Message sent successfully with timetoken: \(response.timetokenDate)")
                self?.pubnubClientListener?.onSendSuccess(
                    channel: channelName,
                    timetoken: NSNumber(value: 1)//response.timetoken)
                )
                
            case .failure(let error):
                print("Message send failed: \(error.localizedDescription)")
                self?.pubnubClientListener?.onSendError(
                    channel: channelName,
                    errorMessage: error.localizedDescription
                )
            }
        }
    }
    
    /// Subscribe to a channel
    /// - Parameter channelName: Channel name to subscribe to
    public func subscribeChannel(channelName: String) {
        guard let pubnub = pubnub else {
            print("Cannot subscribe to channel because PubNub client not initialized")
            return
        }
        
        let subscription = pubnub.channel(channelName).subscription(options: ReceivePresenceEvents())
        
        subscription.onMessage = { [weak self] message in
            print("Received message on channel: \(message.channel)")
            self?.pubnubClientListener?.onMessageReceived(
                channel: message.channel,
                message: message.payload
            )
        }
        
        subscriptions[channelName] = subscription
        subscription.subscribe()
        
        print("Subscribed to channel: \(channelName)")
    }
    
    /// Unsubscribe from a channel
    /// - Parameter channelName: Channel name to unsubscribe from
    public func unSubscribeChannel(channelName: String) {
        guard pubnub != nil else {
            print("Cannot unsubscribe from channel because PubNub client not initialized")
            return
        }
        
        if let subscription = subscriptions[channelName] {
            subscription.unsubscribe()
            subscriptions.removeValue(forKey: channelName)
            print("Unsubscribed from channel: \(channelName)")
        } else {
            print("No active subscription found for channel: \(channelName)")
        }
    }
    
    /// Get list of subscribed channels
    /// - Returns: Array of subscribed channel names
    public func getSubscribedChannels() -> [String] {
        guard pubnub != nil else {
            print("PubNub client not initialized")
            return []
        }
        
        return Array(subscriptions.keys)
    }
    
    /// Disconnect from PubNub
    public func disconnect() {
        guard let pubnub = pubnub else {
            print("PubNub client not initialized")
            return
        }
        
        // Unsubscribe from all channels
        for subscription in subscriptions.values {
            subscription.unsubscribe()
        }
        subscriptions.removeAll()
        
        pubnub.disconnect()
        
        connected = false
        print("Disconnected from PubNub")
    }
    
    /// Destroy PubNub client and cleanup resources
    public func destroy() {
        guard pubnub != nil else {
            print("PubNub client not initialized")
            return
        }
        
        disconnect()
        
        pubnub?.removeAllStatusListeners()
        statusListener = nil
        
        pubnub = nil
        pubnubClientListener = nil
        
        print("PubNub client destroyed")
    }
    
    // MARK: - Private Helper Methods
    
    /// Handle connection status changes
    /// - Parameter status: Connection status from PubNub
    private func handleConnectionStatus(_ status: ConnectionStatus) {
        let connectionStatus = PubNubConnectionStatus(
            isConnected: status.isConnected,
            isActive: status.isActive
        )
        
        // Notify listener about status change
        pubnubClientListener?.onStatusChanged(status: connectionStatus)
        
        if (status.isConnected) {
            print("Connected to PubNub")
            connected = true
            pubnubClientListener?.onConnected()
        } else {
            print("Disconnected from PubNub")
            connected = false
            pubnubClientListener?.onDisconnected()
        }
    }
    
    /// Handle connection errors
    /// - Parameter error: Connection error from PubNub
    private func handleConnectionError(_ error: PubNubError) {
        print("PubNub connection error: \(error.localizedDescription)")
        connected = false
        
        let connectionStatus = PubNubConnectionStatus(
            isConnected: false,
            isActive: false
        )
        
        pubnubClientListener?.onStatusChanged(status: connectionStatus)
        pubnubClientListener?.onDisconnected()
    }
    
    /// Check if PubNub SDK is available
    /// - Returns: true if PubNub is available, false otherwise
    private func isPubnubAvailable() -> Bool {
        return true//NSClassFromString("PubNubSDK") != nil
    }
    
    /// Get device identifier (equivalent to Android ID)
    /// - Returns: Device identifier string
    private func getDeviceIdentifier() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        
        // Fallback to a random UUID if identifierForVendor is not available
        return UUID().uuidString
    }
    
}
