import { useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ChatMessage, Role } from '../types';
import OpenAIService from '../services/OpenAIService';

export const useChatViewModel = () => {
    const [messages, setMessages] = useState<ChatMessage[]>([]);
    const [inputText, setInputText] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [openAIService, setOpenAIService] = useState<OpenAIService | null>(null);

    // Credentials state
    const [partialKey, setPartialKey] = useState('');
    const [associationId, setAssociationId] = useState('');
    const [showSettings, setShowSettings] = useState(false);

    useEffect(() => {
        loadCredentials();
    }, []);

    const loadCredentials = async () => {
        try {
            const pk = await AsyncStorage.getItem('proxlock_partial_key');
            const aid = await AsyncStorage.getItem('proxlock_association_id');

            if (pk && aid) {
                setPartialKey(pk);
                setAssociationId(aid);
                setOpenAIService(new OpenAIService(pk, aid));
            } else {
                setShowSettings(true);
            }
        } catch (e) {
            console.error("Failed to load credentials", e);
        }
    };

    const saveCredentials = async (pk: string, aid: string) => {
        try {
            await AsyncStorage.setItem('proxlock_partial_key', pk);
            await AsyncStorage.setItem('proxlock_association_id', aid);
            setPartialKey(pk);
            setAssociationId(aid);
            setOpenAIService(new OpenAIService(pk, aid));
            setShowSettings(false);
        } catch (e) {
            console.error("Failed to save credentials", e);
        }
    };

    const sendMessage = async () => {
        if (!inputText.trim()) return;
        if (!openAIService) {
            setErrorMessage("Please set your ProxLock credentials in Settings");
            setShowSettings(true);
            return;
        }

        const userMessage: ChatMessage = {
            id: Date.now().toString(),
            role: Role.User,
            content: inputText,
            timestamp: new Date()
        };

        setMessages(prev => [...prev, userMessage]);
        setInputText('');
        setIsLoading(true);
        setErrorMessage(null);

        try {
            // Include previous messages for context
            const allMessages = [...messages, userMessage];
            const responseContent = await openAIService.sendMessage(allMessages);

            const assistantMessage: ChatMessage = {
                id: (Date.now() + 1).toString(),
                role: Role.Assistant,
                content: responseContent,
                timestamp: new Date()
            };

            setMessages(prev => [...prev, assistantMessage]);
        } catch (error: any) {
            setErrorMessage(error.message || "An unknown error occurred");
            // Ideally remove user message or show error state but for now just show error
        } finally {
            setIsLoading(false);
        }
    };

    const clearChat = () => {
        setMessages([]);
        setErrorMessage(null);
    };

    return {
        messages,
        inputText,
        setInputText,
        isLoading,
        errorMessage,
        sendMessage,
        clearChat,
        showSettings,
        setShowSettings,
        partialKey,
        associationId,
        saveCredentials,
        setErrorMessage // Exporting this to allow clearing it
    };
};
