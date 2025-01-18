//
//  DroneWifi.swift
//  UserModule
//
//  Created by Sarah Miller on 6/5/24.
//

import Foundation
import Network

// Helper function to parse json data from drone to get port number to
// send commands to.
// {
//   "status": 0,
//   "c2d_port": 54321,
//   "arstream_fragment_size": 65000,
//   "arstream_fragment_maximum_number": 4,
//   "arstream_max_ack_interval": -1,
//   "c2d_update_port": 51,
//   "c2d_user_port": 21
// }
struct DroneInfo: Decodable {
    let status: Int
    let c2d_port: Int
    let arstream_fragment_size: Int
    let arstream_fragment_maximum_number: Int
    let arstream_max_ack_interval: Int
    let c2d_update_port: Int
    let c2d_user_port: Int
}

// Header
// uint8  type  - frame type
// [  ACK: 1, DATA: 2, DATA_LOW_LATENCY: 3, DATA_WITH_ACK: 4]
// uint8  id    - identifier of the buffer sending the frame
// [NONACK: 0xa, ACK: 0xb, EMERGENCY: 0xc, VIDEO_ACK: 0xd, VideoData: 0x7d, Event: 0x7e, NavData: 0x7f]
// uint8  seq   - sequence number of the frame
// [starts at 1 and incrememnts to 255, repeated back in ack header & body]
// uint32 size  - size of the frame
// [little endian encoded]

// AckMessage:
// all data with ack must be ack'd, not sure about the others
// Type = Ack
// Id = 0x80 | incoming.id
// seq = incoming.seq
// size = 8 bytes
// data = incoming.seq

protocol DroneWiFiDelegate: AnyObject {
    func droneWifiDidConnect()
    func droneWifiDidDisconnect()
}

class DroneWiFi {
    
    /// Sender types, controller side view
    enum SenderType {
        /// commands without ack
        case cmdNoAck
        /// command with ack
        case cmdAck
        /// ack of reveiced events
        case evtAck
    }
    
    /// Reciver types, controller side view
    enum ReceiverType {
        /// events without ack
        case evtNoAck
        /// events ack
        case evtAck
        /// ack of sent commands
        case cmdAck
    }
    
    /// Sender to write on a characteristics
    class Sender {
        private let connection: NWConnection
        private let wifi: DroneWiFi
        
        init (connection: NWConnection, wifi: DroneWiFi) {
            self.connection = connection
            self.wifi = wifi
        }
        
        func write(data: Data) {
            if wifi.isSendReady {
                var msg: Data
                if wifi.sendPong {
                    msg = wifi.pingReceived!
                    msg.append(data)
                    msg[1] = 1
                    
                    // Reset the PONG buffers
                    wifi.sendPong = false
                    wifi.pingReceived = Data()
                } else {
                    msg = data
                }
                
                connection.send(content: msg, completion: NWConnection.SendCompletion.contentProcessed({ error in
                    if let error = error {
                        print("did send, error: %@", "\(error)")
                    }
                }))
            }
        }
    }
    
    /// Receiver on a characteristics
    class Receiver {
        private let listener: NWListener
        
        /// delegate bloc to process received data
        var processor: ((Data) -> Void)?
        
        init (listener: NWListener) {
            self.listener = listener
        }
        
        func receive(data: Data) {
            processor?(data)
        }
    }
    
    var starter: NWConnection?
    var d2clist: NWListener?
    var d2client: NWConnection?
    var c2drone: NWConnection?
    var queue = DispatchQueue.global(qos: .userInitiated)
    var c2dport: Int?
    var hostStr: String
    var port: Int
    
    /// New data will be place in this variable to be received by observers
    @Published private(set) public var pingReceived: Data?
    /// When there is an active listening NWConnection this will be `true`
    @Published private(set) public var isReady: Bool = false
    /// Default value `true`, this will become false if the UDPListener ceases listening for any reason
    @Published public var listening: Bool = true
    /// When there is an active sending NWConnection this will be `true`
    @Published private(set) public var isSendReady: Bool = false
    /// When there is a need to send a PONG prepended to the outbound message this will be 'true'
    @Published private(set) public var sendPong: Bool = false
    
    /// All senders by type
    var senders: [SenderType:Sender] = [:]
    /// All receivers by type
    var receivers: [ReceiverType:Receiver] = [:]
    
    /// delegate
    fileprivate weak var delegate: DroneWiFiDelegate?
    
    init(hostName: String, portName: Int, queue: DispatchQueue, delegate: DroneWiFiDelegate) {
        self.delegate = delegate
        self.hostStr = hostName
        self.port = portName
    }
    
    func start() {
        print("will start")
        let host = NWEndpoint.Host(self.hostStr)
        let port = NWEndpoint.Port("\(self.port)")!
        
        self.starter = NWConnection(host: host, port: port, using: .tcp)
        
        // Setup UDP Listener.
        let d2cport = NWEndpoint.Port("\(43210)")!
        let params = NWParameters.udp
        self.d2clist = try! NWListener(using: params, on: d2cport)
        self.d2clist?.stateUpdateHandler = { update in
            switch update {
            case .ready:
                self.isReady = true
                print("Listener connected to port \(d2cport)")
            case .failed, .cancelled:
                // Announce we are no longer able to listen
                self.listening = false
                self.isReady = false
                self.delegate?.droneWifiDidDisconnect()
                print("Listener disconnected from port \(d2cport)")
            default:
                print("Listener connecting to port \(d2cport)...")
            }
        }
        self.d2clist?.newConnectionHandler = { connection in
            print("Listener receiving new message")
            self.createConnection(connection: connection)
        }
        self.d2clist?.start(queue: self.queue)
        self.starter?.stateUpdateHandler = self.didChange(state:)
        self.starter?.start(queue: .main)
    }
    
    func stop() {
        self.starter?.cancel()
        print("did stop")
    }
    
    private func didChange(state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            print("is waiting: %@", "\(error)")
        case .preparing:
            break
        case .ready:
            print ("Connection READY!!!!!")
            break
        case .failed(let error):
            print("did fail, error: %@", "\(error)")
            self.stop()
        case .cancelled:
            print("was cancelled")
            self.stop()
        @unknown default:
            break
        }
    }
    
    func c2dconnect(port: Int) {
        let host = NWEndpoint.Host(self.hostStr)
        let port = NWEndpoint.Port("\(port)")!
        self.c2drone = NWConnection(host: host, port: port, using: .udp)
        
        self.c2drone?.stateUpdateHandler = { update in
            switch update {
            case .ready:
                self.isSendReady = true
                self.setupSenderReceivers()
                self.delegate?.droneWifiDidConnect()
            case .failed, .cancelled:
                // Announce we are no longer able to listen
                self.isSendReady = false
                self.delegate?.droneWifiDidDisconnect()
            default:
                break
            }
        }
        self.c2drone?.start(queue: .global())
    }
    
    func startReceive() {
        self.starter?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isDone, error in
            if let data = data, !data.isEmpty {
                // need to parse out the sendto port:
                let myString = String(data: data, encoding: String.Encoding.utf8) ?? "{\"c2d_port\": 54321}"
                print (" Data \(myString)")
                //let jsonData = myString.data(using: .utf8)
                //let droneInfo: DroneInfo = try! JSONDecoder().decode(DroneInfo.self, from: jsonData!)
                
                let c2dport = 54321 //droneInfo.c2d_port
                print ("Port Connection \(c2dport)")
                self.c2dconnect(port: c2dport)
                self.stop()
                return
            }
            
            if let error = error {
                print("did receive, error: %@", "\(error)")
                self.stop()
                return
            }
            if isDone {
                print("did receive, EOF")
                self.stop()
                return
            }
            self.startReceive()
        }
    }
    
    func send(line: String) {
        let data = Data("\(line)\r\n".utf8)
        self.starter?.send(content: data, completion: NWConnection.SendCompletion.contentProcessed { error in
            if let error = error {
                print("did send, error: %@", "\(error)")
                self.stop()
            }
        })
    }
    
    func createConnection(connection: NWConnection) {
        self.d2client = connection
        self.d2client?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                print("Listener ready to receive message - \(connection)")
                self.listening = true
                self.receive()
            case .cancelled, .failed:
                print("Listener failed to receive message - \(connection)")
                // Cancel the listener, something went wrong
                self.d2clist?.cancel()
                // Announce we are no longer able to listen
                self.listening = false
            default:
                print("Listener waiting to receive message - \(connection)")
            }
        }
        self.d2client?.start(queue: .global())
    }
    
    func processMessage(data: Data) {
        if data.count < 8 {
            print ("not enough data %@", data as NSData)
            return
        }
        switch (data[0], data[1]) {
            case( 1, 139):
                break
            // Stream / low latency
            case( 3, 125):
                self.receivers[.evtNoAck]?.receive(data: data as Data)
                break
            // command no ack
            case( 2, 127):
                self.receivers[.evtNoAck]?.receive(data: data as Data)
                break
            // Data with ack
            case (4, 126):
                self.receivers[.evtAck]?.receive(data: data as Data)
                break
            // Ping
            case (2, 0):
                pingReceived = data
                sendPong = true
                break
            // Ack
            case (1, 138):
                // do nothing
                break
            default:
                print ("Process Message: unhandled message type \(data[0]) \(data[1])")
                break
        }
    }
    
    func receive() {
        self.d2client?.receiveMessage { data, context, isComplete, error in
            if let unwrappedError = error {
                print("Error: NWError received in \(#function) - \(unwrappedError)")
                return
            }
            guard isComplete, let data = data else {
                print("Error: Received nil Data with context - \(String(describing: context))")
                return
            }
            
            if self.listening {
                if !data.isEmpty {
                    var idx = 0
                    while idx + 7 < data.count {
                        // extract the length from the message starts at offset 3 for 4 bytes
                        let len = data.subdata(in: idx+3..<idx+3+MemoryLayout<UInt32>.size).withUnsafeBytes {$0.load(as: UInt32.self)}
                        
                        // extract the whole message incluing header for length
                        let msg = data.subdata(in: idx..<Data.Index(len)+idx)
                        
                        // set index to start of next method
                        idx += Data.Index(len)
                        
                        // process each individual message
                        self.processMessage(data: msg)
                    }
                 } else {
                    print ("packet empty")
                }
            
                self.receive()
            }
        }
    }
    
    func setupSenderReceivers() {
        receivers[.evtNoAck] = Receiver(listener: self.d2clist!)
        receivers[.evtAck] = Receiver(listener: self.d2clist!)
        receivers[.cmdAck] = Receiver(listener: self.d2clist!)
        
        if (self.c2drone != nil) {
            senders[.cmdAck] = Sender(connection: self.c2drone!, wifi: self)
            senders[.cmdNoAck] = Sender(connection: self.c2drone!, wifi: self)
            senders[.evtAck] = Sender(connection: self.c2drone!, wifi: self)
        }
    }
    
    func cancel() {
        self.listening = false
        self.isSendReady = false
        self.d2client?.cancel()
        self.c2drone?.cancel()
        self.d2clist?.cancel()
    }
}
