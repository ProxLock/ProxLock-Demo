import SwiftUI

/// A view displaying hourly forecast in a horizontal scrollable list.
struct HourlyForecastView: View {
    let hours: [HourForecast]
    
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "h a"
            return formatter.string(from: date)
        }
        return timeString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(hours.prefix(24).enumerated()), id: \.offset) { index, hour in
                        VStack(spacing: 8) {
                            Text(formatTime(hour.time))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 32, height: 32)
                            
                            Text("\(Int(hour.temp_f))°")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if hour.chance_of_rain > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.blue)
                                    Text("\(hour.chance_of_rain)%")
                                        .font(.system(size: 8))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxHeight: 125)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HourlyForecastView(hours: [
        HourForecast(
            time_epoch: 1698508800,
            time: "2023-10-28 12:00",
            temp_c: 20.0,
            temp_f: 68.0,
            is_day: 1,
            condition: Condition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000),
            wind_mph: 10.0,
            wind_kph: 16.0,
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
            windchill_c: 20.0,
            windchill_f: 68.0,
            heatindex_c: 20.0,
            heatindex_f: 68.0,
            dewpoint_c: 10.0,
            dewpoint_f: 50.0,
            will_it_rain: 0,
            chance_of_rain: 0,
            will_it_snow: 0,
            chance_of_snow: 0,
            vis_km: 10.0,
            vis_miles: 6.0,
            gust_mph: 12.0,
            gust_kph: 19.0,
            uv: 5.0
        )
    ])
    .padding()
}


