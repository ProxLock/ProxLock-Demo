import Foundation
import Combine

/// The view model responsible for managing the weather data state.
///
/// This class conforms to `ObservableObject` and exposes published properties for the UI to observe.
@MainActor
public class WeatherViewModel: ObservableObject {
    
    /// The current weather data.
    @Published public var weather: WeatherResponse?
    
    /// The forecast data (3-day forecast).
    @Published public var forecast: ForecastResponse?
    
    /// The astronomy data (sunrise, sunset, moon phases).
    @Published public var astronomy: AstronomyResponse?
    
    /// A flag indicating whether data is currently being fetched.
    @Published public var isLoading: Bool = false
    
    /// An error message if the fetch fails.
    @Published public var errorMessage: String?
    
    /// The service used to fetch weather data.
    private let weatherService: WeatherService
    
    /// Initializes the view model with a weather service.
    ///
    /// - Parameter weatherService: The service to use for fetching data. Defaults to `WeatherService.shared`.
    public init(weatherService: WeatherService = .shared) {
        self.weatherService = weatherService
    }
    
    /// Loads all weather data (current, forecast, and astronomy) for a given city.
    ///
    /// - Parameter city: The name of the city to fetch weather for.
    public func loadWeather(for city: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch comprehensive weather data from Stormglass.io API
                let stormglassResponse = try await weatherService.fetchWeatherData(for: city)
                
                // Get coordinates from the response meta (should always be present)
                let coordinates = (stormglassResponse.meta?.lat ?? 0.0, stormglassResponse.meta?.lng ?? 0.0)
                
                // Convert to app-compatible models
                let (weatherData, forecastResponse, astronomyResponse) = stormglassResponse.toAppModels(
                    locationName: city,
                    coordinates: coordinates
                )
                
                self.weather = weatherData
                self.forecast = forecastResponse
                self.astronomy = astronomyResponse
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
