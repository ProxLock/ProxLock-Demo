# ProxLock iOS Demo - Weather App

This is a sample iOS application demonstrating how to use [ProxLock](https://docs.proxlock.dev/) to securely proxy API requests to the Stormglass.io Weather API. The app displays current weather conditions, hourly forecasts, and 5-day forecasts for any location.

## Features

- 🌤️ Current weather conditions
- 📊 Hourly weather forecast
- 📅 5-day weather forecast
- 🌙 Astronomy data (sunrise, sunset)
- 🔒 Secure API requests via ProxLock
- 📱 Works on both simulator and real devices

## Prerequisites

Before you begin, make sure you have:

- **Xcode** installed (latest version recommended)
- A **ProxLock account**
- A **Stormglass.io API key** - Sign up at [stormglass.io](https://stormglass.io/)
- **App Attest capability** enabled (already configured in this project)

## Setup Instructions

### 0. Configure Bundle ID and Development Team

The project uses a `Config.xcconfig` file to manage build settings. You need to configure your bundle identifier and development team ID:

1. Open `Config.xcconfig` in the project root
2. Update the following values:
   - **PRODUCT_BUNDLE_IDENTIFIER**: Change to your own bundle identifier (e.g., `com.yourcompany.ProxLock-Demo`)
   - **DEVELOPMENT_TEAM**: Change to your Apple Developer Team ID
     - Find your Team ID in Xcode: **Preferences** → **Accounts** → Select your team → **Team ID**
     - Or in the [Apple Developer Portal](https://developer.apple.com/account) under Membership

**Example:**
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.ProxLock-Demo
DEVELOPMENT_TEAM = YOUR_TEAM_ID_HERE
```

### 1. Get Your Stormglass.io API Key

1. Visit [stormglass.io](https://stormglass.io/) and create an account
2. Navigate to your dashboard and generate an API key
3. Copy your API key - you'll need this for ProxLock configuration

### 2. Configure ProxLock

1. Log in to the [ProxLock web dashboard](https://docs.proxlock.dev/)
2. Navigate to your project
3. Add a new API key:
   - Click "Add Key"
   - Enter your Stormglass.io API key as the full key
   - Add `api.stormglass.io` to the whitelisted URLs
   - Save the key
4. Copy your credentials from the key card:
   - **Partial Key** - This is the partial key shown in your dashboard
   - **Association ID** - This is the association ID for your key
5. (Optional) For simulator testing, get your **Bypass Token**:
   - Navigate to the Device Check section in your dashboard
   - Copy the bypass token

### 3. Configure Environment Variables in Xcode

The app uses environment variables to securely store your ProxLock credentials. Follow these steps to configure them:

1. Open the project in Xcode
2. Go to **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** in the left sidebar
4. Go to the **Arguments** tab
5. Under **Environment Variables**, click the **+** button to add each variable:

   Add the following environment variables:

   | Name | Value | Notes |
   |------|-------|-------------|
   | `PROXLOCK_PARTIAL_KEY` | |
   | `PROXLOCK_ASSOCIATION_ID` | Your association ID from ProxLock | |
   | `PROXLOCK_DEVICE_CHECK_BYPASS` | Your bypass token (optional) | Required for simulator testing only |

   **Example:**
   ```
   PROXLOCK_PARTIAL_KEY = abc123def456...
   PROXLOCK_ASSOCIATION_ID = xyz789...
   PROXLOCK_DEVICE_CHECK_BYPASS = bypass_token_here (only for simulator)
   ```

6. Click **Close** to save your changes

### 4. Build and Run

1. Select your target device (simulator or real device)
2. Press **⌘R** or click the **Run** button
3. The app will launch and display weather for San Francisco by default
4. Search for any city to see its weather data

## Project Structure

```
ProxLock-Demo/
├── Config.xcconfig               # Build configuration (bundle ID, team ID)
├── ProxLock-Demo/
│   ├── Services/
│   │   └── WeatherService.swift      # Service for fetching weather data via ProxLock
│   ├── ViewModels/
│   │   └── WeatherViewModel.swift    # View model managing weather state
│   ├── Views/
│   │   ├── ContentView.swift         # Main view
│   │   ├── WeatherDetailView.swift   # Weather details display
│   │   ├── HourlyForecastView.swift  # Hourly forecast display
│   │   ├── ForecastCardView.swift    # Forecast card component
│   │   └── AstronomyView.swift       # Astronomy data display
│   └── Models/
│       └── WeatherModels.swift       # Data models for weather data
└── README.md
```

## How ProxLock Works in This App

The app uses ProxLock to securely proxy requests to Stormglass.io:

1. **PLSession Setup**: A `PLSession` is created using your partial key and association ID (from environment variables)
2. **Bearer Token**: The app uses `session.bearerToken` in the Authorization header instead of the full API key
3. **Request Proxying**: All requests go through ProxLock, which:
   - Validates the request using Device Check
   - Replaces the bearer token placeholder with your full Stormglass.io API key
   - Forwards the request to Stormglass.io
   - Returns the response to your app

See `WeatherService.swift` for the implementation details.

## Testing

### Simulator Testing

- Requires the `PROXLOCK_DEVICE_CHECK_BYPASS` environment variable to be set
- Device Check doesn't work in the simulator, so the bypass token is required

### Real Device Testing

- Device Check works automatically on real devices
- No bypass token needed
- This is the recommended way to test before releasing

## Troubleshooting

### "API key is missing" Error

- Verify that `PROXLOCK_PARTIAL_KEY` and `PROXLOCK_ASSOCIATION_ID` are set in your run scheme
- Make sure there are no extra spaces in the environment variable values
- Restart Xcode if the variables don't seem to be loading

### Device Check Errors

- **On Simulator**: Make sure `PROXLOCK_DEVICE_CHECK_BYPASS` is set
- **On Real Device**: Verify that App Attest is enabled in your target's capabilities (already configured)

### Request Failures

- Verify your Stormglass.io API key is valid and active
- Check that `https://api.stormglass.io` is whitelisted in your ProxLock key configuration
- Ensure you're using the correct partial key and association ID
- Ensure that you have not hit the 10 request per day rate limit.

### Network Errors

- Check your internet connection
- Verify the ProxLock service is accessible
- Check Xcode console for detailed error messages

## Resources

- [ProxLock iOS SDK Documentation](https://docs.proxlock.dev/ios-sdk/)
- [Stormglass.io API Documentation](https://docs.stormglass.io/)
- [ProxLock Web Dashboard](https://docs.proxlock.dev/)

## License

This is a sample project for demonstration purposes.

