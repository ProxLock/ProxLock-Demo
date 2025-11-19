import Foundation

// MARK: - Stormglass.io Response Models

/// The main response model from Stormglass.io API.
public struct StormglassResponse: Codable {
    public let hours: [StormglassHour]?
    public let meta: StormglassMeta?
}

/// Metadata about the request.
public struct StormglassMeta: Codable {
    public let cost: Int?
    public let dailyQuota: Int?
    public let end: String?
    public let lat: Double
    public let lng: Double
    public let params: [String]?
    public let requestCount: Int?
    public let start: String?
}

/// Hourly weather data from Stormglass.io.
public struct StormglassHour: Codable {
    public let time: String
    public let airTemperature: StormglassValue?
    public let humidity: StormglassValue?
    public let windSpeed: StormglassValue?
    public let windDirection: StormglassValue?
    public let pressure: StormglassValue?
    public let cloudCover: StormglassValue?
    public let precipitation: StormglassValue?
    public let visibility: StormglassValue?
}

/// A weather parameter value (can have multiple sources).
public struct StormglassValue: Codable {
    public let noaa: Double?
    public let sg: Double?
    public let icon: Double?
    public let meteo: Double?
    public let dwd: Double?
    
    /// Gets the first available value from any source.
    public var value: Double? {
        return sg ?? noaa ?? icon ?? meteo ?? dwd
    }
}

// MARK: - Convenience Models for App Compatibility

/// The main response model for current weather data (compatible with existing views).
public struct WeatherResponse: Codable {
    public let location: Location
    public let current: Current
}

/// The forecast response model (compatible with existing views).
public struct ForecastResponse: Codable {
    public let location: Location
    public let current: Current
    public let forecast: Forecast
}

/// The astronomy response model (compatible with existing views).
public struct AstronomyResponse: Codable {
    public let location: Location
    public let astronomy: Astronomy
}

// MARK: - Location

/// Location information (compatible with existing views).
public struct Location: Codable {
    public let name: String
    public let region: String
    public let country: String
    public let lat: Double
    public let lon: Double
    public let tz_id: String
    public let localtime_epoch: Int
    public let localtime: String
}

// MARK: - Current Weather

/// Current weather conditions (compatible with existing views).
public struct Current: Codable {
    public let last_updated_epoch: Int
    public let last_updated: String
    public let temp_c: Double
    public let temp_f: Double
    public let is_day: Int
    public let condition: Condition
    public let wind_mph: Double
    public let wind_kph: Double
    public let wind_degree: Int
    public let wind_dir: String
    public let pressure_mb: Double
    public let pressure_in: Double
    public let precip_mm: Double
    public let precip_in: Double
    public let humidity: Int
    public let cloud: Int
    public let feelslike_c: Double
    public let feelslike_f: Double
    public let vis_km: Double
    public let vis_miles: Double
    public let uv: Double
    public let gust_mph: Double?
    public let gust_kph: Double?
}

// MARK: - Condition

/// Weather condition information.
public struct Condition: Codable {
    public let text: String
    public let icon: String
    public let code: Int
}

// MARK: - Forecast

/// Forecast data containing daily and hourly forecasts.
public struct Forecast: Codable {
    public let forecastday: [ForecastDay]
}

/// A single day's forecast.
public struct ForecastDay: Codable {
    public let date: String
    public let date_epoch: Int
    public let day: DayForecast
    public let astro: Astro
    public let hour: [HourForecast]
}

/// Daily forecast information.
public struct DayForecast: Codable {
    public let maxtemp_c: Double
    public let maxtemp_f: Double
    public let mintemp_c: Double
    public let mintemp_f: Double
    public let avgtemp_c: Double
    public let avgtemp_f: Double
    public let maxwind_mph: Double
    public let maxwind_kph: Double
    public let totalprecip_mm: Double
    public let totalprecip_in: Double
    public let totalsnow_cm: Double
    public let avgvis_km: Double
    public let avgvis_miles: Double
    public let avghumidity: Double
    public let daily_will_it_rain: Int
    public let daily_chance_of_rain: Int
    public let daily_will_it_snow: Int
    public let daily_chance_of_snow: Int
    public let condition: Condition
    public let uv: Double
}

/// Hourly forecast information.
public struct HourForecast: Codable {
    public let time_epoch: Int
    public let time: String
    public let temp_c: Double
    public let temp_f: Double
    public let is_day: Int
    public let condition: Condition
    public let wind_mph: Double
    public let wind_kph: Double
    public let wind_degree: Int
    public let wind_dir: String
    public let pressure_mb: Double
    public let pressure_in: Double
    public let precip_mm: Double
    public let precip_in: Double
    public let humidity: Int
    public let cloud: Int
    public let feelslike_c: Double
    public let feelslike_f: Double
    public let windchill_c: Double
    public let windchill_f: Double
    public let heatindex_c: Double
    public let heatindex_f: Double
    public let dewpoint_c: Double
    public let dewpoint_f: Double
    public let will_it_rain: Int
    public let chance_of_rain: Int
    public let will_it_snow: Int
    public let chance_of_snow: Int
    public let vis_km: Double
    public let vis_miles: Double
    public let gust_mph: Double
    public let gust_kph: Double
    public let uv: Double
}

// MARK: - Astronomy

/// Astronomy data for a location.
public struct Astronomy: Codable {
    public let astro: Astro
}

/// Astronomical information (sunrise, sunset, moonrise, moonset).
public struct Astro: Codable {
    public let sunrise: String
    public let sunset: String
    public let moonrise: String
    public let moonset: String
    public let moon_phase: String
    public let moon_illumination: Double
}

// MARK: - Helper Extensions

extension StormglassResponse {
    /// Converts Stormglass.io response to app-compatible models.
    func toAppModels(locationName: String, coordinates: (lat: Double, lng: Double)) -> (weather: WeatherResponse, forecast: ForecastResponse, astronomy: AstronomyResponse) {
        // Create location
        let location = Location(
            name: locationName,
            region: "",
            country: "",
            lat: coordinates.lat,
            lon: coordinates.lng,
            tz_id: "UTC",
            localtime_epoch: Int(Date().timeIntervalSince1970),
            localtime: ISO8601DateFormatter().string(from: Date())
        )
        
        // Get current weather from first hour (most recent)
        let current = (hours?.first ?? StormglassHour.defaultHour).toCurrent()
        
        // Create forecast from hourly data grouped by day
        let forecast = createForecast(from: hours ?? [])
        
        // Create astronomy (simplified - Stormglass.io doesn't provide astronomy data)
        let astronomy = AstronomyResponse(
            location: location,
            astronomy: Astronomy(astro: Astro.defaultAstro)
        )
        
        let weather = WeatherResponse(location: location, current: current)
        let forecastResponse = ForecastResponse(location: location, current: current, forecast: forecast)
        
        return (weather, forecastResponse, astronomy)
    }
    
    private func createForecast(from hours: [StormglassHour]) -> Forecast {
        guard !hours.isEmpty else {
            return Forecast(forecastday: [])
        }
        
        // Group hours by date
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var dateGroups: [String: [StormglassHour]] = [:]
        for hour in hours {
            guard let date = dateFormatter.date(from: hour.time) else { continue }
            let dateKey = formatDate(date)
            if dateGroups[dateKey] == nil {
                dateGroups[dateKey] = []
            }
            dateGroups[dateKey]?.append(hour)
        }
        
        // Convert to ForecastDay objects
        let forecastDays = dateGroups.sorted(by: { $0.key < $1.key }).prefix(5).map { dateKey, dayHours in
            let firstHour = dayHours.first!
            let date = dateFormatter.date(from: firstHour.time) ?? Date()
            let dateEpoch = Int(date.timeIntervalSince1970)
            
            // Calculate daily min/max from hourly data
            let temps = dayHours.compactMap { $0.airTemperature?.value }
            let maxTemp = temps.max() ?? 0
            let minTemp = temps.min() ?? 0
            let avgTemp = temps.isEmpty ? 0 : temps.reduce(0, +) / Double(temps.count)
            
            let winds = dayHours.compactMap { $0.windSpeed?.value }
            let maxWind = winds.max() ?? 0
            
            let precip = dayHours.compactMap { $0.precipitation?.value }.reduce(0, +)
            let humidity = dayHours.compactMap { $0.humidity?.value }
            let avgHumidity = humidity.isEmpty ? 0 : humidity.reduce(0, +) / Double(humidity.count)
            
            // UV index not available in free tier
            let avgUV = 0.0
            
            let visibility = dayHours.compactMap { $0.visibility?.value }
            let avgVis = visibility.isEmpty ? 0 : visibility.reduce(0, +) / Double(visibility.count)
            
            // Determine condition from cloud cover and precipitation
            let cloudCover = dayHours.compactMap { $0.cloudCover?.value }
            let avgCloud = cloudCover.isEmpty ? 0 : cloudCover.reduce(0, +) / Double(cloudCover.count)
            let condition = determineCondition(cloudCover: avgCloud, precipitation: precip > 0)
            
            return ForecastDay(
                date: dateKey,
                date_epoch: dateEpoch,
                day: DayForecast(
                    maxtemp_c: celsiusFromFahrenheit(maxTemp),
                    maxtemp_f: maxTemp,
                    mintemp_c: celsiusFromFahrenheit(minTemp),
                    mintemp_f: minTemp,
                    avgtemp_c: celsiusFromFahrenheit(avgTemp),
                    avgtemp_f: avgTemp,
                    maxwind_mph: maxWind,
                    maxwind_kph: mphToKph(maxWind),
                    totalprecip_mm: precip * 25.4,
                    totalprecip_in: precip,
                    totalsnow_cm: 0, // Stormglass.io doesn't provide snow data in free tier
                    avgvis_km: avgVis / 1000.0, // Convert meters to km
                    avgvis_miles: avgVis / 1609.34, // Convert meters to miles
                    avghumidity: avgHumidity,
                    daily_will_it_rain: precip > 0 ? 1 : 0,
                    daily_chance_of_rain: precip > 0 ? 50 : 0,
                    daily_will_it_snow: 0,
                    daily_chance_of_snow: 0,
                    condition: condition,
                    uv: avgUV
                ),
                astro: Astro.defaultAstro,
                hour: dayHours.map { $0.toHourForecast() }
            )
        }
        
        return Forecast(forecastday: Array(forecastDays))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func determineCondition(cloudCover: Double, precipitation: Bool) -> Condition {
        if precipitation {
            return Condition(text: "Rain", icon: "//cdn.weatherapi.com/weather/64x64/day/266.png", code: 1063)
        } else if cloudCover > 75 {
            return Condition(text: "Cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/119.png", code: 1006)
        } else if cloudCover > 50 {
            return Condition(text: "Partly Cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/116.png", code: 1003)
        } else {
            return Condition(text: "Clear", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000)
        }
    }
}

extension StormglassHour {
    static var defaultHour: StormglassHour {
        StormglassHour(
            time: ISO8601DateFormatter().string(from: Date()),
            airTemperature: nil,
            humidity: nil,
            windSpeed: nil,
            windDirection: nil,
            pressure: nil,
            cloudCover: nil,
            precipitation: nil,
            visibility: nil
        )
    }
    
    func toCurrent() -> Current {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = dateFormatter.date(from: time) ?? Date()
        let epoch = Int(date.timeIntervalSince1970)
        let dateString = formatDateTime(date)
        
        let temp = airTemperature?.value ?? 0
        let humidity = self.humidity?.value ?? 0
        // Calculate apparent temperature from air temperature and humidity
        let apparentTemp = calculateApparentTemperature(temp: temp, humidity: humidity)
        let windSpeed = self.windSpeed?.value ?? 0
        let windDir = windDirection?.value ?? 0
        let pressure = self.pressure?.value ?? 0
        let cloudCover = self.cloudCover?.value ?? 0
        let precip = precipitation?.value ?? 0
        let visibility = self.visibility?.value ?? 0
        // UV index not available in free tier
        let uv = 0.0
        
        // Determine condition
        let condition = determineCondition(cloudCover: cloudCover, precipitation: precip > 0)
        
        // Determine if day time (simplified)
        let hour = Calendar.current.component(.hour, from: date)
        let isDay = hour >= 6 && hour < 20
        
        return Current(
            last_updated_epoch: epoch,
            last_updated: dateString,
            temp_c: celsiusFromFahrenheit(temp),
            temp_f: temp,
            is_day: isDay ? 1 : 0,
            condition: condition,
            wind_mph: windSpeed,
            wind_kph: mphToKph(windSpeed),
            wind_degree: Int(windDir),
            wind_dir: windDirectionToCardinal(windDir),
            pressure_mb: pressure / 100.0, // Convert Pa to mb
            pressure_in: pascalsToInches(pressure),
            precip_mm: precip * 25.4,
            precip_in: precip,
            humidity: Int(humidity),
            cloud: Int(cloudCover),
            feelslike_c: celsiusFromFahrenheit(apparentTemp),
            feelslike_f: apparentTemp,
            vis_km: visibility / 1000.0,
            vis_miles: visibility / 1609.34,
            uv: uv,
            gust_mph: nil,
            gust_kph: nil
        )
    }
    
    func toHourForecast() -> HourForecast {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = dateFormatter.date(from: time) ?? Date()
        let epoch = Int(date.timeIntervalSince1970)
        let dateString = formatDateTime(date)
        
        let temp = airTemperature?.value ?? 0
        let humidity = self.humidity?.value ?? 0
        // Calculate apparent temperature from air temperature and humidity
        let apparentTemp = calculateApparentTemperature(temp: temp, humidity: humidity)
        let windSpeed = self.windSpeed?.value ?? 0
        let windDir = windDirection?.value ?? 0
        let pressure = self.pressure?.value ?? 0
        let cloudCover = self.cloudCover?.value ?? 0
        let precip = precipitation?.value ?? 0
        let visibility = self.visibility?.value ?? 0
        // UV index not available in free tier
        let uv = 0.0
        
        let hour = Calendar.current.component(.hour, from: date)
        let isDay = hour >= 6 && hour < 20
        
        let condition = determineCondition(cloudCover: cloudCover, precipitation: precip > 0)
        
        return HourForecast(
            time_epoch: epoch,
            time: dateString,
            temp_c: celsiusFromFahrenheit(temp),
            temp_f: temp,
            is_day: isDay ? 1 : 0,
            condition: condition,
            wind_mph: windSpeed,
            wind_kph: mphToKph(windSpeed),
            wind_degree: Int(windDir),
            wind_dir: windDirectionToCardinal(windDir),
            pressure_mb: pressure / 100.0,
            pressure_in: pascalsToInches(pressure),
            precip_mm: precip * 25.4,
            precip_in: precip,
            humidity: Int(humidity),
            cloud: Int(cloudCover),
            feelslike_c: celsiusFromFahrenheit(apparentTemp),
            feelslike_f: apparentTemp,
            windchill_c: celsiusFromFahrenheit(calculateWindChill(temp: temp, wind: windSpeed)),
            windchill_f: calculateWindChill(temp: temp, wind: windSpeed),
            heatindex_c: celsiusFromFahrenheit(calculateHeatIndex(temp: temp, humidity: humidity)),
            heatindex_f: calculateHeatIndex(temp: temp, humidity: humidity),
            dewpoint_c: 0, // Stormglass.io doesn't provide dewpoint in free tier
            dewpoint_f: 0,
            will_it_rain: precip > 0 ? 1 : 0,
            chance_of_rain: precip > 0 ? 50 : 0,
            will_it_snow: 0,
            chance_of_snow: 0,
            vis_km: visibility / 1000.0,
            vis_miles: visibility / 1609.34,
            gust_mph: 0,
            gust_kph: 0,
            uv: uv
        )
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func determineCondition(cloudCover: Double, precipitation: Bool) -> Condition {
        if precipitation {
            return Condition(text: "Rain", icon: "//cdn.weatherapi.com/weather/64x64/day/266.png", code: 1063)
        } else if cloudCover > 75 {
            return Condition(text: "Cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/119.png", code: 1006)
        } else if cloudCover > 50 {
            return Condition(text: "Partly Cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/116.png", code: 1003)
        } else {
            return Condition(text: "Clear", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000)
        }
    }
}

// MARK: - Helper Functions

private func celsiusFromFahrenheit(_ f: Double) -> Double {
    return (f - 32) * 5 / 9
}

private func mphToKph(_ mph: Double) -> Double {
    return mph * 1.60934
}

private func pascalsToInches(_ pascals: Double) -> Double {
    return pascals / 3386.39
}

private func windDirectionToCardinal(_ degrees: Double) -> String {
    let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    let index = Int((degrees + 11.25) / 22.5) % 16
    return directions[index]
}

private func calculateWindChill(temp: Double, wind: Double) -> Double {
    if temp <= 50 && wind >= 3 {
        return 35.74 + 0.6215 * temp - 35.75 * pow(wind, 0.16) + 0.4275 * temp * pow(wind, 0.16)
    }
    return temp
}

private func calculateHeatIndex(temp: Double, humidity: Double) -> Double {
    if temp >= 80 {
        return -42.379 + 2.04901523 * temp + 10.14333127 * humidity - 0.22475541 * temp * humidity
            - 6.83783e-3 * temp * temp - 5.481717e-2 * humidity * humidity
            + 1.22874e-3 * temp * temp * humidity + 8.5282e-4 * temp * humidity * humidity
            - 1.99e-6 * temp * temp * humidity * humidity
    }
    return temp
}

/// Calculates apparent temperature (feels like) from air temperature and humidity.
private func calculateApparentTemperature(temp: Double, humidity: Double) -> Double {
    // Use heat index for warm temperatures, wind chill for cold
    if temp >= 80 {
        return calculateHeatIndex(temp: temp, humidity: humidity)
    } else if temp <= 50 {
        // For cold temperatures, wind chill would be more accurate but we don't have wind speed here
        // So just return the temperature (wind chill requires wind speed)
        return temp
    } else {
        // For moderate temperatures, apparent temp is close to actual temp
        // Adjust slightly based on humidity
        return temp + (humidity - 50) * 0.1
    }
}

extension Current {
    static var defaultCurrent: Current {
        Current(
            last_updated_epoch: Int(Date().timeIntervalSince1970),
            last_updated: "",
            temp_c: 0,
            temp_f: 0,
            is_day: 1,
            condition: Condition(text: "Unknown", icon: "", code: 1000),
            wind_mph: 0,
            wind_kph: 0,
            wind_degree: 0,
            wind_dir: "N",
            pressure_mb: 0,
            pressure_in: 0,
            precip_mm: 0,
            precip_in: 0,
            humidity: 0,
            cloud: 0,
            feelslike_c: 0,
            feelslike_f: 0,
            vis_km: 0,
            vis_miles: 0,
            uv: 0,
            gust_mph: nil,
            gust_kph: nil
        )
    }
}

extension Astro {
    static var defaultAstro: Astro {
        Astro(
            sunrise: "N/A",
            sunset: "N/A",
            moonrise: "N/A",
            moonset: "N/A",
            moon_phase: "Unknown",
            moon_illumination: 0
        )
    }
}
