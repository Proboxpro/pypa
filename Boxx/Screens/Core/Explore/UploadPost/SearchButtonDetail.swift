//
//  SearchButtonDetail.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
//

import SwiftUI
enum SearchButtonDetail{
    case location
    case dates
    case killo
}

struct SearchButtonDetail: View {
    @Binding var show: Bool
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var numbkilo = 0
    
struct SearchButtonDetail: View {
    var body: some View {
        VStack{
            HStack{
                Button {
                    withAnimation(){
                        show.toggle()
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                        .foregroundStyle(.black)
                }
                Spacer()
                if !destination.isEmpty{
                    Button("Clear"){
                         destination = ""
                    }
                        .font(.subheadline)
                        .foregroundStyle(.black)
                        .fontWeight(.semibold)
                }

            }
            .padding()
            

            VStack(alignment: .leading){
                if selectedOption == .location{
                    Text("Куда отправляем?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .imageScale(.small)
                        TextField("Найти направление", text: $destination)
                            .font(.subheadline)
                    }
                    .frame(height: 44 )
                    .padding(.horizontal)
                    .overlay{RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.0)
                            .foregroundStyle(Color(.systemGray4))
                    }
                    
                } else{
                    CollapsedPickerView(title: "Куда", description: "Выбрать")
                }
               
                
            } .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .location ? 120  : 64)
                .onTapGesture {
                    withAnimation(){selectedOption = .location}
                }
            
            
            VStack(alignment: .leading){
                if selectedOption == .dates {
                    Text ("Когда хотите отправить?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    VStack{
                        DatePicker("Начиная", selection:$startDate , displayedComponents: .date)
                    
                        Divider()
                        
                        DatePicker("До", selection:$endDate , displayedComponents: .date)

                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                }else {
                        CollapsedPickerView(title: "Когда", description: "Даты")
                    }
            }   .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .dates ? 180  : 64)
            
            .onTapGesture {
                withAnimation(){selectedOption = .dates}
                }
            VStack(alignment: .leading){
                if selectedOption == .killo {
                    Text("Сколько отправить?")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Stepper {
                        Text("\(numbkilo) КГ")
                    } onIncrement: {
                        numbkilo += 1
                    } onDecrement: {
                        guard numbkilo > 0 else {return}
                        numbkilo -= 1
                    }
                }else {
                    CollapsedPickerView(title: "Сколько", description: "Добавить")
                    }
            } .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .killo ? 120  : 64)

            .onTapGesture {
                withAnimation(){selectedOption = .killo}

                }
            Spacer()

        }    }
}

struct CollapsidDestModifier: ViewModifier {
    func body (content: Content) -> some View {
        content
        .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .shadow(radius: 10)
    }
}

    struct CollapsedPickerView: View {
        let title: String
        let description: String
        var body: some View {
            VStack{
                HStack{
                    Text(title)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(description)
                }
                .fontWeight(.semibold)
                .font(.subheadline)
                
            }
        }
    }
}

struct SearchButtonDetail_Previews: PreviewProvider {
    static var previews: some View {
        SearchButtonDetail(show: .constant(false))
    }
}
