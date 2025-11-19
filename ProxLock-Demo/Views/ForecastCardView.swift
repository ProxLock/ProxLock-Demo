import SwiftUI

/// A card view displaying a single day's forecast.
struct ForecastCardView: View {
    let forecastDay: ForecastDay
    let temperatureUnit: TemperatureUnit
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: forecastDay.date) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        return forecastDay.date
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(dayName)
                .font(.headline)
                .foregroundColor(.primary)
            
            AsyncImage(url: URL(string: "https:\(forecastDay.day.condition.icon)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            
            Text(forecastDay.day.condition.text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("\(Int(temperatureUnit == .fahrenheit ? forecastDay.day.maxtemp_f : forecastDay.day.maxtemp_c))\(temperatureUnit.rawValue)")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("\(Int(temperatureUnit == .fahrenheit ? forecastDay.day.mintemp_f : forecastDay.day.mintemp_c))\(temperatureUnit.rawValue)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            if forecastDay.day.daily_chance_of_rain > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(forecastDay.day.daily_chance_of_rain)%")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HStack {
        ForecastCardView(forecastDay: ForecastDay(
            date: "2023-10-28",
            date_epoch: 1698508800,
            day: DayForecast(
                maxtemp_c: 25.0,
                maxtemp_f: 77.0,
                mintemp_c: 15.0,
                mintemp_f: 59.0,
                avgtemp_c: 20.0,
                avgtemp_f: 68.0,
                maxwind_mph: 10.0,
                maxwind_kph: 16.0,
                totalprecip_mm: 0.0,
                totalprecip_in: 0.0,
                totalsnow_cm: 0.0,
                avgvis_km: 10.0,
                avgvis_miles: 6.0,
                avghumidity: 60.0,
                daily_will_it_rain: 0,
                daily_chance_of_rain: 20,
                daily_will_it_snow: 0,
                daily_chance_of_snow: 0,
                condition: Condition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000),
                uv: 5.0
            ),
            astro: Astro(
                sunrise: "06:30 AM",
                sunset: "06:30 PM",
                moonrise: "08:00 PM",
                moonset: "09:00 AM",
                moon_phase: "Waxing Gibbous",
                moon_illumination: 75.0
            ),
            hour: []
        ), temperatureUnit: .fahrenheit)
    }
    .padding()
}

