//
//  Lights.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//

import Foundation

/// Light accessory state
public enum LightState {
    /// lights off
    case off
    /// lights blinking
    case blink
    /// lights oscillating
    case oscillate
    /// light on, parameter is the light level
    case on(UInt)
}
