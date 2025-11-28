//
//  DeviceInfoSettings.swift
//  SolarWindow
//
//  Created by Johny Lopez on 8/9/25.
//

import SwiftUI

struct DeviceInfoSettings: View {
    let device: IoTDevice
    @ObservedObject var viewModel: DeviceMenuViewModel
    @State private var now = Date()
    @State private var efficiency: Double = 0.85
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject private var weatherViewModel = GoogleWeatherViewModel()
    @State private var elevation: Double = 0
    @State private var azimuth: Double = 0
    @State private var optimalAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.orange)
                    Text("System Status")
                        .font(.headline)
                    Spacer()
                }
                Text(now, style: .date)
                Text(now, formatter: timeFormatter)
                    .font(.title2)
                Text(device.locationName)
            }
            .onReceive(timer) { input in
                now = input
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            HStack(alignment: .top) {
                Spacer() // Push content to center
                VStack(spacing: 16) {
                    Text("Power Output")
                        .font(.headline)
                    Text("4.9 kW")
                }
                Spacer() // Push content to center
                Image(systemName: "bolt")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack() {
                        Text("Orientation")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "safari")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("\(Int(device.orientation))°")
                        Spacer()
                        Text(compassDirection(from: device.orientation))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    HStack() {
                        Text("Temperature")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "thermometer.sun")
                            .foregroundColor(.green)
                    }
                    Text(weatherViewModel.temperature)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            VStack(alignment: .center, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max")
                        .foregroundColor(.orange)
                    Text("Solar Tracking")
                        .font(.headline)
                    Spacer()
                }
                HStack {
                    Text("Sun Elevation")
                    Spacer()
                    Text("\(Int(elevation))°")
                }
                HStack {
                    Text("Sun Azimuth")
                    Spacer()
                    Text("\(Int(azimuth))°")
                }
                HStack {
                    Text("Optimal Angle")
                    Spacer()
                    Text("\(Int(optimalAngle))°")
                }
                
                Divider()
                
                Text("System Efficiency")
                
                ProgressView(value: efficiency)
                   .progressViewStyle(LinearProgressViewStyle(tint: .green))
                   .scaleEffect(x: 1, y: 4, anchor: .center)
                   .cornerRadius(8)
                   .animation(.easeInOut(duration: 0.5), value: efficiency)
                Text("\(Int(efficiency * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            updateSunPosition()
            if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_WEATHER_API_KEY"] {
                weatherViewModel.fetchWeather(lat: device.location.latitude, lon: device.location.longitude, apiKey: apiKey)
            }
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateSunPosition()
        }
    }
    
    private func updateSunPosition() {
        let pos = Solar.position(date: Date(), latitude: device.location.latitude, longitude: device.location.longitude)
        elevation = pos.elevation
        azimuth = pos.azimuth
        let (angle, _) = optimalTiltForFixedAzimuth(
            alphaDeg: elevation,
            gammaSDeg: azimuth,
            gammaPDeg: device.orientation
        )

        optimalAngle = angle

    }
    
    private func compassDirection(from angle: Double) -> String {
        let directions = [
            "North", "North-East", "East", "South-East",
            "South", "South-West", "West", "North-West"
        ]
        let index = Int((angle + 22.5).truncatingRemainder(dividingBy: 360) / 45)
        return directions[index]
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a" // Example: 3:45:35 PM
        return formatter
    }
}
