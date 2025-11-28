//
//  SetupDeviceOrientation.swift
//  SolarWindow
//
//  Created by Johny Lopez on 8/2/25.
//

import SwiftUI

struct SetupDeviceOrientation: View {
    let name: String
    let ipaddress: String
    let coordinates: Coordinates
    let locationName: String
    @State private var showHelpDetails = false
    @State private var orientationIndex: Double = 2 // 0..4 -> 0,90,180,270,360
    @Binding var path: [DeviceNavigation]
    @ObservedObject var viewModel: DeviceMenuViewModel
    
    var body: some View {
        VStack(spacing: 24){
            VStack(spacing: 8) {
                Text("Which direction does your facade face?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("This helps us understand your solar panel's current orientation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Image(systemName: "iphone")
                        .foregroundColor(.blue)
                    Text("Need help finding the direction?")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        print("[SetupDeviceOrientation] Tapping help toggle. Current: \(showHelpDetails)")
                        withAnimation {
                            showHelpDetails.toggle()
                            print("[SetupDeviceOrientation] Toggled help. New: \(showHelpDetails)")
                        }
                    }) {
                        Image(systemName: showHelpDetails ? "chevron.up.circle.fill" : "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }

                if showHelpDetails {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "safari")
                                .foregroundColor(.blue)
                            Text("Use your phone's built-in compass app to find the direction")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Text("Stand facing the same direction as your solar panels")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Text("Note the compass reading and adjust the slider below")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .onAppear { print("[SetupDeviceOrientation] Help details appeared") }
                    .onDisappear { print("[SetupDeviceOrientation] Help details disappeared") }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 16){
                HStack(alignment: .center) {
                    Image(systemName: "safari")
                        .foregroundColor(.orange)
                    Text("Facade Orientation")
                        .font(.headline)
                }
                
                VStack(alignment: .center, spacing: 16) {
                    Text("Current orientation reading")
                        .font(.subheadline)
                    Text("\(Int(degrees(for: orientationIndex)))°")
                        .foregroundColor(.orange)
                        .font(.title)
                        .bold()
                    Slider(value: $orientationIndex, in: 0...4, step: 1)
                        .accentColor(.black)
                        .onChange(of: orientationIndex) { newValue in
                            print("[SetupDeviceOrientation] orientationIndex changed -> \(newValue) (degrees: \(degrees(for: newValue)))")
                        }
                    HStack(alignment: .center){
                        Text("N (0)°")
                        Spacer()
                        Text("E (90)°")
                        Spacer()
                        Text("S (180)°")
                        Spacer()
                        Text("W (270)°")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 160, height: 160)
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            .frame(width: 140, height: 140)
                        Group {
                            Text("N")
                                .font(.headline).bold()
                                .position(x: 100, y: 30)
                            Text("E")
                                .font(.headline).bold()
                                .position(x: 170, y: 100)
                            Text("S")
                                .font(.headline).bold()
                                .position(x: 100, y: 170)
                            Text("W")
                                .font(.headline).bold()
                                .position(x: 30, y: 100)
                        }

                        Image(systemName: "location.north.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 100)
                            .foregroundColor(.orange)
                            .rotationEffect(Angle(degrees: degrees(for: orientationIndex)))
                            .animation(.easeInOut(duration: 0.2), value: orientationIndex)

                    }
                    .frame(width: 200, height: 200)
                }
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            Button(action: {
                print("[SetupDeviceOrientation] Completing setup with orientation: \(degrees(for: orientationIndex))°, coords: \(coordinates), locationName: \(locationName)")
                viewModel.addDevice(ipaddress: ipaddress, name: name, orientation: degrees(for: orientationIndex), location: coordinates, locationName: locationName)
                path.append(DeviceNavigation.setupCompleted)
            }) {
                Text("Complete Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Device Setup")
        .onAppear {
            print("[SetupDeviceOrientation] onAppear - name: \(name), ip: \(ipaddress), coords: \(coordinates), locationName: \(locationName), showHelpDetails: \(showHelpDetails), orientationIndex: \(orientationIndex)")
        }
        .onDisappear {
            print("[SetupDeviceOrientation] onDisappear")
        }
    }
    
    private func degrees(for index: Double) -> Double {
        switch Int(index) {
        case 0: return 0
        case 1: return 90
        case 2: return 180
        case 3: return 270
        case 4: return 360
        default: return 0
        }
    }
    
}

