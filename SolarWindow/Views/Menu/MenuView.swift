import SwiftUI

enum DeviceNavigation: Hashable {
    case home(IoTDevice)
    case deviceList
    case setupLocation(name: String, ipaddress: String)
    case setupOrientation(name: String, ipaddress: String, coodinates: Coordinates, locationName: String)
    case setupCompleted
    case generalSettings
    case deviceInfoSettings(IoTDevice)
}

struct MenuView: View {
    @StateObject private var viewModel = DeviceMenuViewModel()
    @State private var path: [DeviceNavigation] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Background color
                Color(.systemGray6)
                    .ignoresSafeArea()

                // Main content
                VStack(alignment: .leading) {

                    //Energy Summary Card
                    HStack {
                        VStack(alignment: .center) {
                            HStack {
                                Text("Energy Generated")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Spacer()
                                HStack(alignment: .center) {
                                    Image("calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.horizontal)
                                    Text(Date().formattedAsCustom())
                                        .font(.subheadline)
                                        
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            Divider()
                               .frame(height: 1)
                               .background(Color.gray.opacity(0.4))
                               .padding(.horizontal)
                               .padding(.vertical, 5)
                            
                            HStack {
                                HStack {
                                    Image("daily_gen")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.horizontal)
                                    VStack {
                                        Text("Today")
                                            .font(.caption)
                                        Text("9 kWh")
                                            .font(.title2)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                               
                                HStack {
                                    Image("monthly_gen")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    VStack {
                                        Text("This Month")
                                            .font(.caption)
                                        Text("31.5 kWh")
                                            .font(.title2)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                            }
                        }
                        .padding(.vertical, 12)
                        .background(Color(.white))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    //Section Title
                    Text("Devices:")
                        .font(.headline)
                        .padding(.horizontal)

                    //Devices Gridw
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.devices) { device in
                            Button(action: {
                                path.append(.home(device))
                            }) {
                                DeviceCardView(device: device)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: {
                            path.append(.deviceList)
                        }) {
                            VStack(spacing: 10) {
                                Image("solar-panel-open")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                Text("Add new device")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .navigationDestination(for: DeviceNavigation.self) { destination in
                        switch destination {
                        case .home(let device):
                            HomeView(path: $path, homeVM: HomeViewModel(device: device))
                        case .deviceList:
                            DeviceListView(path: $path)
                        case .setupCompleted:
                            SetupCompleteView(path: $path)
                        case .setupLocation(let name, let ipaddress):
                            SetupDeviceLocation(name: name, ipaddress: ipaddress, path: $path)
                        case .setupOrientation(let name, let ipaddress, let coordinates, let locationName):
                            SetupDeviceOrientation(name: name, ipaddress: ipaddress, coordinates: coordinates, locationName: locationName, path: $path, viewModel: viewModel)
                        case .generalSettings:
                            GeneralSettings(viewModel: viewModel)
                        case .deviceInfoSettings(let device):
                            DeviceInfoSettings(device: device, viewModel: viewModel)
                        }
                    }
                    Spacer()

                    //Footer
                    HStack {
                        Spacer()
                        Text("Solara ®")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                .padding(.top)
                .navigationTitle("Welcome Home")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append(.generalSettings)
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        
    }

    
}
