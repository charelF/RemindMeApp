//
//  Colors.swift
//  RemindMe
//
//  Created by Charel Felten on 05/10/2021.
//

import Foundation
import SwiftUI

enum ColorTheme: String, CaseIterable {
  case defaultcolor = "Default"
  case retro = "Retro"
  case monotone = "Monotone"
  
  func getColors() -> Colors {
    switch self {
    case .retro:
      if
        let lp = UIColor(named: "retro_0"),
        let mp = UIColor(named: "retro_1"),
        let hp = UIColor(named: "retro_2"),
        let cp = UIColor(named: "retro_3")
      {
        return Colors(
          lowPrimary: Color(lp),
          mediumPrimary: Color(mp),
          highPrimary: Color(hp),
          customPrimary: Color(cp)
        )
      } else {
        fallthrough
      }
    case .monotone:
      return Colors(lowPrimary: Color.black, mediumPrimary: Color.black, highPrimary: Color.black, customPrimary: Color.black, lowSecondary: Color.black, mediumSecondary: Color.black, highSecondary: Color.black, customSecondary: Color.black, lowBackground: Color.clear, mediumBackground: Color.clear, highBackground: Color.clear, customBackground: Color.clear)
    default:
      return Colors()
    }
  }
}


enum ColorLocation {
  case primary
  case secondary
  case background
}

struct Colors {
  let lowPrimary: Color
  let mediumPrimary: Color
  let highPrimary: Color
  let customPrimary: Color
  let lowSecondary: Color
  let mediumSecondary: Color
  let highSecondary: Color
  let customSecondary: Color
  let lowBackground: Color
  let mediumBackground: Color
  let highBackground: Color
  let customBackground: Color
  
  func getColor(for note: Note, in location: ColorLocation) -> Color {
    return self.getColor(for: note.priority, in: location)
  }
  
  func getColor(for priority: Priority, in location: ColorLocation) -> Color {
    switch (priority, location) {
    case (.low, .primary): return self.lowPrimary
    case (.medium, .primary): return self.mediumPrimary
    case (.high, .primary): return self.highPrimary
    case (.custom(_), .primary): return self.customPrimary
    case (.low, .secondary): return self.lowSecondary
    case (.medium, .secondary): return self.mediumSecondary
    case (.high, .secondary): return self.highSecondary
    case (.custom(_), .secondary): return self.customSecondary
    case (.low, .background): return self.lowBackground
    case (.medium, .background): return self.mediumBackground
    case (.high, .background): return self.highBackground
    case (.custom(_), .background): return self.customBackground
    }
  }
}

    
    
extension Colors {
  // https://www.hackingwithswift.com/example-code/language/how-to-add-a-custom-initializer-to-a-struct-without-losing-its-memberwise-initializer
  init(
    lowPrimary: Color,
    mediumPrimary: Color,
    highPrimary: Color,
    customPrimary: Color
  ) {
    self.lowPrimary = lowPrimary
    self.mediumPrimary = mediumPrimary
    self.highPrimary = highPrimary
    self.customPrimary = customPrimary
    self.lowSecondary = lowPrimary.opacity(0.5)
    self.mediumSecondary = mediumPrimary.opacity(0.5)
    self.highSecondary = highPrimary.opacity(0.5)
    self.customSecondary = customPrimary.opacity(0.5)
    self.lowBackground = lowPrimary.opacity(0.2)
    self.mediumBackground = mediumPrimary.opacity(0.2)
    self.highBackground = highPrimary.opacity(0.2)
    self.customBackground = customPrimary.opacity(0.2)
  }
  
  init() {
    self.init(
      lowPrimary: Color.green,
      mediumPrimary: Color.orange,
      highPrimary: Color.red,
      customPrimary: Color.blue
    )
  }
}


