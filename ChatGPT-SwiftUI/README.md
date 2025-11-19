# ProxLock iOS Demo - ChatGPT App

This is a sample iOS application demonstrating how to use [ProxLock](https://docs.proxlock.dev/) to securely proxy API requests to the OpenAI ChatGPT API. The app provides a full-featured chat interface for interacting with ChatGPT, with all API requests securely proxied through ProxLock.

## Features

- 💬 Full ChatGPT chat interface
- 🎨 Beautiful message bubbles with user/assistant distinction
- ⚡ Real-time responses from ChatGPT
- 🔒 Secure API requests via ProxLock
- 💾 Local credential storage
- ⚙️ In-app settings for ProxLock credentials
- 📱 Works on both simulator and real devices
- 🧹 Clear chat functionality

## Prerequisites

Before you begin, make sure you have:

- **Xcode** installed (latest version recommended)
- A **ProxLock account**
- An **OpenAI API key** - Sign up at [platform.openai.com](https://platform.openai.com/)
- **App Attest capability** enabled (already configured in this project)

## Setup Instructions

### 0. Configure Development Team

Open the `Signing & Capabilities` tab under the `ProxLock-Demo` target and select your development team.

### 1. Get Your OpenAI API Key

1. Visit [platform.openai.com](https://platform.openai.com/) and create an account
2. Navigate to your API keys section and generate a new API key
3. Copy your API key - you'll need this for ProxLock configuration

### 2. Configure ProxLock

1. Log in to the [ProxLock web dashboard](https://docs.proxlock.dev/)
2. Navigate to your project
3. Add a new API key:
   - Click "Add Key"
   - Enter your OpenAI API key as the full key
   - Add `api.openai.com` to the whitelisted URLs
   - Save the key
4. Copy your credentials from the key card:
   - **Partial Key** - This is the partial key shown in your dashboard
   - **Association ID** - This is the association ID for your key
5. (Optional) For simulator testing, get your **Bypass Token**:
   - Navigate to the Device Check section in your dashboard
   - Copy the bypass token

### 3. Run the App

1. Open the project in Xcode
2. Select your target device (simulator or real device)
3. Press **⌘R** or click the **Run** button
4. The app will launch and prompt you to enter your ProxLock credentials
5. Tap the settings icon (⚙️) in the top right corner
6. Enter your **Partial Key** and **Association ID** from ProxLock
7. Tap **Save** or **Done**
8. Start chatting with ChatGPT!

### 4. (Optional) Configure Environment Variables for Simulator Testing

If you want to test in the simulator, you can set up environment variables for the bypass token:

1. Go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Environment Variables**, click the **+** button
5. Add:
   - Name: `PROXLOCK_DEVICE_CHECK_BYPASS`
   - Value: Your bypass token from ProxLock dashboard
6. Click **Close** to save your changes

**Note:** The app stores ProxLock credentials locally using UserDefaults, so you only need to enter them once. The bypass token environment variable is only needed for simulator testing.

## Project Structure

```
ProxLock-Demo/
├── ProxLock-Demo/
│   ├── Services/
│   │   └── OpenAIService.swift          # Service for ChatGPT API requests via ProxLock
│   ├── ViewModels/
│   │   └── ChatViewModel.swift          # View model managing chat state
│   ├── Views/
│   │   ├── ContentView.swift            # Main entry point
│   │   ├── ChatView.swift               # Main chat interface
│   │   └── SettingsView.swift           # Settings for ProxLock credentials
│   ├── Models/
│   │   └── Message.swift                # Chat message data models
│   └── ProxLock_DemoApp.swift           # App entry point
└── README.md
```

## How ProxLock Works in This App

The app uses ProxLock to securely proxy requests to OpenAI's ChatGPT API:

1. **PLSession Setup**: A `PLSession` is created using your partial key and association ID (entered in Settings)
2. **Bearer Token**: The app uses `session.bearerToken` in the Authorization header instead of the full API key
3. **Request Proxying**: All requests go through ProxLock, which:
   - Validates the request using Device Check
   - Replaces the bearer token placeholder with your full OpenAI API key
   - Forwards the request to OpenAI's API
   - Returns the response to your app

See `OpenAIService.swift` for the implementation details.

## Usage

1. **First Launch**: The app will automatically open the Settings screen if no credentials are configured
2. **Enter Credentials**: Enter your ProxLock Partial Key and Association ID
3. **Start Chatting**: Type a message and tap the send button (or press Enter)
4. **View Responses**: ChatGPT responses appear in gray bubbles on the left
5. **Clear Chat**: Tap the trash icon in the top left to clear the conversation
6. **Change Settings**: Tap the settings icon (⚙️) to update your ProxLock credentials

## Testing

### Simulator Testing

- Requires the `PROXLOCK_DEVICE_CHECK_BYPASS` environment variable to be set
- Device Check doesn't work in the simulator, so the bypass token is required
- Credentials are still entered through the in-app Settings

### Real Device Testing

- Device Check works automatically on real devices
- No bypass token needed
- This is the recommended way to test before releasing

## Troubleshooting

### "Please set your ProxLock credentials in Settings" Error

- Make sure you've entered both the Partial Key and Association ID in Settings
- Verify that your credentials are correct from the ProxLock dashboard
- Try clearing the app's data and re-entering credentials

### Device Check Errors

- **On Simulator**: Make sure `PROXLOCK_DEVICE_CHECK_BYPASS` is set in your run scheme environment variables
- **On Real Device**: Verify that App Attest is enabled in your target's capabilities (already configured)

### Request Failures

- Verify your OpenAI API key is valid and active
- Check that `https://api.openai.com` is whitelisted in your ProxLock key configuration
- Ensure you're using the correct partial key and association ID
- Check that you haven't exceeded your OpenAI API rate limits or usage quotas
- Review the error message displayed in the app for more details

### Network Errors

- Check your internet connection
- Verify the ProxLock service is accessible
- Check Xcode console for detailed error messages

### Messages Not Sending

- Ensure ProxLock credentials are properly saved (check Settings)
- Verify the input field is not empty
- Check for error messages displayed in the app
- Make sure you're not in a loading state (wait for previous message to complete)

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **@Observable**: Uses the new Swift observation framework for state management
- **Async/Await**: All network requests use modern Swift concurrency
- **ProxLock SDK**: Integrated via Swift Package Manager

### Security

- Full OpenAI API key never stored in the app
- Only ProxLock partial key and association ID are stored locally
- All API requests are proxied through ProxLock
- Device Check validation ensures requests come from legitimate devices

## Resources

- [ProxLock iOS SDK Documentation](https://docs.proxlock.dev/ios-sdk/)
- [OpenAI API Documentation](https://platform.openai.com/docs/)
- [ChatGPT API Reference](https://platform.openai.com/docs/api-reference/chat)

## License

This is a sample project for demonstration purposes.

