//
//  Priority.swift
//  RemindMe
//
//  Created by Charel Felten on 17/11/2022.
//

import Foundation

enum Priority: Identifiable {
  
  case low
  case medium
  case high
  case custom(date: Date)  // prevents us from having rawvalue enum
  
  mutating func next() {
    switch self {
    case .low:
      self = .medium
    case .medium:
      self = .high
    case .high:
      self = .low
    case .custom:
      self = .low
    }
  }
  
  func getIndex() -> Int {
    switch self {
    case .low:
      return 0
    case .medium:
      return 1
    case .high:
      return 2
    case .custom(_):
      return 3
    }
  }
  
  static var allRegularCases: [Priority] {
    return [.low, .medium, .high]
  }
  
  static var count: Int {
    return allRegularCases.count
  }
  
  func getDescription() -> String {
    switch self {
    case .low:
      return "Low Priority"
    case .medium:
      return "Mid Priority"
    case .high:
      return "High Priority"
    case .custom(_):
      return "Custom Priority"
    }
  }
  
  func getIntervalDescription() -> String {
    switch self {
    case .custom(let date):
      return Note.dateFormatter.string(from: date)
    default:
      if let intervalAndDate = Config.shared.getIntervalAndDate(for: self) {
        return intervalAndDate.interval.rawValue
      } else {
        return "Whoops"
      }
    }
  }
  
  func isCustom() -> Bool {
    // this is needed because I cant compare just whether note.priority == .custom,
    // since .custom(date 1) is different from .custom(date 2), however both are custom
    switch self {
    case .custom(_):
      return true
    default:
      return false
    }
  }
  
  // for identifable protocol
  var id: Int { return self.getIndex() }
}


