import SwiftUI
import MapKit

struct ContentView: View {
    @State private var isSecretMode = false
    @State private var showMondayDetail = false
    @State private var showTuesdayDetail = false
    @State private var showWednesdayDetail = false
    @State private var showSaturdayDetail = false
    @State private var showConfirmationMessage = false
    @State private var confirmationText = ""
    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let safetyActions = ["Monitor", "Emergency Alert", "Watch", "", "", "Safe", "Secure"]
    private let dailyIcons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "sun.max.fill", "cloud.bolt.fill", "cloud.snow.fill"]

    var body: some View {
        ScrollView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1), Color(.sRGB, red: 0.0, green: 0.0, blue: 0.4, opacity: 1)]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                StarsView()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("My Location")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("63° | Clear")
                            .font(.system(size: 64, weight: .light))
                            .foregroundColor(.white)
                    }
                    .padding(.top)

                    // Daily Forecast Section with Safety Actions for selected days
                    VStack(alignment: .leading) {
                        Text("DAILY FORECAST")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        ForEach(0..<7) { index in
                            HStack {
                                Image(systemName: dailyIcons[index])
                                    .foregroundColor(.yellow)
                                Text(dayText(for: index))
                                    .font(.body)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("56°F")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                if index == 0 { showMondayDetail = true }
                                if index == 1 { showTuesdayDetail = true }
                                if index == 2 { showWednesdayDetail = true }
                                if index == 5 { showSaturdayDetail = true }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Footer Section for Air Quality, Precipitation, and UV Index
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            FooterCardView(icon: "aqi.low", title: "Air Quality", value: "Good")
                            FooterCardView(icon: "drop.fill", title: "Precipitation", value: "15%")
                            FooterCardView(icon: "sun.max.fill", title: "UV Index", value: "5")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)

                    // Discreet Toggle Button for Secret Mode : This button will turn on the days on the screen to the function of what it will do if you click it
                    Button(action: {
                        isSecretMode.toggle()
                    }) {
                        Text("🔒 Secret Mode")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(15)
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom)

                // Confirmation Message Overlay
                if showConfirmationMessage {
                    VStack {
                        Spacer()
                        Text(confirmationText)
                            .font(.subheadline)
                            .padding()
                            .background(Color.black.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.bottom, 50)
                            .transition(.opacity)
                    }
                    .animation(.easeInOut, value: showConfirmationMessage)
                }
            }
            .sheet(isPresented: $showMondayDetail) {
                MondayDetailView(showConfirmationMessage: $showConfirmationMessage, confirmationText: $confirmationText)
            }
            .sheet(isPresented: $showTuesdayDetail) {
                TuesdayDetailView(showConfirmationMessage: $showConfirmationMessage, confirmationText: $confirmationText)
            }
            .sheet(isPresented: $showWednesdayDetail) {
                WednesdayDetailView(showConfirmationMessage: $showConfirmationMessage, confirmationText: $confirmationText)
            }
            .sheet(isPresented: $showSaturdayDetail) {
                SaturdayDetailView(showConfirmationMessage: $showConfirmationMessage, confirmationText: $confirmationText)
            }
        }
    }

    private func dayText(for index: Int) -> String {
        if isSecretMode, index == 0 || index == 1 || index == 2 || index == 5 {
            return safetyActions[index]
        } else {
            return days[index]
        }
    }
}

// Monday Detail View for adjustable activity level with confirmation
struct MondayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showConfirmationMessage: Bool
    @Binding var confirmationText: String
    @State private var activityLevel = 1

    var body: some View {
        VStack(spacing: 20) {
            Text("Conditions")
                .font(.title2)
                .bold()
                .padding(.top)
                .foregroundColor(.white)
            
            Divider().background(Color.white)

            VStack(alignment: .leading, spacing: 16) {
                Text("Activity Level (1-5)")
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Button(action: { if activityLevel > 1 { activityLevel -= 1 } }) {
                        Image(systemName: "arrow.down.circle.fill").foregroundColor(activityLevel > 1 ? .blue : .gray)
                    }
                    Text("\(activityLevel)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    Button(action: { if activityLevel < 5 { activityLevel += 1 } }) {
                        Image(systemName: "arrow.up.circle.fill").foregroundColor(activityLevel < 5 ? .blue : .gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.2))
                .cornerRadius(10)

                Button(action: {
                    confirmationText = "Emergency message sent with activity level \(activityLevel)."
                    showConfirmationMessage = true
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfirmationMessage = false }
                }) {
                    Text("Enter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(15)
            .padding()

            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1), Color(.sRGB, red: 0.0, green: 0.0, blue: 0.4, opacity: 1)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// Tuesday Detail View for location sharing with a dark overlay
struct TuesdayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showConfirmationMessage: Bool
    @Binding var confirmationText: String
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        VStack(spacing: 20) {
            Text("Emergency Location")
                .font(.title2)
                .bold()
                .padding(.top)
                .foregroundColor(.white)

            ZStack {
                Map(coordinateRegion: $mapRegion)
                    .frame(height: 250)
                    .cornerRadius(15)
                
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.5))
                    .cornerRadius(15)
                
                VStack {
                    Image(systemName: "location.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Spacer()
                }
            }

            Text("75°F | Clear")
                .font(.largeTitle)
                .foregroundColor(.white)

            Button(action: {
                confirmationText = "Location sent to 911. Help is on the way."
                showConfirmationMessage = true
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfirmationMessage = false }
            }) {
                Text("Send Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkGray))
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1), Color(.sRGB, red: 0.0, green: 0.0, blue: 0.4, opacity: 1)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .foregroundColor(.white)
    }
}

// Wednesday Detail View for sending location to a family member
struct WednesdayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showConfirmationMessage: Bool
    @Binding var confirmationText: String
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    private let familyMembers = ["Mom", "Dad", "Sister", "Brother", "Friend"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Contact")
                .font(.title2)
                .bold()
                .padding(.top)
                .foregroundColor(.white)

            ZStack {
                Map(coordinateRegion: $mapRegion)
                    .frame(height: 250)
                    .cornerRadius(15)
                
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.5))
                    .cornerRadius(15)
                
                VStack {
                    Image(systemName: "location.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Spacer()
                }
            }

            Text("75°F | Clear")
                .font(.largeTitle)
                .foregroundColor(.white)

            ForEach(familyMembers, id: \.self) { member in
                Button(action: {
                    confirmationText = "Location sent to \(member)."
                    showConfirmationMessage = true
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfirmationMessage = false }
                }) {
                    Text("Send to \(member)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkGray))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1), Color(.sRGB, red: 0.0, green: 0.0, blue: 0.4, opacity: 1)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .foregroundColor(.white)
    }
}

// Saturday Detail View to alert contacts that the user is safe
struct SaturdayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showConfirmationMessage: Bool
    @Binding var confirmationText: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Safety")
                .font(.title2)
                .bold()
                .padding(.top)
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                confirmationText = "Message sent to contacts. You are marked as safe."
                showConfirmationMessage = true
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfirmationMessage = false }
            }) {
                Text("Send Safe Notification")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkGray))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1), Color(.sRGB, red: 0.0, green: 0.0, blue: 0.4, opacity: 1)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .foregroundColor(.white)
    }
}

// Stars Background View
struct StarsView: View {
    var body: some View {
        ZStack {
            ForEach(0..<100) { _ in
                Circle()
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
        }
    }
}

// Footer Card View for Air Quality, Precipitation, and UV Index
struct FooterCardView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
