export enum Role {
    User = 'user',
    Assistant = 'assistant',
}

export interface ChatMessage {
    id: string;
    role: Role;
    content: string;
    timestamp: Date;
}
