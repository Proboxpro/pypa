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

            Spacer()

            // Кнопка внизу
            Button {
                print("Нажали ПУП")
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
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}
