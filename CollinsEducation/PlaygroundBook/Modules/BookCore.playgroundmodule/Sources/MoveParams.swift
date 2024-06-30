//
//  MoveParameters.swift
//  UserModule
//
//  Created by Sarah Miller on 6/5/24.
//

import Foundation

/// Defines the speed at which the drone must move and turn
public struct MoveParams: Equatable {
    /// Speed on the drone longitudinal direction, in %. Positive values make the drone move forward,
    /// negative values make the drone move backward
    public let longitudinalSpeed: Int
    /// Speed on the drone lateral direction, in %. Positive values make the drone move right,
    /// negative values make the drone move left
    public let lateralSpeed: Int
    
    /// Create a `MoveParams` instance
    ///
    /// - Parameters:
    ///   - longitudinalSpeed: Speed on the drone longitudinal direction, in %.
    ///      Positive values makes the drone move forward, negative values make the drone move backward
    ///   - lateralSpeed: Speed on the drone lateral direction, in %. Positive value make the drone move right,
    ///      negative values make the drone move left
    public init(longitudinalSpeed: Int=0, lateralSpeed: Int=0) {
        self.longitudinalSpeed = longitudinalSpeed
        self.lateralSpeed = lateralSpeed
    }
}

/// Comparato
public func == (lhs: MoveParams, rhs: MoveParams) -> Bool {
    return lhs.longitudinalSpeed == rhs.longitudinalSpeed &&
    lhs.lateralSpeed == rhs.lateralSpeed
}
