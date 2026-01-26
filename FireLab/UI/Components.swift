//
//  Buttons.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import Foundation
import SwiftUI
/// This Components file is where all the common components in the app will be retrieved from, such as navigation buttons and input fields.


/// This input field is a component to be used all throughout the program to retrieve any data, numeric or textual.
struct InputField : View {
    var label: String
    @Binding var fieldVar: String
    var placeholder: String
    var helpText: String?
    var fieldWidth: Int?
    var helpPadding: CGFloat?
    
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
                                    .offset(x: helpPadding ?? 8)
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

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .frame(width: CGFloat(200), alignment: .leading)
                .padding(.leading, 22)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .frame(width: CGFloat(150), alignment: .trailing)
                .padding(.trailing, 22)
            
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

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
    var hint: String?
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
                         hint: hint,
                         height: height,
                         )
        }
        .padding(.vertical, 15)
        .buttonStyle(.plain)
        .accessibilityLabel(text)
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
    var hint: String?
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
        .accessibilityHint(hint ?? "")
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

/// This is a template for a grey-colored card that is used in a screen with scrollable view of cards, complete with animations and gestures
struct ItemCard<Content: View> : View {
    let content: Content
    let rectWidth: CGFloat
    let rectHeight: CGFloat
    var maxDragWidth: CGFloat
    var deleteAccLabel: String
    var deleteAccHint: String
    
    
    var onEdit: () -> Void
    var onDelete: () -> Void
    @State private var isHorizontalGesture = false
    @State private var gestureLocked = false

    // To make animation look better, we use this additional offset variable
    @State private var cardOffsetX: CGFloat = 0
    @State private var trashOffsetX: CGFloat = 0
    @State private var pencilOffsetX: CGFloat = 0
    @State private var pencilBounceToken: Int = 0
    @State private var wasEditCommitted = false
    @State private var deleteBounceToken: Int = 0
    @State private var wasDeleteCommitted = false
    
    @State private var iconOpacity: Double = 1


    private var editCommitted: Bool {
        pencilOffsetX <= -maxDragWidth * 1.7
    }
    
    private var deleteCommitted: Bool {
        trashOffsetX >= maxDragWidth * 1.7
    }
    
    init(
            rectWidth: CGFloat,
            rectHeight: CGFloat,
            maxDragWidth: CGFloat,
            deleteAccLabel: String,
            deleteAccHint: String,
            onEdit: @escaping () -> Void,
            onDelete: @escaping () -> Void,
            @ViewBuilder content: () -> Content
        ) {
            self.rectWidth = rectWidth
            self.rectHeight = rectHeight
            self.maxDragWidth = maxDragWidth
            self.deleteAccLabel = deleteAccLabel
            self.deleteAccHint = deleteAccHint
            self.onEdit = onEdit
            self.onDelete = onDelete
            self.content = content()
        }

    
    var body: some View {
        ZStack {
            
            Image(systemName: "trash.circle.fill")
                .offset(x: trashOffsetX)
                .font(.system(size: 35))
                .symbolEffect(.bounce, value: deleteBounceToken)
                .opacity(iconOpacity)
            Image(systemName: "pencil.circle.fill")
                .offset(x: pencilOffsetX)
                .font(.system(size: 35))
                .symbolEffect(.bounce, value: pencilBounceToken)
                .opacity(iconOpacity)

            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.lightGray))
                .frame(width: rectWidth, height: rectHeight)
                .overlay(alignment: .topTrailing) {
                    // Add .destructive annotation as per accessibility HIG
                    Button(role: .destructive) {
                        // Ensures icons behind the button do not appear when the cross button is clicked
                        iconOpacity = 0
                        // Adds animation for specifically when the card is removed
                        withAnimation(.easeInOut) {
                            onDelete()
                        }
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 25, weight: .bold))
                            .padding(10)
                        // Hides this icon from being dictated by voiceover
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel(deleteAccLabel)
                    .accessibilityHint(deleteAccHint)
                }
                .overlay(content)
                .offset(x: cardOffsetX)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            let dx = value.translation.width
                            let dy = value.translation.height
                            
                            // Decide intent ONCE at the start of the gesture
                            if !gestureLocked {
                                // Strong horizontal bias to avoid stealing vertical scrolls
                                if abs(dx) > abs(dy) * 1.5 {
                                    isHorizontalGesture = true
                                    gestureLocked = true
                                } else if abs(dy) > abs(dx) {
                                    // Vertical gesture → allow ScrollView to handle it
                                    gestureLocked = true
                                    return
                                } else {
                                    // Not enough information yet
                                    return
                                }
                            }
                            
                            // If horizontal gesture is locked, move the card
                            guard isHorizontalGesture else { return }
                            
                            // If the user drags to the left, offset the hidden trash icon to the right into view
                            if dx < 0 {
                                /*
                                 Move the trash icon to the right at a speed of 1.7x the gesture translation.
                                 Set a maximum travel distance of maxDragWidth * 1.7
                                 */
                                trashOffsetX = min(dx * -1.7, maxDragWidth * 1.7)

                                if deleteCommitted && !wasDeleteCommitted {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    deleteBounceToken += 1
                                }
                                wasDeleteCommitted = deleteCommitted
                            }
                            // Else if the user drags to the right, move the pencil icon to the right
                            else {
                                pencilOffsetX = max(dx * -1.7, -maxDragWidth * 1.7)

                                if editCommitted && !wasEditCommitted {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    pencilBounceToken += 1
                                }
                                wasEditCommitted = editCommitted
                            }
                            
                            let clamped = min(
                                max(dx, -maxDragWidth),
                                maxDragWidth
                            )
                            cardOffsetX = clamped
                        }
                        .onEnded { value in
                            defer {
                                // Reset gesture state for next interaction
                                isHorizontalGesture = false
                                gestureLocked = false
                                wasEditCommitted = false
                                wasDeleteCommitted = false
                            }
                            
                            guard isHorizontalGesture else { return }
                            
                            let dx = value.translation.width
                            
                            if dx <= -maxDragWidth {
                                cardOffsetX = -maxDragWidth
                                
                                withAnimation(.easeInOut) {
                                    onDelete()
                                }
                            } else if dx >= maxDragWidth {
                                withAnimation(.easeInOut) {
                                    cardOffsetX = 0
                                    trashOffsetX = 0
                                    pencilOffsetX = 0

                                }
                                onEdit()
                            } else {
                                // Snap back to center
                                withAnimation(.easeOut) {
                                    cardOffsetX = 0
                                    trashOffsetX = 0
                                    pencilOffsetX = 0
                                }
                            }
                        }
                )
        }
        .frame(
            width: rectWidth + maxDragWidth * 2,
            height: rectHeight
        )
    }
}

/// This is a form error text component that is used in every form in the app
struct FormErrorText: View {
    let message: String?
    @AccessibilityFocusState.Binding var isFocused: Bool

    var body: some View {
        if let msg = message {
            Text(msg)
                .foregroundStyle(.red)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 400, alignment: .center)
                .padding(.horizontal)
                // Accessibility: mark and focus the error
                .accessibilityLabel("Error: \(msg)")
                .accessibilityHint("Fix the fields below, then try again.")
                // read before other content
                .accessibilitySortPriority(1000)
                .accessibilityAddTraits(.isStaticText)
                .accessibilityFocused($isFocused)
        }
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

                InputField(label: "Loan Name", fieldVar: $textField, placeholder: "", helpText: "Testing", fieldWidth: 200, helpPadding: 20)
                DateField(text: "Date", DOB: $dateField)
            }
            .padding()
        }
        .previewLayout(.sizeThatFits) // optional: faster + fewer layout surprises
    }
}
