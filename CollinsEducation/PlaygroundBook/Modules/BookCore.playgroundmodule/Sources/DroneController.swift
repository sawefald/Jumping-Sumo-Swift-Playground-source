//
//  DroneController.swift
//  UserModule
//
//  Created by Sarah Miller on 6/5/24.
//

import Foundation

protocol DroneControllerDelegate: AnyObject {
    func opTerminated(error: DroneController.OpError?)
    func droneControllerDidFindDrone(droneModel: String)
    func droneControllerDidStop()
    func droneFirmwareOutOfDate()
    func droneControllerConnectionStateDidChange(_ connectionState: DroneController.ConnectionState)
    func droneControllerStateDidChange()
}

class DroneController {
    
    public enum ConnectionState {
        case searching, searchingAgain, connecting, connected, disconnected
    }
    
    public enum BatteryLevel {
        case unknown, level(percent: Int, low: Bool)
    }
    
    public enum OpError {
        /// battery level to low to perform a jump
        case jumpLowBat
    }
    
    /// range to bound angle
    private let angleRange = -180...180
    /// range to bound commnands in %
    private let percentRange = 0...100
    /// range to bound commands in +/- %
    private let signedPercentRange = -100...100
    
    /// WiFi instance
    public var wifi: DroneWiFi!
    
    /// Queue running drone protocol and ble
    fileprivate let protocolQueue = DispatchQueue(label:"DroneProtocol")
    /// Protocol instance
    fileprivate var droneProtocol: DroneProtocol?
    
    /// Delegate
    weak var delegate: DroneControllerDelegate?
    
    fileprivate (set) var droneModel: String? {
        didSet {
            if let droneModel = droneModel {
                delegate?.droneControllerDidFindDrone(droneModel: droneModel)
            }
        }
    }
    /// Current operation. Set while waiting for operation completion event
    fileprivate (set) var currentOp: Operation? {
        didSet {
            delegate?.droneControllerStateDidChange()
        }
    }
    
    /// connection state
    fileprivate (set) var connectionState = ConnectionState.disconnected {
        didSet {
            delegate?.droneControllerConnectionStateDidChange(connectionState)
        }
    }
    
    /// battery level
    fileprivate (set) var batteryLevel = BatteryLevel.unknown {
        didSet {
            delegate?.droneControllerStateDidChange()
        }
    }
    
    /// Operations
    public enum Operation {
        case move(params: MoveParams, duration: Int)
        case stopMoving
        case animate(animation: Animations)
        case startAnimation(animation: OtherAnimations)
        case stopAnimation
        case jump(jumpType: JumpType)
        case emergency
        case cancel
        case load
    }
    
    init() {
        wifi = DroneWiFi(hostName: "192.168.2.1", portName: 44444, queue: protocolQueue, delegate: self)
    }
    
    public func execute(op: Operation) {
        currentOp = op
        switch op {
            
            // move, complete after duration
        case .move(let params, let duration):
            droneProtocol?.pcmd((
                speed: Int8(params.longitudinalSpeed.clamped(into: signedPercentRange)),
                turn: Int8(params.lateralSpeed.clamped(into: signedPercentRange))),
                                duration: duration)
            
            // stop moving, complete after duration stop duration
        case .stopMoving:
            droneProtocol?.clearPcmd()
        
        case .animate(let animation):
            droneProtocol?.animate(animation: animation.rawValue)
            
        case .jump(let jumpType):
            droneProtocol?.jump(jumpType: jumpType.rawValue)
            
        case .stopAnimation:
            droneProtocol?.stopAnimation()
        
        case .startAnimation(let animation):
            droneProtocol?.startAnimation(animation: animation.rawValue)

        case .emergency:
            droneProtocol?.emergency()
        
        case .cancel:
            droneProtocol?.cancel()
        
        case .load:
            droneProtocol?.load()
        }
    }

    fileprivate func currentOpTerminated(error: OpError? = nil) {
        currentOp = nil
        delegate?.opTerminated(error: error)
    }
    
    public func start() {
        if self.connectionState == .disconnected {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                if (self.connectionState == .searching)
                {
                    self.connectionState = .searchingAgain
                    self.wifi.start()
                    sleep(1)
                    self.wifi.send(line: "{ \"qos_mode\": 1, \"d2c_port\": 43210, \"arstream2_client_stream_port\": 55004, \"arstream2_client_control_port\": 55005, \"arstream2_supported_metadata_version\": 1, \"controller_name\": \"DEFAULT_SDK_CONTROLLER\", \"controller_type\": \"DEFAULT_SDK_TYPE\" }")
                    self.wifi.startReceive()
                }
            }
            self.connectionState = .searching
        }
    }
    
    public func disconnect() {
        self.wifi.cancel()
        self.connectionState = .disconnected
    }
}
    
/// DroneWiFiDelegate implementation. All func are called in the protocol queue
extension DroneController: DroneWiFiDelegate {
    
    func droneWifiDidConnect() {
        // WiFi Delegate Did connect
        connectionState = .connecting
        DispatchQueue.main.sync {
            droneProtocol = DroneProtocol(droneWiFi: wifi, queue: protocolQueue, delegate: self)
        }
        // connect protocol after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak droneProtocol] in
            droneProtocol?.connect()
        }
    }
        
    func droneWifiDidDisconnect() {
        droneProtocol = nil
        batteryLevel = .unknown
        connectionState = .disconnected
        DispatchQueue.main.async {
            self.delegate?.droneControllerDidStop()
        }
    }
}
    
/// DroneProtocolDelegate implementation. All func are called in the protocol queue
extension DroneController: DroneProtocolDelegate {
    
    func protocolDidConnect() {
        connectionState = .connected
    }
    
    func protocolDidDisconnect() {
        connectionState = .disconnected
    }
    
    func firmwareOutOfDate() {
        delegate?.droneFirmwareOutOfDate()
    }
    
    func pcmdTerminated() {
        if let currentOp = currentOp {
            switch currentOp {
            case .move: fallthrough
            case .animate: fallthrough
            case .jump: fallthrough
            case .startAnimation: fallthrough
            case .stopAnimation: fallthrough
            case .emergency: fallthrough
            case .cancel: fallthrough
            case .load: fallthrough
            case .stopMoving:
                currentOpTerminated()
            }
        }
    }
    
    func droneConnecting(name: String) {
        droneModel = name
    }
    
    func batteryLevelDidChange(_ percent: Int?, low: Bool) {
        if let percent = percent {
            batteryLevel = .level(percent: percent, low: low)
        } else {
            batteryLevel = .unknown
        }
        
        if let currentOp = currentOp {
            switch currentOp {
                case .jump:
                    currentOpTerminated(error: OpError.jumpLowBat)
                default:
                    break
            }
        }
    }
}
    
extension Int {
    func clamped(into range: CountableClosedRange<Int>) -> Int {
        return self < range.lowerBound ? range.lowerBound :
        self > range.upperBound ? range.upperBound :
        self
    }
}
