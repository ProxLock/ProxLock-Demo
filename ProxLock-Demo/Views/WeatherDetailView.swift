import SwiftUI

/// A view that displays detailed weather information.
struct WeatherDetailView: View {
    /// The current weather data.
    let current: Current
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // First row
            HStack(spacing: 16) {
                DetailItem(
                    icon: "humidity",
                    title: "Humidity",
                    value: "\(current.humidity)%"
                )
                DetailItem(
                    icon: "wind",
                    title: "Wind",
                    value: "\(Int(current.wind_mph)) mph \(current.wind_dir)"
                )
            }
            
            // Second row
            HStack(spacing: 16) {
                DetailItem(
                    icon: "sun.max.fill",
                    title: "UV Index",
                    value: "\(Int(current.uv))"
                )
                DetailItem(
                    icon: "thermometer",
                    title: "Feels Like",
                    value: "\(Int(current.feelslike_f))°F"
                )
            }
            
            // Third row
            HStack(spacing: 16) {
                DetailItem(
                    icon: "gauge",
                    title: "Pressure",
                    value: "\(Int(current.pressure_in)) in"
                )
                DetailItem(
                    icon: "eye.fill",
                    title: "Visibility",
                    value: "\(Int(current.vis_miles)) mi"
                )
            }
            
            // Fourth row (if gust data available)
            if let gustMph = current.gust_mph, gustMph > 0 {
                HStack(spacing: 16) {
                    DetailItem(
                        icon: "wind",
                        title: "Wind Gust",
                        value: "\(Int(gustMph)) mph"
                    )
                    DetailItem(
                        icon: "cloud.fill",
                        title: "Cloud Cover",
                        value: "\(current.cloud)%"
                    )
                }
            } else {
                HStack(spacing: 16) {
                    DetailItem(
                        icon: "cloud.fill",
                        title: "Cloud Cover",
                        value: "\(current.cloud)%"
                    )
                    if current.precip_in > 0 {
                        DetailItem(
                            icon: "drop.fill",
                            title: "Precipitation",
                            value: "\(String(format: "%.2f", current.precip_in)) in"
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

/// A helper view for a single detail item.
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    WeatherDetailView(current: Current(
        last_updated_epoch: 1698508800,
        last_updated: "2023-10-27 10:00",
        temp_c: 20.0,
        temp_f: 68.0,
        is_day: 1,
        condition: Condition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000),
        wind_mph: 10.5,
        wind_kph: 16.9,
        wind_degree: 180,
        wind_dir: "S",
        pressure_mb: 1015.0,
        pressure_in: 30.0,
        precip_mm: 0.0,
        precip_in: 0.0,
        humidity: 50,
        cloud: 0,
        feelslike_c: 20.0,
        feelslike_f: 68.0,
        vis_km: 10.0,
        vis_miles: 6.0,
        uv: 5.0,
        gust_mph: nil,
        gust_kph: nil
    ))
    .padding()
}
