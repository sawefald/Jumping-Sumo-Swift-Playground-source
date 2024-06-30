//
//  Animations.swift
//  UserModule
//
//  Created by Sarah Miller on 6/5/24.
//

import Foundation


/// Choices for the `animation()` command
public enum Animations: UInt32 {
    /// stop the animations
    case stop = 0
    /// spin animation
    case spin = 1
    /// tap animation
    case tap = 2
    /// slowshake  animation
    case slowshake = 3
    /// metronome  animation
    case metronome = 4
    /// standing dance
    case ondulation = 5
    /// spinjump  animation
    case spinjump = 6
    /// spintoposture  animation
    case spintoposture = 7
    /// spiral animation
    case spiral = 8
    /// slalom animation
    case slalom = 9
}

public enum JumpType: UInt32 {
    case long = 0
    case high = 1
    case cancel = 2
    case emergency = 3
    case load = 4
}
