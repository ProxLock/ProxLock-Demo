import SwiftUI

/// A view displaying astronomical information (sunrise, sunset, moon phases).
struct AstronomyView: View {
    let astro: Astro
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Astronomy")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Sunrise
                VStack(spacing: 8) {
                    Image(systemName: "sunrise.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(astro.sunrise)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                
                // Sunset
                VStack(spacing: 8) {
                    Image(systemName: "sunset.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Sunset")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(astro.sunset)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                // Moonrise
                VStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Moonrise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(astro.moonrise)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                
                // Moonset
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Moonset")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(astro.moonset)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            
            if !astro.moon_phase.isEmpty {
                Divider()
                VStack(spacing: 8) {
                    Text("Moon Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(astro.moon_phase)
                        .font(.headline)
                    Text("\(Int(astro.moon_illumination))% illuminated")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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

#Preview {
    AstronomyView(astro: Astro(
        sunrise: "06:30 AM",
        sunset: "06:30 PM",
        moonrise: "08:00 PM",
        moonset: "09:00 AM",
        moon_phase: "Waxing Gibbous",
        moon_illumination: 75.0
    ))
    .padding()
}

