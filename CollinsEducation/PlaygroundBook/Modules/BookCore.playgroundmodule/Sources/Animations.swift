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

/// Choices for the `startAnimation()` command
public enum OtherAnimations: UInt32 {
    /// flash lights
    case flashlights = 0
    /// blink lights
    case blinklights = 1
    /// oscillatelights
    case oscillatelights = 2
    /// spin animation
    case spin = 3
    /// tap animation
    case tap = 4
    /// slowshake  animation
    case slowshake = 5
    /// metronome  animation
    case metronome = 6
    /// standing dance
    case ondulation = 7
    /// spinjump  animation
    case spinjump = 8
    /// spintoposture  animation
    case spintoposture = 9
    /// spiral animation
    case spiral = 10
    /// slalom animation
    case slalom = 11
}


public enum JumpType: UInt32 {
    case long = 0
    case high = 1
    case cancel = 2
    case emergency = 3
    case load = 4
}
