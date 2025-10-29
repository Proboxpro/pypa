//
//  YouAreSendingView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct YouAreLeavingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
        ZStack {
            BackTopLeftButtonView()
            AskQuestionButton()
            
            HStack {
                Text("Посылки")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 45)
        }
        
        Spacer()
        
//        Text("You are sending")
        DeliveryFormView()
            .ignoresSafeArea(.keyboard)
        Spacer()
    }
}





struct DeliveryFormView: View {
    @State private var from = ""
    @State private var to = ""
    @State private var date = ""
    @State private var selectedTransport: TransportType? = nil

    enum TransportType: String, CaseIterable {
        case plane = "plane"
        case train = "train"
        case car = "car"

        var iconName: String {
            switch self {
            case .plane: return "plane"
            case .train: return "rail"
            case .car: return "car"
            }
        }
    }
    
    @State var showNext: Bool = false
    
    //MARK: - second screen
    @State private var descriptionText = ""
    @State private var pricePerKg = ""
    @State private var selectedPrice: Int? = nil
    
    let presetPrices = [500, 2000, 4000]
    

    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
//            HStack {
//                Text("Посылки")
//                    .font(.system(size: 22, weight: .bold))
//                Spacer()
//            }
//            .padding(.horizontal)
//            Spacer()

            // Поля ввода
            if !showNext {
                firstScreen()
                    .ignoresSafeArea(.keyboard)
            } else {
                secondScreen()
            }

            Spacer()

            // Кнопка внизу
//            Button {
////                print("Нажали ПУП")
//                showNext.toggle()
//            } label: {
//                HStack {
//                    Text("ПУП")
//                        .fontWeight(.semibold)
//                    Image(systemName: "chevron.right")
//                        .font(.system(size: 16, weight: .semibold))
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.green)
//                .cornerRadius(12)
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 30)
        }
    }
    @State var calendarSelected: Bool = false
    
    @MainActor
    func firstScreen()-> some View{
//        VStack {
//            VStack(spacing: 12) {
            VStack {
//                TextField("Откуда", text: $from)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
//                TextField("Куда", text: $to)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                AutocompleteTextField()
//                    .opacity(calendarSelected ? 0 : 1)
//                    .offset(y: !calendarSelected ? 0 : -300)
//                    .frame(height: 1)
//                    .isHidden(true)
                
//                AutocompleteTextField()
//                    .isHidden()
//                    .ignoresSafeArea(.keyboard)
                
//                TextField("Когда", text: $date)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
//                Text("Когда")
//                    .foregroundStyle(Color.gray)
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 1).fill(Color.gray).frame(maxWidth: .infinity))
//                    
//                    .frame(alignment: .leading)
                
                DatePickerExampleView()
                    .onTapGesture {
                        calendarSelected.toggle()
                    }
                Spacer()
            }
            .padding(.horizontal)
            
                
            // Блок выбора транспорта
//            VStack(alignment: .leading, spacing: 10) {
//                Text("На чем?")
//                    .font(.system(size: 18, weight: .semibold))
//                    .padding(.leading)
//                
//                HStack(spacing: 30) {
//                    ForEach(TransportType.allCases, id: \.self) { type in
//                        Button {
//                            selectedTransport = type
//                        } label: {
//                            Image(type.iconName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 70, height: 70)
////                                .font(.system(size: 40))
////                                .foregroundColor(selectedTransport == type ? .blue : .gray)
//                                .padding(10)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(selectedTransport == type ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1.5)
//                                )
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .padding(.top, 10)
                
//        }
    }
    
    
    @MainActor
    func secondScreen()-> some View {
            VStack(alignment: .leading, spacing: 20) {
                // Описание
                Text("Описание")
                    .font(.system(size: 18, weight: .semibold))

                TextEditor(text: $descriptionText)
                    .frame(height: 100)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )

                // Стоимость кг
                Text("Стоимость кг.")
                    .font(.system(size: 18, weight: .semibold))

                TextField("Введите сумму", text: $pricePerKg)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )

                // Кнопки с вариантами
                HStack(spacing: 30) {
                    ForEach(presetPrices, id: \.self) { price in
                        Button {
                            selectedPrice = price
                            pricePerKg = "\(price)"
                        } label: {
                            HStack {
                                Text("\(price)")
                                Text("₽")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                //                                    .fill(Int(pricePerKg) == price ? Color.blue.opacity(0.2) : Color.clear)
                                    .fill(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Int(pricePerKg) == price ? Color.blue.opacity(0.6) : Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        .foregroundColor(Int(pricePerKg) == price ? .blue.opacity(0.6) : .gray)
//                        .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
//                Spacer()
            }
            .padding()
        }
    
}


struct DatePickerExampleView: View {
    @State private var isPickerPresented = false
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

struct AutocompleteTextField: View {
    @State private var text = ""
//    @State private var suggestions = ["Москва", "Мюнхен", "Милан", "Мадрид", "Минск"]
    @State private var suggestions = ["V1", "V2", "V$", "Мадрид", "Минск"]

    var body: some View {
//        ZStack(alignment: .topLeading) {
        VStack {
            TextField("Куда", text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
                .padding(.horizontal)
                .zIndex(1)
            
            if !text.isEmpty {
//                let filtered = suggestions.prefix(1)
                let filtered = suggestions.filter { $0.lowercased().contains(text.lowercased()) }.prefix(1)
                if !filtered.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filtered, id: \.self) { item in
                            Button {
                                text = item
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Text(item)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                            }
//                            Divider()
                        }
                    }
//                    .opacity(filtered.isEmpty ? 1 : 0)
                    .animation(.default, value: text.isEmpty)
//                        .hidden(!text.isEmpty)
//                    .background(Color.green)
//                    .frame(height: 54 * 1)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                            .background(Color.white)
//                            .cornerRadius(10).padding(.horizontal)
//                    )
                    .padding(.horizontal, 25)
//                    .padding(.top, 54)
//                    .overlay(RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                        .background(Color.white)
//                        .cornerRadius(10).padding(.horizontal))
                    //                    .shadow(radius: 3)
//                    .zIndex(1000)
                }
//                    .frame(height: 54 * 4)
            }
        }
//        .frame(height: 54 * 2)
        .background(Color.green)
        .allowsHitTesting(true)
    }
}

#Preview {
    AutocompleteTextField()
}

//struct AutocompleteTextField: View {
//    @State private var text = ""
//    @State private var suggestions = ["Москва", "Мюнхен", "Милан", "Мадрид", "Минск"]
//    @State private var showSuggestions = false
//    
//    var filteredSuggestions: [String] {
//        suggestions.filter {
//            !text.isEmpty && $0.lowercased().contains(text.lowercased())
//        }
//    }
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            TextField("Куда", text: $text, onEditingChanged: { editing in
//                withAnimation {
//                    showSuggestions = editing && !filteredSuggestions.isEmpty
//                }
//            })
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .onChange(of: text) { _ in
//                withAnimation {
//                    showSuggestions = !filteredSuggestions.isEmpty
//                }
//            }
//            
//            // Выпадающий список
//            if showSuggestions {
//                VStack(spacing: 0) {
//                    ForEach(filteredSuggestions, id: \.self) { item in
//                        Button {
//                            text = item
//                            hideKeyboard()
//                            withAnimation { showSuggestions = false }
//                        } label: {
//                            Text(item)
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.white)
//                        }
//                        Divider()
//                    }
//                }
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.white)
//                        .shadow(radius: 3)
//                )
//                .padding(.top, 44) // чтобы появлялось прямо под полем
//                .zIndex(1) // главное — чтобы было поверх других вью
//            }
//        }
//    }
//}
//
//// Хелпер для скрытия клавиатуры
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}

extension View {
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden { self.hidden() } else { self }
    }
}
