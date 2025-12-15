//
//  Red5WebRTCKitWrapper.swift
//  
//  Wrapper module that re-exports Red5WebRTCKit with its dependencies
//

// Re-export the binary framework (the XCFramework's module is named Red5WebRTCKit)
@_exported import Red5WebRTCKit

// Import dependencies to ensure they're linked
import WebRTC

// Note: The @_exported import makes all types from Red5WebRTCKit XCFramework
// available to consumers who import Red5WebRTCKitWrapper, while also ensuring
// that WebRTC are properly linked.
