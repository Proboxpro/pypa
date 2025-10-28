//
//  YouAreSendingView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct YouAreSendingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
        ZStack {
            BackTopLeftButtonView()
            AskQuestionButton()
        }
        
        Spacer()
        
//        Text("You are sending")
        DeliveryFormView()
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
            case .plane: return "paperplane"
            case .train: return "tram.fill"
            case .car: return "car.fill"
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
            HStack {
                Text("Посылки")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
            }
            .padding(.horizontal)

            // Поля ввода
            if !showNext {
                firstScreen()
            } else {
                secondScreen()
            }

            Spacer()

            // Кнопка внизу
            Button {
//                print("Нажали ПУП")
                showNext.toggle()
            } label: {
                HStack {
                    Text("ПУП")
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
//            .ignoresSafeArea(.keyboard)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    @MainActor
    func firstScreen()-> some View{
        VStack {
            VStack(spacing: 12) {
                TextField("Откуда", text: $from)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Куда", text: $to)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Когда", text: $date)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // Блок выбора транспорта
            VStack(alignment: .leading, spacing: 10) {
                Text("На чем?")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.leading)
                
                HStack(spacing: 30) {
                    ForEach(TransportType.allCases, id: \.self) { type in
                        Button {
                            selectedTransport = type
                        } label: {
                            Image(systemName: type.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(selectedTransport == type ? .blue : .gray)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedTransport == type ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
        }
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
                HStack(spacing: 16) {
                    ForEach(presetPrices, id: \.self) { price in
                        Button {
                            selectedPrice = price
                            pricePerKg = "\(price)"
                        } label: {
                            Text("\(price) ₽")
                                .fontWeight(.medium)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedPrice == price ? Color.blue.opacity(0.2) : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedPrice == price ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                )
                        }
                        .foregroundColor(selectedPrice == price ? .blue : .gray)
                    }
                }

//                Spacer()
            }
            .padding()
        }
    
}
