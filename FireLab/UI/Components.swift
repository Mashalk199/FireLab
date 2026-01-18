//
//  Buttons.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import Foundation
import SwiftUI
/// This Components file is where all the common components in the app will be retrieved from, such as navigation buttons and input fields.

/// This BigButton is displayed on the first page, letting users decide whether to perform a new calculation or visit past calculations.
struct BigButton : View {
    var text: String
    var hint: String
    var body: some View {
        Text(text)
            .font(.system(size: 36))
            .frame(width: 353, height: 127)
            .foregroundColor(.orange)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.black, lineWidth: 1)
            )
            .accessibilityLabel(text)
            .accessibilityHint(hint)
    }
}

/// This input field is a component to be used all throughout the program to retrieve any data, numeric or textual.
struct InputField : View {
    var label: String
    @Binding var fieldVar: String
    var placeholder: String
    var helpText: String?
    var fieldWidth: Int?
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            
                .frame(width: CGFloat(200), alignment: .leading)
                .overlay(alignment: .trailing) {
                            if let message = helpText {
                                HelpPopover(message: message)
                                    .padding(.leading, 8)
                                    .foregroundColor(.orange)
                            }
                        }
                .padding([.leading], 22)

            Spacer()
            TextField(placeholder,
                      text: $fieldVar)
            .keyboardType(.decimalPad)
            .frame(width: CGFloat(150), height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5))
            )
            .padding(.trailing, 22)
        }
        .frame(width: CGFloat(fieldWidth ?? 350))
        .padding(.vertical, 5)
        // We will also add accessibility labels
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(fieldVar.isEmpty ? "Empty" : fieldVar))
        .accessibilityHint(Text(helpText ?? ""))
    }
}

/// Implements a basic date input field.
struct DateField : View {
    var text: String
    var DOB: Binding<Date>
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(text)
                .frame(width: 200, alignment: .leading)
            Spacer()
            DatePicker("",
                       selection: DOB,
                       displayedComponents: [.date])
            .frame(width: 150, height: 35)
            .accessibilityLabel(text)
        }
        .frame(width:CGFloat(350))
    }
}


/// This medium button is used on screen 2, the AddDetailsHub. Giving users different options for different features they can use.
struct MediumButton<Destination: View>: View {
    var text: String
    var hint: String
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
        .accessibilityLabel(text)
        .accessibilityHint(hint)
    }
}
/// Global small navigation/add button. This cannot help perform user input validation.
struct SmallNavButton<Destination: View>: View {
    var text: String
    var fontSize: Int = 20
    var icon: String
    var width: Int
    var fgColor: Color
    var bgColor: Color
    var border: Color
    var hint: String
    var height: Int? = nil

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
                         height: height,
                         )
        }
        .padding(.vertical, 15)
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityHint(hint)
    }
}
/** This is simply a view of the small button component, abstracted away into a separate view.
    It is possible to use this as a view for an actual button that can perform navigation and input validation.
 */
struct SmallButtonView: View {
    var text: String
    var fontSize: Int = 20
    var icon: String?
    var width: Int
    var fgColor: Color
    var bgColor: Color
    var border: Color
    var height: Int?

    
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
                if icon != nil {
                    Image(systemName: icon ?? "arrow.right.circle")
                        .foregroundColor(fgColor)
                        .padding(.trailing, 7)
                        .font(.system(size: 40))
                }
                
            }
        }
        .frame(width: CGFloat(width), height: CGFloat(height ?? 66))
        .background(
            RoundedRectangle(
                cornerRadius: 40)
                .stroke(border, lineWidth: 2)
            )
    }
}
/** This displays a popover for the user to see additional information about context for details they need to provide. */
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









#Preview("Component Examples") {
    PreviewHarness()
}

private struct PreviewHarness: View {
    @State private var textField = ""
    @State private var dateField = Date()
    @State private var loanItems: [LoanItem] = [
        LoanItem(name: "HELP Loan", outstandingBalance: "40000", interestRate: "3.5", minimumPayment: "400"),
        LoanItem(name: "Car Loan",  outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "10000"),
    ]
    @State private var portfolioItems: [PortfolioItem] = [
        PortfolioItem(name: "VDHG", type: .etf, value: "1234.56", expectedReturn: "3"),
        PortfolioItem(name: "AusGov Bonds", type: .bond, value: "789", expectedReturn: "3"),
        PortfolioItem(name: "DB Crude Oil Long Exchange Traded Fund", type: .bond, value: "", expectedReturn: "3")
    ]

    var body: some View {
        NavigationStack {
            VStack {
//                PortfolioCard(item: $portfolioItems[0], itemList: $portfolioItems)
//                LoanCard(item: $loanItems[0], itemList: $loanItems)

                SmallNavButton(
                    text: "Go to Details",
                    fontSize: 18,
                    icon: "arrow.right.circle",
                    width: 200,
                    fgColor: .white,
                    bgColor: .blue,
                    border: .blue,
                    hint: "Navigates to the details screen"
                ) {
                    Text("This is the destination view").font(.title).padding()
                }

                InputField(label: "Loan Name", fieldVar: $textField, placeholder: "", fieldWidth: 200)
                DateField(text: "Date", DOB: $dateField)
            }
            .padding()
        }
        .previewLayout(.sizeThatFits) // optional: faster + fewer layout surprises
    }
}
