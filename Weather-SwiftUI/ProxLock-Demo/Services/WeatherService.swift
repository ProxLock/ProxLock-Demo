import Foundation
import ProxLock

extension PLSession {
    /// The ProxLock session for Stormglass.io API.
    ///
    /// - Important: Replace `PROXLOCK_PARTIAL_KEY` with your actual partial key from ProxLock. Same for `PROXLOCK_ASSOCIATION_ID` with the association id.
    static let weatherAPI = PLSession(partialKey: ProcessInfo.processInfo.environment["PROXLOCK_PARTIAL_KEY"]!, assosiationID: ProcessInfo.processInfo.environment["PROXLOCK_ASSOCIATION_ID"]!)
}

/// A service responsible for fetching weather data from Stormglass.io Weather API.
public class WeatherService {
    
    /// The base URL for the Stormglass.io API.
    private let baseURL = "https://api.stormglass.io/v2"
    
    /// Shared singleton instance of the `WeatherService`.
    public static let shared = WeatherService()
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Errors that can occur during weather data fetching.
    public enum WeatherError: Error, LocalizedError {
        /// The URL was invalid.
        case invalidURL
        /// The server returned an invalid response.
        case invalidResponse
        /// The data could not be decoded.
        case decodingError
        /// API key is missing.
        case missingAPIKey
        /// Location could not be geocoded.
        case geocodingFailed
        /// A generic error with a description.
        case custom(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL provided was invalid."
            case .invalidResponse:
                return "The server returned an invalid response."
            case .decodingError:
                return "Failed to decode the weather data."
            case .missingAPIKey:
                return "API key is missing. Please set your ProxLock environment variables correctly."
            case .geocodingFailed:
                return "Could not find coordinates for the specified location."
            case .custom(let message):
                return message
            }
        }
    }
    
    /// Stores the last coordinates used (for use in conversion).
    private var lastCoordinates: (lat: Double, lng: Double)?
    
    /// Fetches comprehensive weather data (current and forecast) for a specific location.
    ///
    /// - Parameter location: The location (city name, coordinates, or address) to fetch weather for.
    /// - Returns: A `StormglassResponse` containing all weather data.
    /// - Throws: A `WeatherError` if the request fails or decoding fails.
    public func fetchWeatherData(for location: String) async throws -> StormglassResponse {
        // First, geocode the location to get coordinates
        let coordinates = try await geocodeLocation(location)
        lastCoordinates = coordinates
        
        // Stormglass.io free tier: 10 requests/day
        // Request current weather and forecast in a single call
        // Limit to 5 days (120 hours) to stay within free tier limits
        // Using only valid parameters (apparentTemperature is not available, will calculate from airTemperature and humidity)
        let urlString = "\(baseURL)/weather/point?lat=\(coordinates.lat)&lng=\(coordinates.lng)&params=airTemperature,humidity,windSpeed,windDirection,pressure,cloudCover,precipitation,visibility&start=\(Int(Date().timeIntervalSince1970))&end=\(Int(Date().timeIntervalSince1970) + (5 * 24 * 3600))"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(PLSession.weatherAPI.bearerToken, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await PLSession.weatherAPI.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        // Print response for debugging
        if httpResponse.statusCode != 200 {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Error response: \(jsonString)")
            }
        }
        
        guard httpResponse.statusCode == 200 else {
            // Try to extract error message
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let message = errorData["message"] as? String {
                    throw WeatherError.custom(message)
                }
                if let errors = errorData["errors"] as? [String: Any],
                   let message = errors["message"] as? String {
                    throw WeatherError.custom(message)
                }
            }
            throw WeatherError.invalidResponse
        }
        
        do {
            let stormglassResponse = try JSONDecoder().decode(StormglassResponse.self, from: data)
            // Store location name for use in conversion
            return stormglassResponse
        } catch {
            print("Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response: \(jsonString)")
            }
            throw WeatherError.decodingError
        }
    }
    
    /// Geocodes a location string to coordinates.
    /// Uses a simple geocoding service (OpenStreetMap Nominatim) for free tier compatibility.
    private func geocodeLocation(_ location: String) async throws -> (lat: Double, lng: Double) {
        // Check if location is already coordinates
        let components = location.split(separator: ",")
        if components.count == 2,
           let lat = Double(components[0].trimmingCharacters(in: .whitespaces)),
           let lng = Double(components[1].trimmingCharacters(in: .whitespaces)) {
            return (lat, lng)
        }
        
        // Use OpenStreetMap Nominatim for geocoding (free, no API key required)
        guard let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://nominatim.openstreetmap.org/search?q=\(encodedLocation)&format=json&limit=1") else {
            throw WeatherError.geocodingFailed
        }
        
        var request = URLRequest(url: url)
        request.setValue("WeatherApp/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherError.geocodingFailed
        }
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let firstResult = jsonArray.first,
              let latString = firstResult["lat"] as? String,
              let lonString = firstResult["lon"] as? String,
              let lat = Double(latString),
              let lon = Double(lonString) else {
            throw WeatherError.geocodingFailed
        }
        
        return (lat, lon)
    }
}
