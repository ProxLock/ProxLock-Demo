import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { ChatMessage, Role } from '../types';

interface Props {
    message: ChatMessage;
}

const MessageBubble = ({ message }: Props) => {
    const isUser = message.role === Role.User;

    return (
        <View style={[
            styles.container,
            isUser ? styles.userContainer : styles.assistantContainer
        ]}>
            <View style={[
                styles.bubble,
                isUser ? styles.userBubble : styles.assistantBubble
            ]}>
                <Text style={[
                    styles.text,
                    isUser ? styles.userText : styles.assistantText
                ]}>
                    {message.content}
                </Text>
                <Text style={[
                    styles.timestamp,
                    isUser ? styles.userTimestamp : styles.assistantTimestamp
                ]}>
                    {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </Text>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        width: '100%',
        marginVertical: 4,
        flexDirection: 'row',
    },
    userContainer: {
        justifyContent: 'flex-end',
    },
    assistantContainer: {
        justifyContent: 'flex-start',
    },
    bubble: {
        maxWidth: '80%',
        padding: 12,
        borderRadius: 20,
    },
    userBubble: {
        backgroundColor: '#007AFF',
        borderBottomRightRadius: 4,
    },
    assistantBubble: {
        backgroundColor: '#E5E5EA',
        borderBottomLeftRadius: 4,
    },
    text: {
        fontSize: 16,
    },
    userText: {
        color: '#FFFFFF',
    },
    assistantText: {
        color: '#000000',
    },
    timestamp: {
        fontSize: 10,
        marginTop: 4,
        alignSelf: 'flex-end',
    },
    userTimestamp: {
        color: 'rgba(255, 255, 255, 0.7)',
    },
    assistantTimestamp: {
        color: 'rgba(0, 0, 0, 0.5)',
    },
});

export default MessageBubble;
