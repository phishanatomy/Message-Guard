//
//  ContentView.swift
//  Message Guard
//
//  Created by Jonathan Gregson on 2/7/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AboutView()
                .tabItem {
                    Image(systemName: "questionmark.diamond.fill")
                    Text("About")
                }
            SetupView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Setup")
                }
            AnalyzeView()
                .tabItem {
                    Image(systemName: "text.magnifyingglass")
                    Text("Analyze")
                }
        }
    }
}

struct TitleView<Content: View>: View {
    let test = getLeetVariations(initialString: "tttt")
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            self.content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(uiImage: UIImage(named: "AppIcon-Transparent-128") ?? UIImage())
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                            Text("Message Guard")
                                .font(.title)
                            Spacer()
                        }
                    }
                }
        }
    }
}

struct AboutView: View {
    var body: some View {
        TitleView {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        HStack {
                            Text("Message Guard filters suspicious messages to your junk folder. Filtered messages include: ")
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            Label("Messages sent from email addresses (Email to Text)", systemImage: "envelope")
                                .padding(.bottom, 2.0)
                            Label("Messages containing URLs with risky TLDs, such as .ru", systemImage: "link")
                                .padding(.bottom, 2.0)
                            Label("Messages containing IP addresses", systemImage: "number")
                                .padding(.bottom, 2.0)
                            Label("Messages containing popular bank names which were not sent using an SMS shortcode", systemImage: "building.columns")
                                .padding(.bottom, 2.0)
                            Label("Messages containing common phishing phrases", systemImage: "exclamationmark.bubble")
                                .padding(.bottom, 2.0)
                        }
                        .padding(.all)
                    }
                    VStack {
                        GroupBox(label: Label("IMPORTANT", systemImage: "exclamationmark.triangle")) {
                            Text("Message Guard cannot filter messages from senders that are in your contacts or senders that you have replied to, as iOS does not send messages from known senders to message filters.")
                            
                        }
                    }
                    VStack {
                        GroupBox(label: Label("Privacy", systemImage: "hand.raised")) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Message Guard takes your privacy very seriously. All message processing and filtering occurs on your device at the time you receive a message. No data is stored from any of your messages or about your usage of the app at any point. Message Guard makes no connections to any other apps or remote servers at any point.")
                                    Spacer()
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.all)
            }
        }
    }
}

struct SetupView: View {
    var body: some View {
        TitleView {
            ScrollView {
                VStack(alignment: .leading) {
                    GroupBox(label: Label("Enable Message Guard", systemImage: "switch.2")) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("To enable Message Guard:")
                                Spacer()
                            }
                            .padding(.bottom, 1.0)
                            VStack(alignment: .leading) {
                                Label("Open Settings", systemImage: "1.circle.fill")
                                    .padding(.bottom, 1.0)
                                Label("Tap \"Messages\"", systemImage: "2.circle.fill")
                                    .padding(.bottom, 1.0)
                                Label("Tap \"Unknown & Spam\"", systemImage: "3.circle.fill")
                                    .padding(.bottom, 1.0)
                                Label("Enable \"Filter Unknown Senders\"", systemImage: "4.circle.fill")
                                    .padding(.bottom, 1.0)
                                Label("Under \"SMS FILTERING,\" select \"Message Guard\"", systemImage: "5.circle.fill")
                            }
                        }
                        .padding(.top, 2.0)
                    }
                    GroupBox(label: Label("Filter a Sender", systemImage: "person.fill.xmark")) {
                        VStack(alignment: .leading) {
                            Text("To filter messages from a sender, make sure the sender is not in your contacts, delete any messages from and to the sender, and do not reply to messages from the sender. Replying to a sender tells Apple that you are interested in receiving messages from the sender and iOS will stop filtering messages from the sender through Message Guard.")
                                .padding(.bottom, 1.0)
                            Text("If you want to stop receiving all messages from a given sender, blocking the sender would be a safer approach.")
                        }
                        .padding(.top, 2.0)
                    }
                    GroupBox(label: Label("Stop Filtering a Sender", systemImage: "person.fill.checkmark")) {
                        VStack(alignment: .leading) {
                            Text("To prevent Message Guard from filtering any messages from a sender, you can add the sender to your contacts, or reply to a message from them two or more times. This will cause iOS to stop filtering messages from the sender through Message Guard.")
                        }
                        .padding(.top, 2.0)
                    }
                }
                .padding(.all)
            }
        }
    }
}

struct AnalyzeView: View {
    @State private var messageSender = ""
    @State private var messageBody = ""
    @State var resultColor = Color(wordName: "red")
    @State var resultImage = ""
    @State var resultText = ""
    @State var resultDetail = ""
    
    var body: some View {
        let messageSenderBinding = Binding<String>(get: {
            self.messageSender
        }, set: {
            self.messageSender = $0
            resultImage = ""
            resultText = ""
            resultDetail = ""
        })
        
        let messageBodyBinding = Binding<String>(get: {
            self.messageBody
        }, set: {
            self.messageBody = $0
            resultImage = ""
            resultText = ""
            resultDetail = ""
        })
        
        TitleView {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack {
                        VStack {
                            Text("You can use the fields below to check if a message would be blocked by Message Guard and why it would be blocked.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 1.0)
                            Text("Some Message Guard filters consider both the sender and the message body, so be sure to include both for a more accurate analysis.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 15.0)
                        VStack {
                            TextField("Sender", text: messageSenderBinding)
                                .padding(.leading, 4.0)
                                .frame(width: .infinity, height: 30.0)
                                .foregroundColor(.gray)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7.0)
                                        .stroke(.primary, lineWidth: 1.0)
                                )
                            TextEditor(text: messageBodyBinding)
                                .frame(width: .infinity, height: 200.0)
                                .foregroundColor(.gray)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7.0)
                                        .stroke(.primary, lineWidth: 1.0)
                                )
                                .padding(.bottom)
                            Button("Analyze")
                            {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                let results = analyzeMessage(messageBody: messageBody, messageSender: messageSender)
                                if (results.count > 0) {
                                    resultColor = Color(wordName: "red")
                                    resultImage = "x.circle.fill"
                                    resultText = "This message is blocked by Message Guard."
                                    resultDetail = "The message is blocked due to the following:\n • " +
                                        results.joined(separator: "\n • ")
                                } else {
                                    resultColor = Color(wordName: "green")
                                    resultImage = "checkmark.circle.fill"
                                    resultText = "This message is not blocked by Message Guard."
                                    resultDetail = ""
                                }
                            }
                            .padding(.all)
                            .background(Color(hex: 0x14b7f1))
                            .foregroundColor(.white)
                            .cornerRadius(7.0)
                            HStack {
                                Image(systemName: resultImage).foregroundColor(resultColor)
                                Text(resultText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 15.0)
                            Text(resultDetail)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 5.0)
                        }
                    }
                }
                .padding(.all)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Color {
    init?(wordName: String) {
        switch wordName {
        case "red":   self = .red
        case "green": self = .green
        default:      return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
