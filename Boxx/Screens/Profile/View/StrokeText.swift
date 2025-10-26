//
//  StrokeText.swift
//  Boxx
//
//  Created by namerei on 19.10.2025.
//

import SwiftUI
import UIKit

struct StrokeText: View {
    let name: String
//    let surName: String
    let strokeWidth: Double = 0.34

    var body: some View {
//        VStack(spacing: -20) {
//            Text(par())
        Text(name)
//            .scaleEffect(0.8)
//            .lineSpacing(-20)
            

//            Text(surName)
                
//        }
            .font(.system(size: fontSize(for: name)))
        .fontWeight(.bold)
        .foregroundStyle(Color.white)
        .shadow(color: Color.teal, radius: strokeWidth, x: strokeWidth, y : strokeWidth)
        .shadow(color: Color.teal, radius: strokeWidth, x: -strokeWidth, y : -strokeWidth)
        .shadow(color: Color.teal, radius: strokeWidth, x: strokeWidth, y : -strokeWidth)
        .shadow(color: Color.teal, radius: strokeWidth, x: -strokeWidth, y : strokeWidth)
    }
    
    private func fontSize(for text: String) -> CGFloat {
        let numChars = text.count
        // Формула: fontSize = -0.8333 * numChars + 64
        let size = -0.8333 * CGFloat(numChars) + 64
        return max(size, 12) // минимальный размер 12, чтобы не ушло в отрицательные значения
    }

    
    func par()->AttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 0 // желаемая высота строки
        paragraph.maximumLineHeight = 0
        paragraph.alignment = .center
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 55, weight: .bold),
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.white // цвет заливки (если нужно)
        ]
        
        let ns = NSAttributedString(string: name, attributes: attrs)
        
        // Конвертируем в AttributedString для использования в SwiftUI
        let attr = try! AttributedString(ns, including: \.uiKit)
        
        return attr
    }
    
}

#Preview {
    StrokeText(name: "Никита Павлов")
}


