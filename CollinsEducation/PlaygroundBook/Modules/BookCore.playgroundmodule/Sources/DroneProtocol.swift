//
//  DroneProtocol.swift
//  UserModule
//
//  Created by Sarah Miller on 6/5/24.
//

import Foundation


/// Delegate. All function are called in the DroneProtocol dispatch queue
protocol DroneProtocolDelegate: AnyObject {
    func protocolDidConnect()
    func protocolDidDisconnect()
    func firmwareOutOfDate()
    func pcmdTerminated()
    func droneConnecting(name: String)
    func batteryLevelDidChange(_ percent: Int?, low: Bool)
}

class DroneProtocol {
    
    /// Delegate
    private weak var delegate: DroneProtocolDelegate?
    /// Ble instance
    private let droneWiFi: DroneWiFi
    /// Queue running drone protocol
    private let dispatchQueue: DispatchQueue
    /// Channel for ACK'ed commands
    private var commandChannel: CommandChannel!
    /// Channel for non ack commands
    private var controlChannel: ControlChannel!
    /// Channel receiving ACK'ed events
    private var eventChannel: EventChannel!
    /// Channel receiving non ack events
    private var eventChannelNoAck: EventChannel!
    /// Timer to send pcmd
    private var pcmdTimer: DispatchSourceTimer?
    /// pcmd value
    private var pcmd = (speed:Int8(0), turn:Int8(0))
    /// countdonw numer of pcmd to send before reseting it to 0
    private var pcmdCnt = 0
    /// true if lowBattery alert has been received
    private var lowBattery = false
    /// current battery level, nil if not received
    private var batteryLevel: Int?
    /// True when protocol is connected
    private var connected = false
    
    // delay before completing pcmd with duration. This is to let the drone stop before continuing
    private static let pcmdStopDelay = 5
    
    // Min version required
    private static let sumoMinVersion = (2, 1, 77)
    
    /// Cosntructor
    ///
    /// - Parameters:
    ///   - droneBle: ble transport instance
    ///   - queue: queue to run protocol. Delegate func are called in this queue
    ///   - delegate: delegate
    init(droneWiFi: DroneWiFi, queue: DispatchQueue, delegate: DroneProtocolDelegate) {
        self.delegate = delegate
        self.dispatchQueue = queue
        self.droneWiFi = droneWiFi
        self.commandChannel = CommandChannel(sender: droneWiFi.senders[.cmdAck]!, ack: droneWiFi.receivers[.cmdAck]!)
        self.controlChannel = ControlChannel(sender: droneWiFi.senders[.cmdNoAck]!)
        self.eventChannel = EventChannel(
            receiver: droneWiFi.receivers[.evtAck]!, ack: droneWiFi.senders[.evtAck]!) { [unowned self] event in
                self.didReceiveEvent(event)
            }
        self.eventChannelNoAck = EventChannel(
            receiver: droneWiFi.receivers[.evtNoAck]!, ack: nil) { [unowned self] event in
                self.didReceiveEvent(event)
            }
    }
    
    deinit {
        pcmdTimer = nil
    }
    
    /// Connect the protocol
    func connect() {
        dispatchQueue.sync {
            pcmd = (speed: 0, turn: 0)
            lowBattery = false
            batteryLevel = nil
            // execute basic connection steps
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            let now = Date()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            commandChannel.send(command: .setDate(dateFormatter.string(from: now)))
            dateFormatter.dateFormat = "'T'HHmmssZZZ"
            commandChannel.send(command: .setTime(dateFormatter.string(from: now)))
            // get all settings to start connection
            commandChannel.send(command: .getAllSettings)
            // get all states
            commandChannel.send(command: .getAllStates)
        }
    }
    
    /// Set the pcmd value to send
    ///
    /// - Parameters:
    ///   - pcmd: pcmd value
    ///   - duration: duration, in seconds. pcmd is cleared and delegate pcmdTerminated after this duration
    func pcmd(_ pcmd: (speed: Int8, turn: Int8), duration: Int) {
        dispatchQueue.sync {
            if duration >= 0 {
                self.pcmdCnt = duration * 10 + DroneProtocol.pcmdStopDelay
            } else {
                self.pcmdCnt = -1
                self.dispatchQueue.async {
                    self.delegate?.pcmdTerminated()
                }
            }
            self.pcmd = pcmd
        }
    }
    
    /// Clear current pcmd. delegate pcmdTerminated is called after pcmdStopDelay
    func clearPcmd() {
        dispatchQueue.sync {
            self.pcmdCnt = DroneProtocol.pcmdStopDelay
            self.pcmd = (0, 0)
        }
    }
    
    func animate(animation: UInt32) {
        dispatchQueue.sync {
            commandChannel.send(command: .animate(animation: animation))
        }
    }

    func startAnimation(animation: UInt32) {
        dispatchQueue.sync {
            commandChannel.send(command: .startAnimation(animation: animation))
        }
    }
    
    func stopAnimation() {
        dispatchQueue.sync {
            commandChannel.send(command: .stopAnimation)
        }
    }

    func jump(jumpType: UInt32) {
        dispatchQueue.sync {
            commandChannel.send(command: .jump(jumpType: jumpType))
        }
    }

    func emergency() {
        dispatchQueue.sync {
            commandChannel.send(command: .emergency)
        }
    }

    func cancel() {
        dispatchQueue.sync {
            commandChannel.send(command: .cancelJump)
        }
    }

    func load() {
        dispatchQueue.sync {
            commandChannel.send(command: .loadJump)
        }
    }

    private func didReceiveEvent(_ event: Event) {
        switch event {
        case .allSettingsSent:
            commandChannel.send(command: .getAllStates)
        case .allStateSent:
            // start pcmd loop
            pcmdTimer = DispatchSource.makeTimerSource(queue: dispatchQueue)
            pcmdTimer?.setEventHandler { [unowned self] in
                if self.pcmdCnt > 0 {
                    if self.pcmdCnt == DroneProtocol.pcmdStopDelay {
                        self.pcmd = (0, 0)
                        
                    }
                    self.pcmdCnt -= 1
                    if self.pcmdCnt == 0 {
                        self.dispatchQueue.async {
                            self.delegate?.pcmdTerminated()
                        }
                    }
                }
                let flag = self.pcmd.speed != 0 || self.pcmd.turn != 0
                self.controlChannel.send(command:
                        .pcmd(flag: flag, speed: self.pcmd.speed, turn: self.pcmd.turn))
            }
            pcmdTimer?.schedule(deadline: DispatchTime.now(), repeating: .milliseconds(100))
            pcmdTimer?.resume()
            // connected !
            connected = true
            delegate?.protocolDidConnect()
        case .productName(let name):
            delegate?.droneConnecting(name: name)
        case .batteryStateChanged(let level):
            batteryLevel = Int(level)
            delegate?.batteryLevelDidChange(batteryLevel, low: lowBattery)
        case .productVersion(let version):
            if !checkFirmwareUpToDate(versionString: version) {
                delegate?.firmwareOutOfDate()
            }
        case .jumpLoad(let state):
            print ("jumpLoad State: \(state)")
            if (state == 0x1) {
                self.delegate?.pcmdTerminated()
            }
            else if (state == 0x4) {
                self.delegate?.batteryLevelDidChange(nil, low: true)
            }
        default:
            break
        }
    }
    
    private func checkFirmwareUpToDate(versionString: String) -> Bool {
        let versionComp = versionString.components(separatedBy: ".")
        if versionComp.count >= 3, let major = Int(versionComp[0]), let minor = Int(versionComp[1]), let bugfix = Int(versionComp[2]) {
            if major == 0 {
                return true
            }
            let version = (major, minor, bugfix)
            return version >= DroneProtocol.sumoMinVersion
        }
        
        return false
    }
}


/// Commands that can be sent to the drone
 enum Command {
    case setDate(String)
    case setTime(String)
    case getAllSettings
    case getAllStates
    case pcmd(flag: Bool, speed: Int8, turn: Int8)
    case animate(animation: UInt32)
    case jump(jumpType: UInt32)
    case startAnimation(animation: UInt32)
    case stopAnimation
    case emergency
    case cancelJump
    case loadJump
    
    var data: Data {
        switch self {
        case .setDate(let date):
            var data = Data(forCommand:(0, 4, 1))
            data.append(cmdString: date)
            return data
        case .setTime(let time):
            var data = Data(forCommand:(0, 4, 2))
            data.append(cmdString: time)
            return data
        case .getAllSettings:
            return Data(forCommand: (0, 2, 0))
        case .getAllStates:
            return Data(forCommand: (0, 4, 0))
        case .pcmd(let flag, let speed, let turn):
            var data = Data(forCommand: (3, 0, 0))
            data.append(data: flag ? Int8(1) : Int8(0))
            data.append(data: speed)
            data.append(data: turn)
            return data
        case .emergency:
            let data = Data(forCommand: (3, 2, 0))
            return data
        case .cancelJump:
            let data = Data(forCommand: (3, 2, 1))
            return data
        case .loadJump:
            let data = Data(forCommand: (3, 2, 2))
            return data
        case .jump(let jumpType):
            var data = Data(forCommand: (3, 2, 3))
            data.append(data: jumpType)
            return data
        case .animate(let animation):
            var data = Data(forCommand: (3, 2, 4))
            data.append(data: animation)
            return data
        case .startAnimation(let animation):
            var data = Data(forCommand: (0, 24, 0))
            data.append(data: animation)
            return data
        case .stopAnimation:
            let data = Data(forCommand: (0, 24, 2))
            return data
        }
    }
}

/// Events received from the drone
private enum Event {
    case currentDate
    case currentTime
    
    // Settings
    case allSettingsSent
    case productName(name: String)
    case productSerialNumberHigh(high: String)
    case productSerialNumberLow(low: String)
    case productVersion(version: String)
    case autoCountry(automatic: Bool)
    case country(code: String)
    case wifiSelection(type: UInt32, band: UInt32, channel: UInt8)
    case masterVolume(volume: UInt8)
    case outdoorSetting(outdoor: Bool)
    case autoRecord(enabled: Bool)
    
    // States
    case allStateSent
    case deviceLibVersion(version: String)
    case productModel(model: UInt32)
    case headlightsState(left: UInt8, right: UInt8)
    case batteryStateChanged(level: UInt8)
    case posture(state: UInt32)
    case jumpLoad(state: UInt32)
    case jumpMotorProblem(error: UInt32)
    case chargingInfo(phase: UInt32, rate: UInt32, intensity: UInt8, fullChargingTime: UInt8)
    case animationList(anim: UInt32, stopped: Bool, error: UInt32)
    case sensorStateList(sensor: UInt32, state: UInt8)
    case videoEnabled(enabled: Bool)
    case videoStateV2(state: UInt32, error: UInt32)
    case videoState(state: UInt32, massStorageId: UInt8)
    case massStorageStateList(massStorageId: UInt8, name: String)
    case massStorageInfoStateList(massStorageId: UInt8, size: UInt32, used: UInt32, plugged: Bool, full: Bool)
    case linkQuality(quality: UInt8)
    case wifiSignal(rssi: Int16)
    
    static func from(data: Data) -> Event? {
        //print("from event: \(data[7]), \(data[8]), \(data[9])")
        switch (data[7], data[8], data[9]) {
        case (0, 5, 4):
            return .currentDate
        case (0, 5, 5):
            return .currentTime
        case (0, 3, 0):
            return .allSettingsSent
        case (0, 3, 3):
            return .productVersion(version: data.readString(at: 11))
        case (0, 3, 2):
            return .productName(name: data.readString(at: 11))
        case (0, 3, 4):
            return .productSerialNumberHigh(high: data.readString(at: 11))
        case (0, 3, 5):
            return .productSerialNumberLow(low: data.readString(at: 11))
        case (0, 3, 7): //Autocountry
            return .autoCountry(automatic: data[11] == 1)
        case (0, 3, 6): // Country
            return .country(code: data.readString(at: 11))
        case (3, 9, 0): // Network WiFi Selection
            return .wifiSelection(type: data.readUIn32(at: 11), band: data.readUIn32(at: 15), channel: data[19])
        case (3, 13, 0): // Master Volume
            return .masterVolume(volume: data[11])
        case (0, 10, 0): // WiFi setting - Outdoors
            return .outdoorSetting(outdoor: data[11] == 1)
        case (3, 22, 0): // Video Auto Record
            return .autoRecord(enabled: data[11] == 1)
            
        // States
        case (0, 5, 0):
            return .allStateSent
        case (0, 18, 2): // AR Libs Version
            return .deviceLibVersion(version: data.readString(at: 11))
        case (3, 1, 0): // Posture
            return .posture(state: data.readUIn32(at: 11))
        case (3, 3, 0): // Animation - JumpLoad
            return .jumpLoad(state: data.readUIn32(at: 11))
        case (3, 3, 2): // Animation - Jump Motor
            return .jumpMotorProblem(error: data.readUIn32(at: 11))
        case (0, 29, 3): // Charging info
            return .chargingInfo(phase: data.readUIn32(at: 11), rate: data.readUIn32(at: 15), intensity: data[19], fullChargingTime: data[20])
        case (0, 25, 0): // Animation List
            return .animationList(anim: data.readUIn32(at: 11), stopped: data[15] == 1, error: data.readUIn32(at: 19))
        case (0, 5, 1):
            return .batteryStateChanged(level: data[11])
        case (0, 5, 9):
            return .productModel(model: data.readUIn32(at: 11))
        case (0, 23, 0):
            return .headlightsState(left: data[11], right: data[12])
        case (0, 5, 8):
            return .sensorStateList(sensor: data.readUIn32(at: 11), state: data[15])
        case (3, 19, 0):
            return .videoEnabled(enabled: data[11] == 1)
        case (3, 7, 3):
            return .videoStateV2(state: data.readUIn32(at: 11), error: data.readUIn32(at: 15))
        case (3, 7, 1):
            return .videoState(state: data.readUIn32(at: 11), massStorageId: data[15])
        case (0, 5, 2):
            return .massStorageStateList(massStorageId: data[11], name: data.readString(at: 15))
        case (0, 5, 3):
            return .massStorageInfoStateList(massStorageId: data[11], size: data.readUIn32(at: 12), used: data.readUIn32(at: 16), plugged: data[20] == 1, full: data[21] == 1)
        case (3, 11, 4):
            return .linkQuality(quality: data[11])
        case (0, 5, 7):
            return .wifiSignal(rssi: data.readInt16(at: 11))
            
        default:
            return nil
        }
    }
}

///  Channel to send command with ack
 class CommandChannel {
    private let sender: DroneWiFi.Sender
    private let ack: DroneWiFi.Receiver
    private var seqNr: UInt8 = 0
    
    init (sender: DroneWiFi.Sender, ack: DroneWiFi.Receiver) {
        self.sender = sender
        self.ack = ack
        ack.processor = {
            [weak self] data in
            self?.didReceive(data: data)
        }
    }
    
    func send(command: Command) {
        seqNr = seqNr &+ 1
        var data = command.data
        data[2] = seqNr
        data[3] = UInt8(data.count)
        sender.write(data: data)
    }
    
    private func didReceive (data: Data) {
        // ignore ack
    }
}

///  Control channel to send piloting commands
 class ControlChannel {
    private let sender: DroneWiFi.Sender
    private var seqNr: UInt8 = 0
    init (sender: DroneWiFi.Sender) {
        self.sender = sender
    }
    
    func send(command: Command) {
        seqNr = seqNr &+ 1
        var data = command.data
        data[0] = 2 // DATA
        data[1] = 10 //no ack
        data[2] = seqNr
        data[3] = UInt8(data.count)
        sender.write(data: data)
    }
}

/// Channel to receive events
private class EventChannel {
    private let receiver: DroneWiFi.Receiver
    private let ack: DroneWiFi.Sender?
    private let handler: (Event) -> Void
    private var seqNr: UInt8 = 0
    
    init (receiver: DroneWiFi.Receiver, ack: DroneWiFi.Sender?, handler: @escaping (Event) -> Void) {
        self.receiver = receiver
        self.ack = ack
        self.handler = handler
        receiver.processor  = {
            [weak self] data in
            self?.didReceive(data: data)
        }
    }
    
    private func didReceive (data: Data) {
        // acknolege all received events
        if let ack = ack {
            seqNr = seqNr &+ 1
            ack.write(data: Data(ackOf: data, withSeqNr: seqNr))
        }
        if let event = Event.from(data: data) {
            handler(event)
        }
    }
}

/// Extension to create data of a commands and write zero terminated string
extension Data {
    init(forCommand cmd:(prj: UInt8, cls: UInt8, id: UInt8)) {
        self.init(_:[4, 11, 0, 0,0,0,0, cmd.prj, cmd.cls, cmd.id, 0])
    }
    
    init(ackOf data: Data, withSeqNr seqNr: UInt8) {
        self.init(_:[1, 254, seqNr, 8,0,0,0, data[2]])
    }
    
    mutating func append(cmdString string: String) {
        self.append(Data(_:Array(string.utf8)))
        self.append(Data(_: [UInt8(0)]))
    }
    
    mutating func append(data: UInt8) {
        Swift.withUnsafeBytes(of: data) {
            self.append(contentsOf: $0)
        }
    }
    
    mutating func append(data: Int8) {
        Swift.withUnsafeBytes(of: data) {
            self.append(contentsOf: $0)
        }
    }
    
    mutating func append(data: Int16) {
        Swift.withUnsafeBytes(of: data) {
            self.append(contentsOf: $0)
        }
    }
    
    mutating func append(data: UInt32) {
        Swift.withUnsafeBytes(of: data) {
            self.append(contentsOf: $0)
        }
    }
    
    mutating func append(data: Float) {
        Swift.withUnsafeBytes(of: data) {
            self.append(contentsOf: $0)
        }
    }
    
    func readInt16(at index: Index) -> Int16 {
        return self.subdata(in: index..<index+MemoryLayout<Int16>.size).withUnsafeBytes {$0.load(as: Int16.self)}
    }
    
    func readUIn32(at index: Index) -> UInt32 {
        return self.subdata(in: index..<index+MemoryLayout<UInt32>.size).withUnsafeBytes {$0.load(as: UInt32.self)}
    }
    
    func readFloat(at index: Index) -> Float {
        return self.subdata(in: index..<index+MemoryLayout<Float>.size).withUnsafeBytes {$0.load(as: Float.self)}
    }
    
    func readString(at index: Index) -> String {
        let y = self.subdata(in: index..<self.count)
        guard let str = String(data: y, encoding: .utf8) else { return "" }
        return str
    }
}

