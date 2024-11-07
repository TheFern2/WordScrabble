//
//  ConfettiView.swift
//  WorldScramble
//
//  Created by Fernando Balandran on 10/28/24.
//


import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Create the emitter layer
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10) // Start at the top center
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        
        // Create the confetti cells
        let colors: [UIColor] = [.red, .green, .blue, .orange, .purple, .yellow, .cyan, .magenta]
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.contents = createColoredImage(color: color)?.cgImage
            cell.birthRate = 10
            cell.lifetime = 8.0
            cell.velocity = 150
            cell.velocityRange = 100
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.1
            cell.scaleRange = 0.1
            cell.color = color.cgColor
            return cell
        }
        
        view.layer.addSublayer(emitter)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    // Helper function to create a colored UIImage for confetti particles
    private func createColoredImage(color: UIColor) -> UIImage? {
        let image = UIImage(systemName: "square.fill") // Base image
        let renderer = UIGraphicsImageRenderer(size: image?.size ?? CGSize(width: 20, height: 20))
        return renderer.image { _ in
            color.setFill()
            image?.withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: image?.size ?? CGSize(width: 20, height: 20)))
        }
    }
}

#Preview {
    ConfettiView()
}
