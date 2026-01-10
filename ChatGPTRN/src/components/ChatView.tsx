import React, { useRef, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, FlatList, ActivityIndicator, StyleSheet, KeyboardAvoidingView, Platform, SafeAreaView } from 'react-native';
import { useChatViewModel } from '../hooks/useChatViewModel';
import MessageBubble from './MessageBubble';
import SettingsView from './SettingsView';

const ChatView = () => {
    const {
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
        setErrorMessage
    } = useChatViewModel();

    const flatListRef = useRef<FlatList>(null);

    // Scroll to bottom when messages change
    useEffect(() => {
        if (messages.length > 0) {
            setTimeout(() => {
                flatListRef.current?.scrollToEnd({ animated: true });
            }, 100);
        }
    }, [messages, isLoading]);

    const renderEmptyState = () => (
        <View style={styles.emptyContainer}>
            <Text style={styles.emptyIcon}>💬</Text>
            <Text style={styles.emptyTitle}>Start a conversation</Text>
            <Text style={styles.emptyDescription}>
                Type a message below to begin chatting with ChatGPT
            </Text>
        </View>
    );

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <TouchableOpacity
                    onPress={clearChat}
                    disabled={messages.length === 0}
                    style={{ opacity: messages.length === 0 ? 0.3 : 1 }}
                >
                    <Text style={styles.headerButton}>🗑️</Text>
                </TouchableOpacity>
                <Text style={styles.headerTitle}>ChatGPT</Text>
                <TouchableOpacity onPress={() => setShowSettings(true)}>
                    <Text style={styles.headerButton}>⚙️</Text>
                </TouchableOpacity>
            </View>

            {errorMessage && (
                <View style={styles.errorContainer}>
                    <Text style={styles.errorText}>⚠️ {errorMessage}</Text>
                    <TouchableOpacity onPress={() => setErrorMessage(null)}>
                        <Text style={styles.closeError}>✖️</Text>
                    </TouchableOpacity>
                </View>
            )}

            <View style={styles.chatArea}>
                {messages.length === 0 && !isLoading ? renderEmptyState() : (
                    <FlatList
                        ref={flatListRef}
                        data={messages}
                        keyExtractor={item => item.id}
                        renderItem={({ item }) => <MessageBubble message={item} />}
                        contentContainerStyle={styles.listContent}
                        ListFooterComponent={isLoading ? (
                            <View style={styles.loadingContainer}>
                                <ActivityIndicator size="small" color="#007AFF" />
                                <Text style={styles.loadingText}>Thinking...</Text>
                            </View>
                        ) : null}
                    />
                )}
            </View>

            <KeyboardAvoidingView
                behavior={Platform.OS === "ios" ? "padding" : undefined}
                keyboardVerticalOffset={Platform.OS === "ios" ? 10 : 0}
            >
                <View style={styles.inputContainer}>
                    <TextInput
                        style={styles.input}
                        value={inputText}
                        onChangeText={setInputText}
                        placeholder="Type a message..."
                        multiline
                        maxLength={500}
                        editable={!isLoading}
                    />
                    <TouchableOpacity
                        style={[styles.sendButton, (!inputText.trim() || isLoading) && styles.sendButtonDisabled]}
                        onPress={sendMessage}
                        disabled={!inputText.trim() || isLoading}
                    >
                        <Text style={styles.sendButtonText}>➜</Text>
                    </TouchableOpacity>
                </View>
            </KeyboardAvoidingView>

            <SettingsView
                visible={showSettings}
                onClose={() => setShowSettings(false)}
                initialPartialKey={partialKey}
                initialAssociationId={associationId}
                onSave={saveCredentials}
            />
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 16,
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#eee',
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: '600',
    },
    headerButton: {
        fontSize: 20,
    },
    chatArea: {
        flex: 1,
    },
    listContent: {
        padding: 16,
        paddingBottom: 20,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
        marginTop: 60,
    },
    emptyIcon: {
        fontSize: 60,
        marginBottom: 20,
        opacity: 0.5,
    },
    emptyTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        marginBottom: 8,
        color: '#666',
    },
    emptyDescription: {
        fontSize: 14,
        color: '#888',
        textAlign: 'center',
    },
    loadingContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 10,
        marginLeft: 10,
    },
    loadingText: {
        marginLeft: 8,
        color: '#888',
        fontSize: 14,
    },
    errorContainer: {
        backgroundColor: '#FFEBEE',
        padding: 10,
        paddingHorizontal: 16,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    errorText: {
        color: '#D32F2F',
        fontSize: 12,
        flex: 1,
    },
    closeError: {
        fontSize: 16,
        color: '#D32F2F',
        marginLeft: 10,
    },
    inputContainer: {
        flexDirection: 'row',
        padding: 12,
        borderTopWidth: 1,
        borderTopColor: '#eee',
        alignItems: 'flex-end',
        backgroundColor: '#fff',
        marginBottom: 0,
    },
    input: {
        flex: 1,
        backgroundColor: '#f2f2f7',
        borderRadius: 20,
        paddingHorizontal: 16,
        paddingTop: 10,
        paddingBottom: 10,
        fontSize: 16,
        maxHeight: 100,
        minHeight: 40,
    },
    sendButton: {
        marginLeft: 10,
        backgroundColor: '#007AFF',
        width: 36,
        height: 36,
        borderRadius: 18,
        justifyContent: 'center',
        alignItems: 'center',
    },
    sendButtonDisabled: {
        backgroundColor: '#ccc',
    },
    sendButtonText: {
        color: '#fff',
        fontSize: 18,
        fontWeight: 'bold',
    },
});

export default ChatView;
