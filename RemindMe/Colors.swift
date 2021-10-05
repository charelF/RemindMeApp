//
//  Colors.swift
//  RemindMe
//
//  Created by Charel Felten on 05/10/2021.
//

import Foundation
import SwiftUI // for Color

enum ColorLocation: String {
    case primary = "p"
    case secondary = "s"
    case background = "b"
}

enum ColorTheme: String, CaseIterable {
    case defaultcolor = "Default"
    case retro = "Retro"
}

class Colors {
    
    static func getColor(for note: Note, in location: ColorLocation) -> Color {
        return Colors.getColor(for: Int(note.priority), in: location)
    }
    
    static func getColor(for priority: Int, in location: ColorLocation) -> Color {
        let config: Config = Config.shared
        let theme: ColorTheme = config.colorTheme
        var color: Color
        switch theme {
        case .retro:
            let colorCode: String = "\(theme.rawValue.lowercased())_\(priority)"
            if let uicolor = UIColor(named: colorCode) {
                color =  Color(uicolor)
            } else {
                fallthrough // if we cant find anything, we fall through to default
            }
        default:
            switch priority {
            case 0:
                color = Color.green
            case 1:
                color = Color.orange
            case 2:
                color = Color.red
            case 3:
                color = Color.blue
            case 4:
                color = Color.purple
            default:
                color = Color.primary
            }
        }
        
        switch location {
        case .primary:
            break
        case .secondary:
            color = color.opacity(0.5)
        case .background:
            // TODO: return higher opacity if in dark mode
            color = color.opacity(0.1)
        }
        
        return color
    }
}
