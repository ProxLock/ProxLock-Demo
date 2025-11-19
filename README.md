# ProxLock Demo Projects

This repository contains sample iOS applications demonstrating how to use [ProxLock](https://docs.proxlock.dev/) to securely proxy API requests in applications. ProxLock allows you to protect your API keys by proxying requests through their service, which validates requests using Device Check and replaces bearer tokens with your full API keys server-side.

## Demo Projects

This repository includes the following demo applications:

### 1. [ChatGPT iOS Demo](./ChatGPT-SwiftUI/)

A full-featured chat interface demonstrating ProxLock integration with the OpenAI ChatGPT API.

**Features:**
- 💬 Full ChatGPT chat interface
- 🎨 Beautiful message bubbles with user/assistant distinction
- ⚡ Real-time responses from ChatGPT
- 🔒 Secure API requests via ProxLock
- 💾 Local credential storage
- ⚙️ In-app settings for ProxLock credentials

[View ChatGPT Demo README →](./ChatGPT-SwiftUI/README.md)

### 2. [Weather iOS Demo](./Weather-SwiftUI/)

A weather application demonstrating ProxLock integration with the Stormglass.io Weather API.

**Features:**
- 🌤️ Current weather conditions
- 📊 Hourly weather forecast
- 📅 5-day weather forecast
- 🌙 Astronomy data (sunrise, sunset)
- 🔒 Secure API requests via ProxLock

[View Weather Demo README →](./Weather-SwiftUI/README.md)

## Getting Started

Each demo project has its own detailed setup instructions. To get started:

1. Choose a demo project that interests you
2. Navigate to its directory and read its README
3. Follow the setup instructions to configure ProxLock and run the app

## Prerequisites

All demo projects require:
- **Xcode** (latest version recommended)
- A **ProxLock account**
- The appropriate **API key** for the service being demonstrated (OpenAI, Stormglass.io, etc.)
- **App Attest capability** (already configured in each project)

## Resources

- [ProxLock Documentation](https://docs.proxlock.dev/)
- [ProxLock iOS SDK Documentation](https://docs.proxlock.dev/ios-sdk/)

## License

These are sample projects for demonstration purposes licensed under the [MIT License](LICENSE).

