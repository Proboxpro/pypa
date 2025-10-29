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
                BaseTitle("Посылки")
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 45)
        }
        
        //        Spacer()
        
        //        Text("You are sending")
        DeliveryFormView()
            .ignoresSafeArea(.keyboard)
//        Spacer()
    }
}


struct DeliveryFormView: View {
    
    @State private var isPickerPresented = false
    
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
        ZStack {
            VStack(spacing: 20) {
                if !showNext {
                    firstScreen()
                        .ignoresSafeArea(.keyboard)
                } else {
                    secondScreen()
                }
                
                Spacer()
            }
            
            VStack(spacing: 150) {
                Spacer()
                
                chooseTransport()
//                    .opacity(isPickerPresented ? 0 : 1)
                    .offset(y: isPickerPresented ? 250 : 0)
                PypButtonRightImage(text: "ПУП", image: Image("chevron_right"), action: {
                    showNext.toggle()
                })
                .offset(y: isPickerPresented ? 150 : 0)
            }
            .opacity(isPickerPresented ? 0 : 1)
            .animation(.easeInOut, value: isPickerPresented)
        }
    }
    @State var calendarSelected: Bool = false
    
    @MainActor
    func firstScreen()-> some View{
        VStack {
            DatePickerView(isPickerPresented: $isPickerPresented)
                .onTapGesture {
                    calendarSelected.toggle()
                }
            Spacer()
        }
        .padding(.horizontal)
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
    
    @MainActor
    func chooseTransport()-> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("На чем?")
                .font(.system(size: 18, weight: .semibold))
                .padding(.leading)
            
            HStack(spacing: 30) {
                ForEach(TransportType.allCases, id: \.self) { type in
                    Button {
                        selectedTransport = type
                    } label: {
                        Image(type.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                        //                                .font(.system(size: 40))
                        //                                .foregroundColor(selectedTransport == type ? .blue : .gray)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedTransport == type ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1.5)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 10)
        
//    }
}

}


#Preview {
    DeliveryFormView()
}
