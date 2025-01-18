//
//  Drone.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//
import Foundation
import PlaygroundSupport

// Global drone view proxy
let droneViewProxy = DroneViewProxy()

// Global drone instance
let drone = Drone(droneViewProxy: droneViewProxy)

// Global motion detector
let motionDetector = MotionDetector(droneViewProxy: droneViewProxy)

/// Speed for simple moves. Speed is in % of the drone maximum speed
public var droneSpeed: UInt {
    get {
        return drone.speed
    }
    set {
        drone.speed = newValue
    }
}

/// Wait until the drone is connected and ready to accept commands
public func waitDroneConnected() {
    drone.waitConnected()
}


/// Move in a single direction during the specified time.
///
/// - Parameters:
///   - direction: direction to move
///   - duration: duration of the move in seconds
public func move(direction: MoveDirection, duration: UInt) {
    drone.move(direction: direction, duration: Int(duration))
}

/// Start moving in a single direction and return immediatly
///
/// - Parameters:
///   - direction: direction to move
public func move(direction: MoveDirection) {
    drone.move(direction: direction)
}

/// Stop current mouvement.
public func stopMoving() {
    drone.stopMoving()
}

/// Complex move: move in multiple directions for a specific duration
///
/// - Parameters:
///   - speed: longitudinal speed in %, positive to move forward, negative to move backward.
///   - turn: lateral speed in %, positive to turn right, negative to turn left.
///   - duration: Move duration in seconds
public func move(speed: Int, turn: Int, duration: UInt) {
    drone.move(params: MoveParams(longitudinalSpeed: speed, lateralSpeed: turn), duration: duration)
}

/// Perform an animation
///
/// - Parameter animation: Animations
public func animate(animation: Animations) {
    drone.animate(animation: animation)
    wait(2)
}

/// Perform a jump
///
/// - Parameter jump: JumpType
public func jump(jumpType: JumpType) {
    drone.jump(jumpType: jumpType)
}

/// Start an animation
///
/// - Parameter animation: OtherAnimations
public func startAnimation(animation: OtherAnimations) {
    drone.startAnimation(animation: animation)
}

/// Stop an animation
///
/// - Parameter animation: OtherAnimations
public func stopAnimation() {
    drone.stopAnimation()
}


/// Take a picture
//public func takePicture() {
//    drone.takePicture()
//}

/// Wait for a fixed duration
///
/// - Parameter seconds: duration to wait, in seconds
public func wait(_ seconds: Int) {
    if seconds > 0 {
        sleep(UInt32(seconds))
    }
}

/// Wait for the next iPad motion event
///
/// - Returns: next motion event
public func waitNextMotionEvent() -> MotionEvent {
    return motionDetector.waitNextMotionEvent()
}

/// Starts collecting action to check assessment
public func startAssessor() {
    drone.assessor = Assessor()
}

/// Check if expected actions have been made
public func checkAssessment(expected expectedActions: [Assessor.Assessment], success: String?) {
    PlaygroundPage.current.assessmentStatus = drone.assessor?.check(expected: expectedActions, success: success)
}

public func isConnected() -> Bool {
    return drone.isConnected()
}
