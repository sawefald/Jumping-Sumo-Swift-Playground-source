//
//  DroneViewProxy.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//

import Foundation
import PlaygroundSupport

/// Drone related events listener
protocol DroneViewProxyDroneDelegate: AnyObject {
    func droneViewProxyDidReceiveStatusEvent()
}

/// Motion tracker related events listener
protocol DroneViewProxyMotionTrackerDelegate: AnyObject {
    func droneViewProxyDidReceiveMotionEvent(_ event: MotionEvent)
}

/// Playground page proxy to the drone liveview
class DroneViewProxy {

    /// Commands sent from playground page to contoller
    enum Cmd {
        case getState
        case move(params: MoveParams, duration: Int)
        case stopMoving
        case animate(animation: Animations)
        case jump(jumpType: JumpType)
        case startAnimation(animation: OtherAnimations)
        case stopAnimation
        //case takePicture
        case startMotionTracker

        func marshal() -> PlaygroundValue {
            switch self {
            case .getState:
                return .dictionary(["cmd": .string("getState")])
            case .move(let params, let duration):
                return .dictionary(["cmd": .string("move"),
                                    "params": .array([
                                        .integer(params.longitudinalSpeed),
                                        .integer(params.lateralSpeed)]),
                                    "duration": .integer(Int(duration)) ])
            case .stopMoving:
                return .dictionary(["cmd": .string("stopMoving")])
            case .animate(let animation):
                return .dictionary(["cmd": .string("animate"), "animation": .integer(Int(animation.rawValue))])
            case .jump(let jumpType):
                return .dictionary(["cmd": .string("jump"), "jumpType": .integer(Int(jumpType.rawValue))])
            case .startAnimation(let animation):
                return .dictionary(["cmd": .string("startAnimation"), "animation": .integer(Int(animation.rawValue))])
           case .stopAnimation:
               return .dictionary(["cmd": .string("stopAnimation")])
//            case .takePicture:
//                return .dictionary(["cmd": .string("takePicture")])
            case .startMotionTracker:
                return .dictionary(["cmd": .string("startMotionTracker")])

            }
        }

        init?(value: PlaygroundValue) {
            guard case let .dictionary(dict) = value else { return nil }

            var val: Cmd?
            if let cmdEntry = dict["cmd"], case let .string(cmdStr) = cmdEntry {
                switch cmdStr {
                case "getState":
                    val = .getState
                case "move":
                    if case let .array(params)? = dict["params"], params.count == 2,
                        case let .integer(longitudinalSpeed) = params[0],
                        case let .integer(lateralSpeed) = params[1],
                        case let .integer(duration)? = dict["duration"] {
                        val = .move(params: MoveParams(
                            longitudinalSpeed: longitudinalSpeed, lateralSpeed: lateralSpeed), duration: duration)
                    }
                case "stopMoving":
                    val = .stopMoving
                case "animate":
                    if case let .integer(animationValue)? = dict["animation"],
                       let animation = Animations(rawValue: UInt32(animationValue)) {
                        val = .animate(animation: animation)
                    }
                case "jump":
                    if case let .integer(jumpTypeValue)? = dict["jumpType"],
                       let jumpType = JumpType(rawValue: UInt32(jumpTypeValue)) {
                        val = .jump(jumpType: jumpType)
                    }
                case "stopAnimation":
                    val = .stopAnimation
                case "startAnimation":
                    if case let .integer(animationValue)? = dict["animation"],
                       let animation = OtherAnimations(rawValue: UInt32(animationValue)) {
                        val = .startAnimation(animation: animation)
                    }
                case "startMotionTracker":
                    val = .startMotionTracker
                default:
                    break
                }
            }
            if let val = val {
                self = val
            } else {
                return nil
            }
        }
    }

    /// Events from the live view
    enum Evt {
        /// drone connected/disconnected
        case connected(Bool)
        /// latest command completed
        case cmdCompleted
        /// status update
        case status
        /// motion tracker event
        case motionEvent(event: MotionEvent)

        func marshal() -> PlaygroundValue {
            switch self {
            case let .connected(connected):
                return .dictionary(["evt": .string("connected"),
                                    "state": .boolean(connected)])
            case .cmdCompleted:
                return .dictionary(["evt": .string("cmdCompleted")])
            case .status:
                return .dictionary(["evt": .string("status")])
            case let .motionEvent(motion):
                return .dictionary(["evt": .string("motion"),
                                    "motion": .integer(motion.rawValue)])
            }
        }

        init?(value: PlaygroundValue) {
            guard case let .dictionary(dict) = value else { return nil }

            var val: Evt?
            if let evtEntry = dict["evt"], case let .string(evtStr) = evtEntry {
                switch evtStr {
                case "connected":
                    if let stateEntry = dict["state"],
                        case let .boolean(connected) = stateEntry {
                        val = .connected(connected)
                    }

                case "cmdCompleted":
                    val = .cmdCompleted

                case "status":
                        val = .status

                case "motion":
                    if let motionEventEntry = dict["motion"],
                        case let .integer(motionEventVal) = motionEventEntry,
                        let motionEvent = MotionEvent(rawValue: motionEventVal) {
                        val = .motionEvent(event: motionEvent)
                    }

                default: break
                }
            }

            if let val = val {
                self = val
            } else {
                return nil
            }
        }
    }

    weak var droneDelegate: DroneViewProxyDroneDelegate?
    weak var motionTrackerDelegate: DroneViewProxyMotionTrackerDelegate?

    private var connected = false
    private var done = true

    init() {
        let page = PlaygroundPage.current
        let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
        proxy?.delegate = self
    }

    func waitConnected() {
        done = false
        sendCommand(.getState)
        while !connected || !done {
            receiveEvents()
        }
    }

    func sendCommand(_ cmd: Cmd) {
        (PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy)?.send(cmd.marshal())
    }

    func processEvent(_ event: Evt) {
        switch event {
        case .connected(let connected):
            self.connected = connected
        case .cmdCompleted:
            done = true
        case .status:
            droneDelegate?.droneViewProxyDidReceiveStatusEvent()
        case .motionEvent(let motionEvent):
            motionTrackerDelegate?.droneViewProxyDidReceiveMotionEvent(motionEvent)
        }
    }

    func receiveEvents(wait: Double = 0.1) {
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: wait))
    }

    func waitDone() {
        done = false
        while !done {
            receiveEvents()
        }
    }
    
    func isConnected() -> Bool {
        return connected
    }
}

extension DroneViewProxy: PlaygroundRemoteLiveViewProxyDelegate {

    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    }

    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        if let event = Evt(value: message) {
            processEvent(event)
        }
    }
}
