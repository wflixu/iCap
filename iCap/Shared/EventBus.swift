//
//  EventBus.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import Foundation
import Combine
// 系统总线事件
protocol Event {}

struct SaveAll: Event {
    let data: String
}
struct SaveDrawing: Event {
    let data: String
}
struct SavedAnno: Event {
    let data: String
}

final class EventBus {
    static let shared = EventBus()

    private init() {}

    private let subject = PassthroughSubject<Event, Never>()
    
    /// 发送一个事件
    func post<T: Event>(_ event: T) {
        subject.send(event)
    }
    
    /// 监听某个特定事件类型
    func observe<T: Event>(_ eventType: T.Type) -> AnyPublisher<T, Never> {
        subject
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }
}

