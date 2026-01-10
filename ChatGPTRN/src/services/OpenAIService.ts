import { ProxLockSession } from 'proxlock-react-native';
import { ChatMessage } from '../types';

class OpenAIService {
    private session: ProxLockSession;
    private baseURL = "https://api.proxlock.dev/proxy";

    constructor(partialKey: string, associationID: string) {
        // Initialize ProxLockSession
        // TODO: Add Android Config if needed for Play Integrity
        this.session = new ProxLockSession(partialKey, associationID, { cloudProjectNumber: '000000000000' });
    }

    async sendMessage(messages: ChatMessage[]): Promise<string> {
        const targetUrl = "https://api.openai.com/v1/chat/completions";
        const method = "POST";

        try {
            const headers = await this.session.getRequestHeaders(targetUrl, method);

            // Add standard headers
            headers['Content-Type'] = 'application/json';
            // The Authorization header uses the bearerToken from the session which contains the placeholder
            headers['Authorization'] = `Bearer ${this.session.bearerToken}`;

            const requestBody = {
                model: "gpt-4o-mini",
                messages: messages.map(msg => ({
                    role: msg.role,
                    content: msg.content
                })),
                stream: false
            };

            const response = await fetch(this.baseURL, {
                method: method,
                headers: headers,
                body: JSON.stringify(requestBody)
            });

            if (!response.ok) {
                const errorText = await response.text();
                // Check if it's a JSON error
                try {
                    const errorJson = JSON.parse(errorText);
                    if (errorJson.error && errorJson.error.message) {
                        throw new Error(errorJson.error.message);
                    }
                } catch (e) {
                    // Ignore JSON parse error, use text
                }
                throw new Error(`API Error: ${response.status} - ${errorText}`);
            }

            const data = await response.json();

            if (data.choices && data.choices.length > 0 && data.choices[0].message) {
                return data.choices[0].message.content;
            } else {
                throw new Error("Invalid response format from OpenAI");
            }
        } catch (error) {
            console.error("OpenAI Service Error:", error);
            throw error;
        }
    }
}

export default OpenAIService;
