//
//  SwiftUIView.swift
//  Boxx
//
//  Created by Supunme Nanayakkarami on 20.11.2023.
//

import SwiftUI
import Firebase

enum SearchOption{
    case dates
    case killo
    case location
    case price
}
struct dataTyp : Identifiable {
    
    var id : String
    var name : String
    var reg : String
}


struct SwiftUIView: View {
    
    @ObservedObject var dat = getData()
    var body: some View {
        NavigationView{
                    
                    ZStack(alignment: .top){
                        
                        GeometryReader{_ in
                            
                            // Home View....
                     
                            
                        }.background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                        
                        CustomSearchBa(data: self.$dat.datas).padding(.top, 20)
                        
                    }.navigationTitle("Вы уезжате?")

                    .navigationBarHidden(false)
                }
            }
        }

        struct SwiftUIView_Previews: PreviewProvider {
            static var previews: some View {
                SwiftUIView()
            }
        }

        struct CustomSearchBa : View {
            
            @State var txt = ""
            @Binding var data : [dataType]
            
            var body : some View{
                
                VStack(spacing: 0){
                    
                    HStack{
                        Image(systemName: "magnifyingglass")
                        TextField("Откуда выезжате?", text: self.$txt)
                            .font(.footnote)
                            .fontWeight(.semibold )
                        Image(systemName:"line.3.horizontal.decrease.circle")

                        
                        if self.txt != ""{
                            
                            Button(action: {
                                
                                self.txt = ""
                                
                            }) {
                                
                                Text("Отмена")
                            }
                            .foregroundColor(.red)
                            
                        }

                    }.padding()
                    
                    if self.txt != ""{
                        
                        if  self.data.filter({$0.name.lowercased().contains(self.txt.lowercased())}).count == 0{
                            
                            Text("No Results Found").foregroundColor(Color.black.opacity(0.5)).padding()
                        }
                        else{
                            
                        List(self.data.filter{$0.name.lowercased().contains(self.txt.lowercased())}){i in
                                    
                            NavigationLink(destination: Detail(data: i)) {
                                
                                Text(i.name)
                            }
                                    
                                
                            }.frame(height: UIScreen.main.bounds.height / 5)
                        }

                    }
                    
                    
                }.background(Color.white)
                .padding()
            }
        }

        class getDat : ObservableObject{
            
            @Published var datas = [dataType]()
            
            init() {
                
                let db = Firestore.firestore()
                
                db.collection("items").getDocuments { (snap, err) in
                    
                    if err != nil{
                        
                        print((err?.localizedDescription)!)
                        return
                    }
                    
                    for i in snap!.documents{
                        
                        let id = i.documentID
                        let name = i.get("name") as! String
                        let reg = i.get("reg") as! String
                        
                        self.datas.append(dataType(id: id, name: name, reg: reg))
                    }
                }
            }
        }




struct Detai : View {

    func setorder(order: Order, completion: @escaping (Result<OrdeI, Error>) -> ()) € ordersRef .document (order.id) .setData(order.representation) { error in
    if let error = error {
    completion(.failure(error))
    } else {
    completion(.success (order))

    var data : dataType
    @State var freeForm = ""
    @State var price = ""
    @State var numbkilo = 0
    @State var  startdate = Date()
    @State private var selectedOption: SearchOptions = .location
    

    
    var body : some View{
        
        VStack{
            Text("Укажите дату и время отправления из города")
            Text(data.name)
                .font(.title3)
            
            VStack(alignment: .leading){
                if selectedOption == .location{
                    Text("Заметка")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(){
                        Image(systemName: "pencil.circle")
                            .imageScale(.small)
                        TextField("Укажите что можете взять", text: $freeForm)
                            .font(.subheadline)
                    }
                    .frame(height: 60 )
                    .padding(.horizontal)
                    .overlay{RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.0)
                            .foregroundStyle(Color(.systemGray4))
                    }
                    
                } else{
                    CollapsedPickerView(title: "Описание", description: "Написать")
                }
            } .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .location ? 120  : 64)
                .onTapGesture {
                    withAnimation(){selectedOption = .location}
                }
            
            VStack(alignment: .leading){
                if selectedOption == .price {
                    Text ("Стоимость")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer ()
                    VStack{
                        TextField("Укажите цену за кг", text: $price)
                            .font(.subheadline)
                        Divider()
                        
                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    
                }else {
                    CollapsedPickerView(title: "Стоимость", description: "Руб")
                }
            }   .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .price ? 34  : 64)
            
                .onTapGesture {
                    withAnimation(){selectedOption = .price}
                }
            VStack(alignment: .leading){
                if selectedOption == .killo {
                    Text("Укажите вес в кг?")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Сколько кг свобдного места?")
                        .font(.subheadline)
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
                    CollapsedPickerView(title: "Сколько кг", description: "Добавить")
                }
            }.modifier(CollapsidDestModif())
                .frame(height: selectedOption == .killo ? 120  : 64)
                .onTapGesture {
                    withAnimation(){selectedOption = .killo}
                }
                .navigationTitle("Какого числа?")
                .padding(.top, 20)
            VStack(alignment: .leading){
                if selectedOption == .dates {
                    Text ("Когда уезжаете?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text ("Укажите дату")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    VStack{
                        DatePicker("Дата", selection:$startdate)
                            .datePickerStyle(.wheel)
                        Divider()
                        
                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    
                }else {
                    CollapsedPickerView(title: "Когда", description: "Даты")
                }
            }   .modifier(CollapsidDestModifier())
                .frame(height: selectedOption == .dates ?60  : 40)
                .onTapGesture {
                    withAnimation(){selectedOption = .dates}
                }
            Spacer()
                VStack{
                    Button(action : {
                        self.UploadPostservice(freeForm: self.freeForm)
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .resizable()
                            .frame(width:100, height: 100 )
                            .scaledToFit()
                            .padding(.vertical, 40)
                    }
                }
                
            }
        }
    }


            
struct CollapsidDestModi: ViewModifier {
    func body (content: Content) -> some View {
        content
        .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .shadow(radius: 10)
    }
}

struct CollapsedPicke: View {
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



        

