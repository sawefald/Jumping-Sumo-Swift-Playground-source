//
//  Drone.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//

import Foundation

public class Drone {
    fileprivate let droneViewProxy: DroneViewProxy

    public var assessor: Assessor?

    /// Speed for simple moves. Speed is in % of the drone maximum speed
    public var speed = UInt(50) {
        didSet {
            assessor?.add(action: .speed(speed))
        }
    }

    /// Constructor
    init(droneViewProxy: DroneViewProxy) {
        self.droneViewProxy = droneViewProxy
        self.droneViewProxy.droneDelegate = self
    }

    /// Waits until the drone is connected
    public func waitConnected() {
        print ("calling view proxy wait connected")
        droneViewProxy.waitConnected()
    }

    /// Move in a single direction during the specified time.
    ///
    /// - Parameters:
    ///   - direction: direction to move
    ///   - duration: duration of the move in seconds
    public func move(direction: MoveDirection, duration: Int) {
        doMove(params: MoveParams(direction: direction, speed: speed), duration: duration)
        assessor?.add(action: .move(direction: direction, duration: duration))
    }

    /// Start moving in a single direction and return immediatly
    ///
    /// - Parameters:
    ///   - direction: direction to move
    public func move(direction: MoveDirection) {
        doMove(params: MoveParams(direction: direction, speed: speed), duration: -1)
        assessor?.add(action: .move(direction: direction, duration: -1))
    }

    /// Stop current mouvement.
    public func stopMoving() {
        droneViewProxy.sendCommand(.stopMoving)
        droneViewProxy.waitDone()
    }

    /// Complex move: move in multiple directions for a specific duration
    ///
    /// - Parameters:
    ///   - params: movement description
    ///   - duration: duration of the movement
    public func move(params: MoveParams, duration: UInt) {
        doMove(params: params, duration: Int(duration))
        assessor?.add(action: .complexMove(params, duration: duration))
    }

    /// Send move request to controller
    ///
    /// - Parameters:
    ///   - params: movement description
    ///   - duration: duration of the movement
    private func doMove(params: MoveParams, duration: Int) {
        droneViewProxy.sendCommand(.move(params: params, duration: duration))
        droneViewProxy.waitDone()
    }

    /// Ask the drone to turn on itself
    ///
    /// - Parameters:
    ///   - direction: turn direction
    ///   - angle: angle to turn in degrees (0 to 180 degrees)
    //public func turn(direction: TurnDirection, angle: UInt) {
    //    let absoluteAngle: Int
    //    switch direction {
    //    case .left:
    //        absoluteAngle = -Int(angle)
    //    case .right:
    //        absoluteAngle = Int(angle)
    //    }
    //    assessor?.add(action: .turn(direction: direction, angle: angle))
    //}

    /// Perform an animation
    ///
    /// - Parameter animation: Animations
    public func animate(animation: Animations) {
        droneViewProxy.sendCommand(.animate(animation: animation))
        droneViewProxy.waitDone()
        assessor?.add(action: .animate(animation: animation))
    }
    
    /// Perform a jump
    ///
    /// - Parameter jump: JumpType
    public func jump(jumpType: JumpType) {
        droneViewProxy.sendCommand(.jump(jumpType: jumpType))
        droneViewProxy.waitDone()
        assessor?.add(action: .jump(jumpType: jumpType))
    }

    /// Take a picture
    //public func takePicture() {
    //    droneViewProxy.receiveEvents()
    //    droneViewProxy.sendCommand(.takePicture)
    //    droneViewProxy.waitDone()
    //    assessor?.add(action: .takePicture)
    //}
}

extension Drone: DroneViewProxyDroneDelegate {
    func droneViewProxyDidReceiveStatusEvent() {
    }
}

// Extension that add constructor from a MoveDirection
fileprivate extension MoveParams {
    init(direction: MoveDirection, speed: UInt) {
        switch direction {
        case .forward:
            self.init(longitudinalSpeed: Int(speed))
        case .backward:
            self.init(longitudinalSpeed: -Int(speed))
        case .left:
            self.init(lateralSpeed: -Int(speed))
        case .right:
            self.init(lateralSpeed: Int(speed))
        }
    }
}