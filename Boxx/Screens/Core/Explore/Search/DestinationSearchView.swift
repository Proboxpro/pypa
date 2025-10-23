//
//  DestinationSearchView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 17.11.2023.
//

import SwiftUI

enum DestinationSearchOptions{
    case location
    case dates
    case killo
}


@available(iOS 17.0, *)
struct DestinationSearchView: View {
//    @Binding var startDate: Date
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var viewModel: AuthViewModel
//    @EnvironmentObject var searchViewModel: DestinationSearchViewModel
    
    @State private var recipient: String = ""

    @Binding var show: Bool
    @Binding var parameters: SearchParameters
//    @Binding var cityName : String
    
    @State private var destination = ""
//    @State private var startDate = Date()
//    @State private var endDate = Date()
    @State private var numbkilo = 0

    @State var search = ""

    var filtereduser: [City] {
        guard !search.isEmpty else { return viewModel.city}
        return viewModel.city.filter{ $0.name.localizedCaseInsensitiveContains (search) }
    }

    @State private var selectedOption: DestinationSearchOptions = .location
        
    var body: some View {
        VStack{
            DeleteSearchInputView()
            DestinationView()
            DateSection()
            SearchButton()
        }
    }
    
    
    //MARK: - Views
    func DeleteSearchInputView()->some View {
        HStack{
            Button {
                withAnimation(){
                    parameters.cityName = ""
                    show.toggle()
                }
            } label: {
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
                    .foregroundStyle(.black)
            }
            
            Spacer()
            if search != "" {
                Button("Удалить"){
                    search = ""
                }
                .font(.subheadline)
                .foregroundStyle(.red)
                .fontWeight(.semibold)
            }
            
        }
        .padding()
    }
    
    func DestinationView()->some View {
        VStack(alignment: .leading){
            if selectedOption == .location{
                VStack{
                    Text("Куда отправляем?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(alignment: .center){
                        Image(systemName: "magnifyingglass")
                        TextField("Город получения", text: self.$search)
                            .font(.subheadline)
                            .fontWeight(.semibold )
                    } .frame(height: 44 )
                        .padding(.horizontal)
                        .overlay{RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(Color(.systemGray4))
                        }
                    if self.search != ""{
                        if  self.viewModel.city.filter({$0.name.lowercased().contains(self.search.lowercased())}).count == 0{
                            VStack(alignment: .leading){
                                Text("Не найден")
                            }
                            
                            
                        }
                        else{
                            //                                print("CITY's: \(filtereduser)")
                            VStack(alignment: .leading){
                                ForEach(filtereduser.prefix(1)) { item in
                                    CityView(city: item)
                                        .onTapGesture {
                                            search = item.name
                                        }
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: 60 )
                            .padding(.horizontal)
                            .overlay{RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundStyle(Color(.systemGray4))
                            }
                        }
                    }
                }
            } else {
                CollapsedPickerView(title: "Куда", description: "Выбрать")
            }
            
        } .modifier(CollapsidDestModifier())
            .frame(height: selectedOption == .location ? 120  : 64)
            .onTapGesture {
                withAnimation(){selectedOption = .location}
            }
    }
    
    
    func DateSection()->some View {
        VStack(alignment: .leading){
            if selectedOption == .dates {
        
                Text ("Когда хотите отправить?")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text ("Укажите примерные даты")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                VStack{
                    DatePicker("Начиная", selection: $parameters.startDate, displayedComponents: .date)
                        .onChange(of: parameters.startDate) { oldValue, newValue in
                            parameters.datesIsSelected = true
                        }
                    Divider()
                    DatePicker("До", selection:$parameters.endDate , displayedComponents: .date)
                        .onChange(of: parameters.endDate) { oldValue, newValue in
                            parameters.datesIsSelected = true
                        }
                }
                .foregroundStyle(.gray)
                .font(.subheadline)
                .fontWeight(.semibold)
                
                
            } else {
                let title = "Когда                                                               "
                CollapsedPickerView(title: title, description: "Даты")
                    .onTapGesture {
                        withAnimation(){
                            selectedOption = .dates
                        }
                    }
            }
            
        } 
        .modifier(CollapsidDestModifier())
        .frame(height: selectedOption == .dates ? 180  : 64)
        .onAppear() {
            parameters.endDate = Date()
            parameters.startDate = Date()
        }
    }
    
    
    func SearchButton()->some View {
        Button {
            //MARK: - handle action
            Task {
//                print("All city's \(viewModel.city.compactMap({$0.name}))")
//                print("CITY's: \(filtereduser.compactMap({$0.name}))" )
                
                if filtereduser.compactMap({$0.name}).filter({$0 == search}).isEmpty {
                    print("NOTHING FOUND")
                } else {
//                    print("Search: \(search)")
//                    print("GO TO MAINSEARCH")
//                    
//                    print("DAte: \($parameters.startDate)")
                    
                    //MARK: - переход обратно на экран MainSearch
                    
                    withAnimation {
                        parameters.cityName = search
                        show.toggle()
                    }
                }
            }
        } label: {
            HStack{
                Text ("Search")
                    .fontWeight (.semibold)
                Image (systemName: "arrow.right")
                
            }
            . foregroundColor (.white)
            .frame(width:UIScreen.main.bounds.width-32, height: 48)
            
        }
        .background (Color (.black))
        .cornerRadius (10)
        .padding(.top,25)
        //        }
    }
    
    
//    func convertDate() {
//        if let date = viewModel.orders[0].startdate.toDate() {
//            let outputDateFormatter = DateFormatter()
//            outputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//            let outputDateString = outputDateFormatter.string(from: date)
//            print("Конвертированная дата: \(outputDateString)")
//        } else {
//            print("Ошибка: неверный формат входной строки")
//        }
//    }
    
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

//MARK: Preview

//@available(iOS 17.0, *)
//struct Previews_Container: PreviewProvider {
//    struct Container: View {
//        @State var show = true
//        @State var cityName = "Мончегорск"
//        var body: some View {
//            DestinationSearchView(show: $show, cityName: $cityName)
//        }
//    }
//    
//    static var previews: some View {
//        Container()
//    }
//}
