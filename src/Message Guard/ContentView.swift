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
        }
    }
}

struct TitleView<Content: View>: View {
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
                                .padding(.bottom, 2)
                            Label("Messages containing URLs with risky TLDs, such as .ru", systemImage: "link")
                                .padding(.bottom, 2)
                            Label("Messages containing IP addresses", systemImage: "number")
                                .padding(.bottom, 2)
                            Label("Messages from full phone numbers (as opposed to SMS shortcodes) which mention popular banks", systemImage: "building.columns")
                                .padding(.bottom, 2)
                            Label("Messages containing common phishing ohrases", systemImage: "exclamationmark.bubble")
                                .padding(.bottom, 2)
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
                            .padding(.bottom, 1)
                            VStack(alignment: .leading) {
                                Label("Open Settings", systemImage: "1.circle.fill")
                                    .padding(.bottom, 1)
                                Label("Tap \"Messages\"", systemImage: "2.circle.fill")
                                    .padding(.bottom, 1)
                                Label("Tap \"Unknown & Spam\"", systemImage: "3.circle.fill")
                                    .padding(.bottom, 1)
                                Label("Enable \"Filter Unknown Senders\"", systemImage: "4.circle.fill")
                                    .padding(.bottom, 1)
                                Label("Under \"SMS FILTERING,\" select \"Message Guard\"", systemImage: "5.circle.fill")
                            }
                        }
                        .padding(.top, 2)
                    }
                    GroupBox(label: Label("Filter a Sender", systemImage: "person.fill.xmark")) {
                        VStack(alignment: .leading) {
                            Text("To filter messages from a sender, make sure the sender is not in your contacts, delete any messages from and to the sender, and do not reply to messages from the sender. Replying to a sender tells Apple that you are interested in hearing from the sender and iOS will stop filtering messages from the sender through Message Guard.")
                                .padding(.bottom, 1)
                            Text("If you want to stop receiving all messages from a given sender, blocking the sender would be a safer approach.")
                        }
                        .padding(.top, 2)
                    }
                    GroupBox(label: Label("Stop Filtering a Sender", systemImage: "person.fill.checkmark")) {
                        VStack(alignment: .leading) {
                            Text("To prevent Message Guard from filtering any messages from a sender, you can add the sender to your contacts, or reply to a message from them two or more times. This will cause iOS to stop filtering messages from the sender through Message Guard.")
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.all)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
