//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation

import AddressURL
import SwiftyPing
import UIKit

import SwiftUI

@available(iOS 14.0, *)
struct PingNumberSettings: View {
    @Binding var numberOfPings: Int
    @Binding var indefinitely: Bool

    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximum = 1000
        formatter.minimum = 1
        return formatter
    }

    var body: some View {
        Form {
            Section {
                Toggle("Indefinitely", isOn: $indefinitely)
            }
            if !self.indefinitely {
                Section {
                    Stepper(value: $numberOfPings, in: ClosedRange(1 ..< 1000)) {
                        HStack {
                            Text("Number")
                            TextField("\(self.numberOfPings)", value: $numberOfPings, formatter: self.numberFormatter).foregroundColor(.gray)
                        }
                    }

                    Picker("Number of pings", selection: $numberOfPings, content: {
                        ForEach(1 ..< 1000, id: \.self) { i in
                            Text("\(i)")
                                .tag(i)
                                .id(i)
                        }
                    }).pickerStyle(WheelPickerStyle())
                }
            }
        }.navigationTitle("Ping Count")
    }
}

@available(iOS 14.0, *)
struct PingSettings: View {
    @Binding var interval: Double
    @Binding var timeout: Double
    @Binding var pingIndefinitly: Bool
    @Binding var pingCount: Int
    @Binding var savePings: Bool
    @Binding var payloadSize: Int
    @Binding var enableTTL: Bool
    @Binding var ttl: Int

    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        return formatter
    }

    var payloadSizeNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.minimum = 44
        formatter.maximum = 4096
        return formatter
    }

    var ttlNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.minimum = 1
        formatter.maximum = 255
        return formatter
    }

    var body: some View {
        Form {
            // TextField("Number of pings", text: $numberOfPings)
            NavigationLink(
                destination: PingNumberSettings(numberOfPings: $pingCount, indefinitely: $pingIndefinitly),
                label: {
                    HStack {
                        Text("Ping Count")
                        Spacer()
                        if self.pingIndefinitly {
                            Text("Indefinitely").foregroundColor(.gray)
                        } else {
                            Text("\(self.pingCount)").foregroundColor(.gray)
                        }
                    }
                }
            )
            Section {
                Stepper(value: $interval, in: 0 ... 10.0, step: 0.1) {
                    HStack {
                        Text("Interval")
                        let str: LocalizedStringKey = "\(self.interval, specifier: "%.02f")"
                        TextField(str, value: $interval, formatter: self.numberFormatter).foregroundColor(.gray)
                    }
                }
                Stepper(value: $timeout, in: 0 ... 10, step: 0.5) {
                    HStack {
                        Text("Timeout")
                        let str: LocalizedStringKey = "\(self.timeout, specifier: "%.2f")"
                        TextField(str, value: $timeout, formatter: self.numberFormatter).foregroundColor(.gray)
                    }
                }
            }
            Section {
                Stepper(value: $payloadSize, in: 44 ... 4096, step: 1) {
                    HStack {
                        Text("Payload Size")
                        let str: LocalizedStringKey = "\(self.payloadSize, specifier: "%d")"
                        TextField(str, value: $payloadSize, formatter: self.payloadSizeNumberFormatter).foregroundColor(.gray)
                    }
                }
            }
            Section {
                Toggle("Use TTL", isOn: $enableTTL)
                if self.enableTTL {
                    Stepper(value: $ttl, in: 1 ... 255, step: 1) {
                        HStack {
                            Text("TTL")
                            let str: LocalizedStringKey = "\(self.ttl, specifier: "%d")"
                            TextField(str, value: $ttl, formatter: self.ttlNumberFormatter).foregroundColor(.gray)
                        }
                    }
                }
            }
            Section {
                Toggle("Save Pings", isOn: $savePings)
            }
            Button(action: {
                self.enableTTL = false
                self.ttl = 64
                self.payloadSize = 44
                self.interval = 0.5
                self.timeout = 5.0
                self.pingCount = 5
                self.pingIndefinitly = false
                self.savePings = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Reset")
                    Spacer()
                }

            })
        }.navigationBarTitle("Ping Settings", displayMode: .inline)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

@available(iOS 14.0, *)
struct PingSetView: View {
    var ping: PingSet

    var body: some View {
        if ping.pings.count <= 0 {
            Text("No pings recorded")
        } else {
            List {
                ForEach(Array(ping.pings.sorted(by: { a, b in
                    a.sequenceNumber < b.sequenceNumber
                })), id: \.self) { ping in
                    HStack {
                        Text("#\(ping.sequenceNumber)")
                        if let error = ping.error {
                            Text("\(error)")
                        } else {
                            VStack(alignment: .leading) {
                                if let address = ping.ipAddress {
                                    Text("\(address)").font(.headline)
                                    Text("\(ping.byteCount) bytes")
                                }
                            }
                            Spacer()
                            Text("\(ping.duration * 1000, specifier: "%.02f") ms")
                        }
                    }
                }
            }.navigationTitle(ping.host)
        }
    }
}

@available(iOS 14.0, *)
struct PingSetList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(fetchRequest: PingSet.fetchAllRequest()) var pings: FetchedResults<PingSet>

    var body: some View {
        List {
            ForEach(pings) { ping in
                NavigationLink(
                    destination: PingSetView(ping: ping),
                    label: {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text("\(ping.host)").font(.headline)
                                Spacer()
                                Text("\(ping.pings.count)").font(.footnote).foregroundColor(.gray)
                            }
                            Text("\(ping.timestamp)").font(.caption)
                        }
                    }
                )
            }.onDelete(perform: deleteItems)
        }.listStyle(PlainListStyle()).navigationTitle("History").toolbar {
            #if os(iOS)
                EditButton()
            #endif
        }
    }

    private func deleteItems(offsets: IndexSet) {
        viewContext.perform {
            withAnimation {
                offsets.map { pings[$0] }.forEach(viewContext.delete)

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

struct DeferView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content() // << everything is created here
    }
}

@available(iOS 14.0, *)
struct PingSwiftUIViewController: View {
    let persistenceController = PersistenceController.shared

    @State var text: String = ""

    @State var isPinging: Bool = false

    @State var entries = [String]()

    @AppStorage("ping.indefinitly") var pingIndefinity: Bool = false
    @AppStorage("ping.count") var pingCount: Int = 5
    @AppStorage("ping.payloadSize") var pingPayloadSize: Int = 44
    @AppStorage("ping.useTTL") var pingUseTTL: Bool = false
    @AppStorage("ping.ttl") var pingTTL: Int = 64
    @AppStorage("ping.timeout") var pingTimeout: Double = 5.0
    @AppStorage("ping.interval") var pingInterval: Double = 0.5
    @AppStorage("ping.save") var pingSave: Bool = true

    @State var showSettings: Bool = false

    var defaultPing = "google.com"

    @State var dismissKeyboard = UUID()

    @State var showAlert: Bool = false
    @State var alertMessage: String?

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0.0) {
                    ScrollViewReader { reader in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0.0) {
                                ForEach(0 ..< entries.count, id: \.self) { i in
                                    Text(entries[i]).multilineTextAlignment(.leading).foregroundColor(.green).tag(i).font(Font.system(.footnote, design: .monospaced))
                                }.onChange(of: entries, perform: { _ in
                                    withAnimation {
                                        reader.scrollTo(entries.count - 1, anchor: .bottom)
                                    }
                                })
                            }.padding()
                        }
                        .background(Color.black.ignoresSafeArea(.all, edges: .horizontal))
                        // Fix for the content going above the navigation
                        // See !92 for more information
                        .padding(.top, 0.15)
                        .onTapGesture {
                            dismissKeyboard = UUID()
                        }
                    }
                    VStack(alignment: .leading, spacing: 0.0) {
                        Divider()
                        HStack(alignment: .center) {
                            // it would be great if this could be a .bottomBar toolbar but it is too buggy
                            TextField(self.defaultPing, text: $text, onCommit: { self.ping() }).id(dismissKeyboard).disableAutocorrection(true).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.URL).padding(.leading, geometry.safeAreaInsets.leading)
                            if self.isPinging {
                                Button("Cancel", action: {
                                    self.cancel()
                                }).padding(.trailing, geometry.safeAreaInsets.trailing)
                            } else {
                                Button("ping", action: {
                                    self.ping()
                                }).padding(.trailing, geometry.safeAreaInsets.trailing)
                            }
                        }.padding(.horizontal).padding([.vertical], 6)
                    }.background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).ignoresSafeArea(.all, edges: .horizontal)).ignoresSafeArea()
                }.navigationBarTitle("Ping", displayMode: .inline)
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: { showSettings.toggle() }, label: {
                        Image(systemName: "gear")
                    })
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationLink(
                        destination: PingSetList(),
                        label: {
                            Image(systemName: "clock")
                        }
                    )
                })
            }).sheet(isPresented: $showSettings, content: {
                EZPanel {
                    PingSettings(interval: $pingInterval, timeout: $pingTimeout, pingIndefinitly: $pingIndefinity, pingCount: $pingCount, savePings: $pingSave, payloadSize: $pingPayloadSize, enableTTL: $pingUseTTL, ttl: $pingTTL)
                }
            }).alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text("\(self.alertMessage ?? "")"), dismissButton: .none)
            }) // GeometryReader
        }.onDisappear(perform: {
            self.pinger?.stopPinging()
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.managedObjectContext, persistenceController.container.viewContext) // NavigationView
    }

    func cancel() {
        dismissKeyboard = UUID()
        isPinging = false
        pinger?.stopPinging()
    }

    @State var pinger: SwiftyPing?

    func ping() {
        print("ping")
        dismissKeyboard = UUID()
        let saveThisSession = pingSave
        let text = text.isEmpty ? defaultPing : text
        guard let host = URL(string: text)?.absoluteString else {
            alertMessage = "Unable to create URL. Please try again."
            showAlert.toggle()
            return
        }
        var config = PingConfiguration(interval: pingInterval, with: pingTimeout)
        if pingUseTTL {
            config.timeToLive = pingTTL
        }
        config.payloadSize = pingPayloadSize
        var stopPinging = false
        let workGroup = DispatchGroup()
        workGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            if let pinger = try? SwiftyPing(host: host, configuration: config, queue: .global()) {
                self.pinger = pinger
                workGroup.leave()
            } else {
                alertMessage = "Unable to create ping. Please try again."
                showAlert.toggle()
                stopPinging = true
                workGroup.leave()
                return
            }
        }
        workGroup.notify(queue: .main) {
            if stopPinging {
                return
            }
            var ps: PingSet?
            if saveThisSession {
                ps = PingSet(context: persistenceController.container.viewContext, configuration: config)
                ps?.host = host
                try? ps?.managedObjectContext?.save()
            }

            if !pingIndefinity {
                pinger?.targetCount = pingCount
            }

            var count = 1

            var latencySum = 0.0
            var minLatency = Double.greatestFiniteMagnitude
            var maxLatency = Double.leastNormalMagnitude
            var errorCount = 0

            entries.append("PING " + host)

            pinger?.observer = { response in
                print(response)
                if saveThisSession {
                    let item = PingItem(context: persistenceController.container.viewContext, response: response)
                    ps?.pings.insert(item)
                    do {
                        try ps?.managedObjectContext?.save()
                    } catch {
                        print("error\(error)")
                    }
                }

                if let error = response.error {
                    errorCount += 1
                    self.entries.append(error.localizedDescription)
                } else {
                    let duration = response.duration
                    let latency = duration * 1000
                    latencySum += latency
                    if latency > maxLatency {
                        maxLatency = latency
                    }
                    if latency < minLatency {
                        minLatency = latency
                    }
                    self.entries.append("\(response.byteCount ?? 0) bytes from \(response.ipAddress ?? "") icmp_seq=\(response.sequenceNumber) time=\(latency) ms")
                }

                if !self.pingIndefinity, count >= self.pingCount {
                    self.pinger?.stopPinging()
                    self.isPinging = false

                    self.entries.append("--- \(host) ping statistics ---")

                    // 5 packets transmitted, 5 packets received, 0.0% packet loss
                    self.entries.append("\(count) packets transmitted, ")
                    let received = count - errorCount
                    self.entries.append("\(count - errorCount) received, ")
                    if count == received {
                        self.entries.append("0.0% packet loss")
                    } else if received == 0 {
                        self.entries.append("100% packet loss")
                    } else {
                        self.entries.append(String(format: "%0.1f%% packet loss", Double(received) / Double(count) * 100.0))
                    }

                    // round-trip min/avg/max/stddev = 14.063/21.031/28.887/4.718 ms
                    var stats = "ronnd-trip min/avg/max = "
                    if errorCount == count {
                        stats += "n/a"
                    } else {
                        let avg = latencySum / Double(count)
                        stats += String(format: "%0.3f/%0.3f/%0.4f ms", minLatency, avg, maxLatency)
                    }
                    self.entries.append("\(stats)\n")
                }
                count += 1
            }

            isPinging = true
            try? pinger?.startPinging()
        }
    }
}

class PingViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    var status: UITextView?
    var urlBar: UITextField?

    var stack: UIStackView!

    // let preferredStatusBarStyle: UIStatusBarStyle = .lightContent

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = .white
        }

        stack = UIStackView()
        stack.backgroundColor = UIColor.black
        stack.axis = NSLayoutConstraint.Axis.vertical
        // stack.alignment = UIStackViewAlignment.fill
        // stack.alignment = .top
        // stack.distribution = UIStackViewDistribution.fillProportionally
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))

        status = UITextView()
        status?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
        // TODO: make this a constraint so there isn't padding when on the side
        status?.isEditable = false
        status?.isSelectable = true
        status?.backgroundColor = UIColor.black
        status?.textColor = UIColor.green
        status?.translatesAutoresizingMaskIntoConstraints = false
        status?.contentInset = view.safeAreaInsets
        status?.contentInset.bottom = 0
        status?.contentInsetAdjustmentBehavior = .always
        status?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        let statusView = UIView()
        statusView.addSubview(status!)

        stack.addArrangedSubview(statusView)

        let barStack = UIStackView()
        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        // barStack.autoresizingMask = [.flexibleWidth]
        // stack.alignment = UIStackViewAlignment.Fill
        // stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        barStack.translatesAutoresizingMaskIntoConstraints = false

        // urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        // urlBar?.autoresizingMask = [.flexibleWidth]
        urlBar?.placeholder = "1.1.1.1"
        urlBar?.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        urlBar?.delegate = self

        barStack.addArrangedSubview(urlBar!)

        let button = UIButton(type: .system)
        button.setTitle("ping", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(ping), for: .touchDown)
        barStack.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        barStack.addArrangedSubview(loader)

        let bar = UIToolbar()
        bar.barStyle = .default
        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        stack.addArrangedSubview(bar)

        loader.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loader.style = .medium
        } else {
            loader.style = .gray
        }

        let yConstraint = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])

        startAvoidingKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAvoidingKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopAvoidingKeyboard()
    }

    private var _isLoading = false
    var isLoading: Bool {
        get {
            _isLoading
        }
        set {
            _isLoading = newValue
        }
    }

    let loader = UIActivityIndicatorView()

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\r" {
            ping()
        }
        return true
    }

    func scrollViewDidScroll(_: UIScrollView) {
        dismissKeyboard()
    }

    public var pingCount: Int = 5
    private var pinger: SwiftyPing?

    func pingRepeated(_ url: URL, count _: Int = 1) {
        isLoading = true

        guard let pinger = try? SwiftyPing(host: url.absoluteString, configuration: PingConfiguration(interval: 0.5, with: 5), queue: .global()) else {
            isLoading = false
            return
        }

        self.pinger = pinger

        var count = 1

        var latencySum = 0.0
        var minLatency = Double.greatestFiniteMagnitude
        var maxLatency = Double.leastNormalMagnitude
        var errorCount = 0
        pinger.targetCount = pingCount
        pinger.observer = { response in
            print(response)
            print(response.sequenceNumber)
            if let error = response.error {
                errorCount += 1
                switch error {
                case .addressLookupError:
                    self.status?.insertText("Address lookup failed.\n")
                case .addressMemoryError:
                    self.status?.insertText("Address data could not be converted to `sockaddr`.\n")
                case .checksumMismatch:
                    self.status?.insertText("The received checksum doesn't match the calculated one.\n")
                case .checksumOutOfBounds:
                    self.status?.insertText("Checksum is out-of-bounds for `UInt16` in `computeCheckSum`.\n")
                case .hostNotFound:
                    self.status?.insertText("Host was not found.\n")
                case .identifierMismatch:
                    self.status?.insertText("Response `identifier` doesn't match what was sent.\n")
                case .invalidCode:
                    self.status?.insertText("Response `code` was invalid.\n")
                case .invalidHeaderOffset:
                    self.status?.insertText("The ICMP header offset couldn't be calculated.\n")
                case .invalidLength:
                    self.status?.insertText("The response length was too short.\n")
                case .invalidSequenceIndex:
                    self.status?.insertText("Response `sequenceNumber` doesn't match.\n")
                case .invalidType:
                    self.status?.insertText("Response `type` was invalid.\n")
                case .packageCreationFailed:
                    self.status?.insertText("Unspecified package creation error.\n")
                case .requestError:
                    self.status?.insertText("An error occured while sending the request.\n")
                case .requestTimeout:
                    self.status?.insertText("The request send timed out.\n")
                case .responseTimeout:
                    self.status?.insertText("The response took longer to arrive than `configuration.timeoutInterval`.\n")
                case .socketNil:
                    self.status?.insertText("For some reason, the socket is `nil`.\n")
                case .socketOptionsSetError:
                    self.status?.insertText("Failed to change socket options, in particular SIGPIPE.\n")
                case .unexpectedPayloadLength:
                    self.status?.insertText("Unexpected payload length.\n")
                case .unknownHostError:
                    self.status?.insertText("Unknown error occured within host lookup.\n")
                }
            } else {
                let duration = response.duration
                let latency = duration * 1000
                latencySum += latency
                if latency > maxLatency {
                    maxLatency = latency
                }
                if latency < minLatency {
                    minLatency = latency
                }
                self.status?.insertText(String(format: "latency=%0.3f ms\n", latency))
            }
            if count >= self.pingCount {
                pinger.stopPinging()
                self.isLoading = false

                self.status?.insertText("--- \(url.absoluteString) ping statistics ---\n")

                // 5 packets transmitted, 5 packets received, 0.0% packet loss
                self.status?.insertText("\(count) packets transmitted, ")
                let received = count - errorCount
                self.status?.insertText("\(count - errorCount) received, ")
                if count == received {
                    self.status?.insertText("0.0% packet loss\n")
                } else if received == 0 {
                    self.status?.insertText("100% packet loss\n")
                } else {
                    self.status?.insertText(String(format: "%0.1f%% packet loss\n", Double(received) / Double(count) * 100.0))
                }

                // round-trip min/avg/max/stddev = 14.063/21.031/28.887/4.718 ms
                self.status?.insertText("latency min/avg/max = ")
                if errorCount == count {
                    self.status?.insertText("n/a\n")
                } else {
                    let avg = latencySum / Double(count)
                    self.status?.insertText(String(format: "%0.3f/%0.3f/%0.4f ms\n", minLatency, avg, maxLatency))
                }
                latencySum = 0.0
            }
            count = count + 1
            self.status?.scrollToBottom()
        }

        try? pinger.startPinging()
    }

    @objc
    func ping() {
        if !isLoading {
            var urlString = (urlBar?.text)!
            if urlString == "" {
                urlString = (urlBar?.placeholder)!
            }
            if let url = URL(string: urlString) {
                status?.insertText("PING " + url.absoluteString + "\n")
                isLoading = true
                pingRepeated(url)
            } else {
                status?.insertText("Invalid URL\n")
            }
        }
    }
}
