//
//  EventCoordinator.swift
//  CampsGroupingMacApp
//
//  Created by Nathan Sjoquist on 5/30/24.
//

import Combine
import Foundation

// MARK: - Event Space protcol

public protocol EventSpace {
    associatedtype State: Equatable
    associatedtype Event
    associatedtype Action

    static func handle(event: Event, state: inout State) -> [Action]
}

// MARK: - Handler Superclasses

open class ActionHandler<T: EventSpace> {
    open func handle(action: T.Action, handleEvent: @escaping (T.Event) -> Void) {}
}

open class EventHandler<T: EventSpace> {
    open func handle(event: T.Event, state: inout T.State, handleActions: @escaping ([T.Action]) -> Void) { }
}

// MARK: - Event Coordinator

final class EventCoordinator<T: EventSpace>: ObservableObject, Observable, Equatable {
    static func == (lhs: EventCoordinator<T>, rhs: EventCoordinator<T>) -> Bool {
        lhs.state == rhs.state
    }

    @Published private(set) var state: T.State

    private var actionHandlers: [ActionHandler<T>]

    private let eventHandler: EventHandler<T>

    init(
        state: T.State,
        eventHandler: EventHandler<T> = DefaultEventHandler<T>(),
        actionHandlers: [ActionHandler<T>] = []
    ) {
        self.state = state
        self.eventHandler = eventHandler
        self.actionHandlers = actionHandlers
    }

    final func send(event: T.Event) {
        DispatchQueue.main.async {
            self.eventHandler.handle(event: event, state: &self.state) { actions in
                DispatchQueue.global().async {
                    for action in actions {
                        for actionHandler in self.actionHandlers {
                            actionHandler.handle(action: action) { event in
                                self.send(event: event)
                            }
                        }
                    }
                }
            }
        }
    }

    final func add(actionHandler: ActionHandler<T>) {
        actionHandlers.append(actionHandler)
    }
}

// MARK: - Prebuilt Handlers

private class DefaultEventHandler<T: EventSpace>: EventHandler<T> {
    override func handle(event: T.Event, state: inout T.State, handleActions: @escaping ([T.Action]) -> Void) {
        handleActions(T.handle(event: event, state: &state))
    }
}

final class MockEventHandler<T: EventSpace>: EventHandler<T> {
    var events: [T.Event] = []
    var states: [T.State] = []
    var onEvent: (T.Event) -> [T.Action] = { _ in return [] }

    override func handle(event: T.Event, state: inout T.State, handleActions: @escaping ([T.Action]) -> Void) {
        self.events.append(event)
        self.states.append(state)

        handleActions(self.onEvent(event))
    }
}
