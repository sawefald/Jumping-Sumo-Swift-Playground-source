//
//  Assessor.swift
//  UserModule
//
//  Created by Sarah Miller on 6/6/24.
//

import Foundation
import PlaygroundSupport

// Action recorder and Assessor
public class Assessor {

    // an action and array of Hint strings
    public typealias Assessment = (Action, [String])

    // Assessable action
    public enum Action {
        case speed(UInt?)
        case move(direction: MoveDirection?, duration: Int?)
        case complexMove(MoveParams?, duration: UInt?)
//        case turn(direction: TurnDirection?, angle: UInt?)
        case animate(animation: Animations?)
        case jump(jumpType: JumpType?)
//        case takePicture
        // for expected action only: a set of action present is any order
        case allAnyOrder([Action])
        // for expected action only: a list of action in a single Assessment
        case all([Action])
    }

    // Recorded actions
    private var actions = [Action]()

    /// Add an action to the recorder
    ///
    /// - Parameter action: action to add
    public func add(action: Action) {
        actions.append(action)
    }

    /// This class can be constructed from playground page
    public init() {
    }

    /// Check that expected actions have been recorded
    ///
    /// - Parameters:
    ///   - expectedActions: array of expected assessment
    ///   - success: success message
    /// - Returns: AssessmentStatus
    public func check(expected expectedActions: [Assessment], success: String?)
        -> PlaygroundPage.AssessmentStatus {
            var actionsIdx = 0
            for expectedAction in expectedActions {
                if !checkExpectedAction(expected: expectedAction.0, actionIdx: &actionsIdx) {
                    return .fail(hints: expectedAction.1, solution: nil)
                }
            }
            return .pass(message: success)
    }

    private func checkExpectedAction(expected: Action, actionIdx: inout Int) -> Bool {
        while actionIdx < actions.count {
            let actual = actions[actionIdx]
            switch expected {
            case .allAnyOrder(let anyOrderActions):
                let startIdx = actionIdx
                var endIdx = actionIdx
                for action in anyOrderActions {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                            // store last valid action idx, start from start pos
                            endIdx = max(endIdx, actionIdx)
                            actionIdx = startIdx
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    actionIdx = endIdx
                    return true
                }
            case .all(let allAction):
                for action in allAction {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    return true
                }
            default:
                if checkAction(expected: expected, actual: actual) {
                    actionIdx += 1
                    return true
                }
            }
            actionIdx += 1
        }
        return false
    }

    private func checkAction(expected: Action, actual: Action) -> Bool {
        switch expected {
        case let .speed(expectedSpeed):
            if case let .speed(speed) = actual, expectedSpeed == nil || expectedSpeed == speed {
                return true
            }
        case let .move(expectedDirection, expectedDuration):
            if case let .move(direction, duration) = actual,
                (expectedDirection == nil || expectedDirection == direction) &&
                    (expectedDuration == nil || expectedDuration == duration) {
                return true
            }
        case let .complexMove(expectedParams, expectedDuration) :
            if case let .complexMove(params, duration) = actual,
                (expectedParams == nil || expectedParams == params) &&
                    (expectedDuration == nil || expectedDuration! == duration) {
                return true
            }
//        case let .turn(expectedDirection, expectedAngle):
//            if case let .turn(direction, angle) = actual,
//                (expectedDirection == nil || expectedDirection == direction) &&
//                    (expectedAngle == nil || expectedAngle == angle) {
//                return true
//            }
        case let .animate(expectedAnimation):
            if case let .animate(animation) = actual,
                expectedAnimation == nil || expectedAnimation == animation {
                return true
            }
        case let .jump(expectedJumpType):
            if case let .jump(jumpType) = actual,
                expectedJumpType == nil || expectedJumpType == jumpType {
                return true
            }
//        case .takePicture:
//            if case .takePicture = actual {
//                return true
//            }
        default: break
        }
        return false
    }
}
