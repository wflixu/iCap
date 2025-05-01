//
//  EventBus.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import Foundation
import Combine


final class EventBus {
    static let shared = EventBus()
    
    private init() {}
    
    private var subjects = [String: PassthroughSubject<Any, Never>]()
    
    func post(event name: String, data: Any) {
        if let subject = subjects[name] {
            subject.send(data)
        } else {
            let subject = PassthroughSubject<Any, Never>()
            subjects[name] = subject
            subject.send(data)
        }
    }
    
    func publisher(for event: String) -> AnyPublisher<Any, Never> {
        if let subject = subjects[event] {
            return subject.eraseToAnyPublisher()
        } else {
            let subject = PassthroughSubject<Any, Never>()
            subjects[event] = subject
            return subject.eraseToAnyPublisher()
        }
    }
}

