//
//  CalendarView.swift
//  Boxx
//
//  Created by namerei on 29.10.2025.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var isPickerPresented: Bool
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Это та view, на которую нажимаем
            Button(action: {
                withAnimation {
                    isPickerPresented.toggle()
                }
            }) {
                HStack {
                    Text("Когда:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(selectedDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity) // ← растягивает на всю ширину
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(16)
            }
            
            // Сам календарь, показывается при isPickerPresented = true
            if isPickerPresented {
                DatePicker(
                    "Выберите дату и время",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}


struct BaseTitle: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
    }
}
