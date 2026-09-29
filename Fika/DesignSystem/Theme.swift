//
//  Theme.swift
//  Common Ground
//
//  Design System: Tokens for colors, typography, spacing, corner radii, and styling
//

import SwiftUI

enum Theme {
    // MARK: - Color Tokens
    enum Colors {
        /// Warm ivory / soft neutral app canvas
        static let background = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.10, green: 0.09, blue: 0.09, alpha: 1.0)
                    : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)
            }
        )
        
        /// Elevated card surface
        static let cardBackground = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.15, green: 0.14, blue: 0.14, alpha: 1.0)
                    : UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            }
        )
        
        /// Secondary surface for inputs and nested containers
        static let secondaryCardBackground = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.19, green: 0.18, blue: 0.18, alpha: 1.0)
                    : UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)
            }
        )
        
        /// Deep plum / dark ink for high-contrast primary typography
        static let primaryText = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.96, green: 0.94, blue: 0.95, alpha: 1.0)
                    : UIColor(red: 0.16, green: 0.11, blue: 0.16, alpha: 1.0)
            }
        )
        
        /// Muted plum / warm slate for subtitles and metadata
        static let secondaryText = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.72, green: 0.67, blue: 0.71, alpha: 1.0)
                    : UIColor(red: 0.46, green: 0.40, blue: 0.45, alpha: 1.0)
            }
        )
        
        /// Restrained coral / rose for primary intentional actions
        static let accentCoral = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.88, green: 0.45, blue: 0.42, alpha: 1.0)
                    : UIColor(red: 0.79, green: 0.35, blue: 0.32, alpha: 1.0)
            }
        )
        
        /// Soft coral wash for pills and banners
        static let accentSoft = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.28, green: 0.18, blue: 0.18, alpha: 1.0)
                    : UIColor(red: 0.97, green: 0.92, blue: 0.91, alpha: 1.0)
            }
        )
        
        /// Calm sage green for mutual spark or confirmed states
        static let sage = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.45, green: 0.65, blue: 0.58, alpha: 1.0)
                    : UIColor(red: 0.32, green: 0.49, blue: 0.43, alpha: 1.0)
            }
        )
        
        /// Warm ochre for date planning
        static let ochre = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.88, green: 0.68, blue: 0.38, alpha: 1.0)
                    : UIColor(red: 0.72, green: 0.49, blue: 0.20, alpha: 1.0)
            }
        )
        
        /// Subtle separator line
        static let divider = Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.24, green: 0.22, blue: 0.22, alpha: 1.0)
                    : UIColor(red: 0.91, green: 0.88, blue: 0.85, alpha: 1.0)
            }
        )
        
        // MARK: - Swiping & Dating Actions
        /// Vibrant emerald for Like / Connect (Tinder / Bumble style)
        static let swipeLike = Color(red: 0.05, green: 0.80, blue: 0.52)
        /// Vibrant coral-red for Nope / Pass
        static let swipeNope = Color(red: 1.00, green: 0.28, blue: 0.35)
        /// Electric blue for Super Like
        static let swipeSuperLike = Color(red: 0.08, green: 0.62, blue: 1.00)
        /// Golden amber for Rewind / Undo
        static let swipeRewind = Color(red: 1.00, green: 0.72, blue: 0.12)
        /// Modern purple for Boost / Detail
        static let swipeBoost = Color(red: 0.65, green: 0.35, blue: 0.95)
    }
    
    // MARK: - Gradients
    enum Gradients {
        /// Tinder flame gradient
        static let datingFlame = LinearGradient(
            colors: [Color(red: 1.00, green: 0.27, blue: 0.35), Color(red: 1.00, green: 0.45, blue: 0.22)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Bumble honey gold gradient
        static let bumbleGold = LinearGradient(
            colors: [Color(red: 1.00, green: 0.78, blue: 0.16), Color(red: 1.00, green: 0.62, blue: 0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// FB Dating violet-rose gradient
        static let fbDating = LinearGradient(
            colors: [Color(red: 0.55, green: 0.20, blue: 0.88), Color(red: 0.95, green: 0.26, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// Scrim for photo readability
        static let cardOverlay = LinearGradient(
            colors: [
                Color.black.opacity(0.0),
                Color.black.opacity(0.15),
                Color.black.opacity(0.70),
                Color.black.opacity(0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Spacing Tokens
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radii
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isDestructive ? Color.red.opacity(0.85) : Theme.Colors.accentCoral)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.secondaryCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(Theme.Colors.divider, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(Theme.Colors.secondaryText)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
