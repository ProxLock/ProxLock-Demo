//
//  ContentView.swift
//  ProxLock-Demo
//
//  Created by Morris Richman on 11/13/25.
//

import SwiftUI

/// The main view of the application.
struct ContentView: View {
    /// The view model managing the weather data.
    @StateObject private var viewModel = WeatherViewModel()
    
    /// The city to search for.
    @State private var city = "San Francisco"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background gradient based on time of day
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Search Bar
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search city...", text: $city)
                                    .onSubmit {
                                        viewModel.loadWeather(for: city)
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            
                            Button(action: {
                                viewModel.loadWeather(for: city)
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if viewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading weather data...")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let errorMessage = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let weather = viewModel.weather {
                            // Main Weather Card
                            VStack(spacing: 16) {
                                // Location
                                VStack(spacing: 4) {
                                    Text(weather.location.name)
                                        .font(.system(size: 32, weight: .bold))
                                    
                                    if !weather.location.region.isEmpty {
                                        Text("\(weather.location.region), \(weather.location.country)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(weather.location.country)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Current Temperature and Condition
                                HStack(spacing: 20) {
                                    AsyncImage(url: URL(string: "https:\(weather.current.condition.icon)")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("\(Int(viewModel.temperatureUnit == .fahrenheit ? weather.current.temp_f : weather.current.temp_c))\(viewModel.temperatureUnit.rawValue)")
                                            .font(.system(size: 72, weight: .bold))
                                        
                                        Text(weather.current.condition.text)
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                // Last Updated
                                Text("Updated: \(formatLastUpdated(weather.current.last_updated))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            
                            // Hourly Forecast
                            if let forecast = viewModel.forecast,
                               let firstDay = forecast.forecast.forecastday.first,
                               !firstDay.hour.isEmpty {
                                HourlyForecastView(hours: firstDay.hour, temperatureUnit: viewModel.temperatureUnit)
                                    .padding(.horizontal)
                            }
                            
                            // Weather Details
                            WeatherDetailView(current: weather.current, temperatureUnit: viewModel.temperatureUnit)
                                .padding(.horizontal)
                            
                            // 5-Day Forecast
                            if let forecast = viewModel.forecast {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("5-Day Forecast")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(forecast.forecast.forecastday, id: \.date_epoch) { day in
                                                ForecastCardView(forecastDay: day, temperatureUnit: viewModel.temperatureUnit)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Astronomy
                            if let astronomy = viewModel.astronomy {
                                AstronomyView(astro: astronomy.astronomy.astro)
                                    .padding(.horizontal)
                            }
                            
                            // Bottom padding
                            Spacer()
                                .frame(height: 20)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "cloud.sun.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                Text("Search for a city to see the weather")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Picker("Temperature Unit", selection: $viewModel.temperatureUnit) {
                    Text("°F").tag(TemperatureUnit.fahrenheit)
                    Text("°C").tag(TemperatureUnit.celsius)
                }
                .labelsHidden()
            }
        }
        .onAppear {
            // Load default city on appear
            viewModel.loadWeather(for: city)
        }
    }
    
    private func formatLastUpdated(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    ContentView()
}
