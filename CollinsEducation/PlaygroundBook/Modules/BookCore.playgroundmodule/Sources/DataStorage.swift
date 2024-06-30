//
//  DataStorage.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//

import Foundation
import PlaygroundSupport


public var myDrone: String? {
    get {
        if case let .dictionary(dict)? = PlaygroundKeyValueStore.current["com.collins.education.jsdrone.LastConnectedDrone"],
            case let .string(nameValue)? = dict["name"] {
            return nameValue
        }
        return nil
    }

    set {
        let value: PlaygroundValue?
        if let newValue = newValue {
            value = .dictionary([
                "name": .string(String(newValue))])
        } else {
            value = nil
        }
        PlaygroundKeyValueStore.current["com.collins.education.jsdrone.LastConnectedDrone"] = value
    }
}
