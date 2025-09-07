//
//  Buttons.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import Foundation
import SwiftUI
// This file is where all the common components in the app will be retrieved from
struct Logo : View {
    var body: some View {
        Text("FireLab")
            .font(.system(size: 36, weight: .black))
            .fontWeight(.black)
        // Here we adhere to HIG by using system default colors so that system dark mode management is possible
            .foregroundColor(.orange)
    }
}
struct BigButton : View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 36))
            .frame(width: 353, height: 127)
            .foregroundColor(.orange)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}

struct InputField : View {
    var label: String
    @Binding var fieldVar: String
    var placeholder: String
    var helpText: String?
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        // .firstTextBaseline properly aligns the text and inputfields
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)                    
                .padding(.trailing, 22)
                .frame(width:200, alignment: .leading)
                .overlay(alignment: .trailing) {
                            if let message = helpText {
                                HelpPopover(message: message)
                                    .padding(.leading, 8)
                                    .foregroundColor(.orange)
                            }
                        }
            TextField(placeholder,
                      text: $fieldVar)
            .keyboardType(.decimalPad)
            .frame(width: 150, height: 35)
            .border(Color.gray)
        }
        .padding(.vertical, 5)
    }
}

// This medium button is used on screen 2, the AddDetailsHub
struct MediumButton<Destination: View>: View {
    var text: String
    @ViewBuilder var destination: () -> Destination
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .foregroundColor(Color.orange)
                
                Text(text)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(.white)
                        .padding(.trailing, 7)
                        .font(.system(size: 40))
                }
            }
            .frame(width: 350, height: 61)
        }
        .padding(.vertical, 15)
        .buttonStyle(.plain)

    }
}
// Global small navigation/add button
struct SmallNavButton<Destination: View>: View {
    var text: String
    var fontSize: Int = 20
    var icon: String
    var width: Int
    var fgColor: Color
    var bgColor: Color
    var border: Color
    @ViewBuilder var destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            SmallButtonView(text: text,
                         fontSize: fontSize,
                         icon: icon,
                         width: width,
                         fgColor: fgColor,
                         bgColor: bgColor,
                         border: border,
                         )
        }
        .padding(.vertical, 15)
        .buttonStyle(.plain)
    }
}
struct SmallButtonView: View {
    var text: String
    var fontSize: Int = 20
    var icon: String
    var width: Int
    var fgColor: Color
    var bgColor: Color
    var border: Color


    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(bgColor)
            HStack {
                // We use a spacer here, and a spacer after the Text component so that the text lies in the middle of the space between the icon and the button edge
                Spacer()
                Text(text)
                    .font(.system(size: CGFloat(fontSize)))
                    .foregroundColor(fgColor)
                    .padding(.leading, 7)
                    .multilineTextAlignment(.center)
                Spacer()
                Image(systemName: icon)
                
                    .foregroundColor(fgColor)
                    .padding(.trailing, 7)
                    .font(.system(size: 40))
            }
        }
        .frame(width: CGFloat(width), height: 66)
        .background(
            RoundedRectangle(
                cornerRadius: 40)
                .stroke(border, lineWidth: 2)
            )
    }
}
struct HelpPopover: View {
    let message: String
    
    @State private var showHelp = false
    
    var body: some View {
        Button {
            showHelp.toggle()
        } label: {
            Image(systemName: "questionmark.circle")
                .fontWeight(.bold)
                .imageScale(.large)
        }
        .popover(isPresented: $showHelp, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Help")
                    .font(.headline)
                    .foregroundColor(.black)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Button("Got it") { showHelp = false }
                    .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: 280)
        }
        .presentationCompactAdaptation(.none) 
    }
}
struct DateField : View {
    var text: String
    var DOB: Binding<Date>
    var body: some View {
        HStack {
            Text(text)
                .frame(width: 200, alignment: .leading)
            DatePicker("",
                       selection: DOB,
                       displayedComponents: [.date])
            .frame(width: 150, height: 35)
        }
        .frame(width:300)
    }
}

struct InvestmentAllocationCard : View {
    @Binding var item: InvestmentItem
    @Binding var itemList: [InvestmentItem]
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.lightGray))
            .frame(width: 215, height: 200)
            .overlay(alignment: .topTrailing) {
                Button {
                    if let idx = itemList.firstIndex(of: item) {
                        itemList.remove(at: idx)
                    }
                } label: {
                    Image(systemName: "x.circle")
                        .font(.system(size: 25, weight: .bold))
                        .padding(10)
                }
                
            }
            .overlay(
                ZStack {
                    VStack {
                        Text(item.name)
                            .font(.system(size: 20, weight: .black))
                            .frame(width: 170, alignment: .leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Investment Portfolio Allocation")
                                .frame(width:100, alignment: .center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            TextField("%",
                                      text: $item.allocationPercent)
                            .keyboardType(.decimalPad)
                            .padding(.leading, 8)
                            .frame(width: 80, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white)
                            )
                        }
                    }
                }
            )
    }
}
