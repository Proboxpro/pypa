//
//  YouAreSendingView.swift
//  Boxx
//
//  Created by namerei on 26.10.2025.
//

import SwiftUI

struct YouAreLeavingView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var showNext: Bool = false
    
    var body: some View {
        
        ZStack {
            VStack {
                ZStack {
                    
                    BackTopLeftButtonView(showNext: $showNext)
                    AskQuestionButton()
                    
                    HStack {
                        BaseTitle("Посылки")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .offset(y: 45)
                    
                }
                Spacer()
            }
            .zIndex(1)
//            .background(Color.green)
            
            //        Spacer()
            
            //        Text("You are sending")
            VStack {
                DeliveryFormView(showNext: $showNext)
                    .ignoresSafeArea(.keyboard)
                    .offset(y: 60)
                Spacer()
            }
            .zIndex(2)
//            .background(Color.orange)
        }
    }
}


struct DeliveryFormView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showNext: Bool
    @State private var isPickerPresented = false
    
    let presetPrices = [500, 2000, 4000]
    @State private var testSuggestions : [String] = []

    //MARK: Info:
    @State private var from = ""
    @State private var to = ""
    @State private var date = Date()
    @State private var selectedTransport: TransportType = .plane
    
    @State private var descriptionText = ""
    @State private var pricePerKg = ""
    @State private var selectedPrice: Int? = nil
    
    
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
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if !showNext {
                    firstScreen()
                        .ignoresSafeArea(.keyboard)
                } else {
                    secondScreen()
                        .offset(y: 10)
                }
                
                Spacer()
            }
            
            VStack(spacing: 10 /*60*/) {
                Spacer()
                
                if !showNext {
                    chooseTransport()
                        .offset(y: isPickerPresented ? 250 : 0)
                }
                
                departureLabel()
                
                PypButtonRightImage(text: "ПУП", image: Image("chevron_right"), action: {
                    Task {
                       await handlePypAction()
                    }
                })
                .offset(y: isPickerPresented ? 150 : 0)
            }
            .offset(y: -60)
            .opacity(isPickerPresented ? 0 : 1)
            .animation(.easeInOut, value: isPickerPresented)
        }
        .onChange(of: viewModel.isAlertPresented) { _, newValue in
            if newValue == false && checkFormValidity() && to != from {
                dismiss()
            }
        }
    }
    
    
    @MainActor
    func firstScreen()-> some View{
        VStack {
            AutocompleteTextField(placeholder: "Откуда", textToSave: $from, suggestions: testSuggestions)
            AutocompleteTextField(placeholder: "Куда", textToSave: $to, suggestions: testSuggestions)
            DatePickerView(isPickerPresented: $isPickerPresented, selectedDate: $date)
            
            Spacer()
        }
        .onAppear {
            testSuggestions = viewModel.allPosibleCityes.compactMap({$0.name})
        }
//        .background(Color.orange)
        .padding(.top, 40)
        .padding(.horizontal)
    }
    
    @MainActor
    func departureLabel()-> some View {
        VStack {
            Text("откуда \(from)")
            Text("куда \(to)")
            Text("когда \(date)")
            Text("на чем \(selectedTransport.rawValue)")
            Text("описание \(descriptionText)")
            Text("цена за кг \(pricePerKg)")
        }
    }
    
    @FocusState private var isFocused: Bool
    
    @MainActor
    func secondScreen()-> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Описание")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.8))
            
            
            TextEditor(text: $descriptionText)
                .frame(height: 80)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Готово") {
                            isFocused = false // скрыть клавиатуру
                        }
                    }
                }
            
            Text("Стоимость кг.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.8))
            
            TextField("Введите сумму", text: $pricePerKg)
                .keyboardType(.numberPad)
                .focused($isFocused)
//                .submitLabel(.done)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
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
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Int(pricePerKg) == price ? Color.blue.opacity(0.6) : Color.gray.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    .foregroundColor(Int(pricePerKg) == price ? .blue.opacity(0.6) : .gray)
                }
            }
            .frame(maxWidth: .infinity)
            
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
    
    //MARK: - action
    private func handlePypAction() async {
        if !showNext {
            showNext.toggle()
        } else if checkFormValidity() && to != from {
            viewModel.presentAlert(kind: .success, message: "✅ Обьявление успешно создано!")
            await viewModel.uploadPostservice(cityTo: to, cityFrom: from, startdate: date, pricePerKillo: Double(pricePerKg) ?? 0.0, transport: selectedTransport.rawValue)
        } else {
            viewModel.presentAlert(kind: .error, message: "❌ Некоторые поля заполнены некорректно")
        }
    }
    
    private func checkFormValidity() -> Bool {
        !to.isEmpty && !from.isEmpty
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    DeliveryFormView(showNext: .constant(false))
}

#Preview {
    YouAreLeavingView().environmentObject(AuthViewModel())
}
