import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Modal, SafeAreaView, KeyboardAvoidingView, Platform } from 'react-native';

interface Props {
    visible: boolean;
    onClose: () => void;
    initialPartialKey: string;
    initialAssociationId: string;
    onSave: (pk: string, aid: string) => void;
}

const SettingsView = ({ visible, onClose, initialPartialKey, initialAssociationId, onSave }: Props) => {
    const [partialKey, setPartialKey] = useState(initialPartialKey);
    const [associationId, setAssociationId] = useState(initialAssociationId);

    // Update state when modal opens with initial values
    React.useEffect(() => {
        if (visible) {
            setPartialKey(initialPartialKey);
            setAssociationId(initialAssociationId);
        }
    }, [visible, initialPartialKey, initialAssociationId]);

    const handleSave = () => {
        onSave(partialKey, associationId);
    };

    return (
        <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
            <SafeAreaView style={styles.container}>
                <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.keyboardView}>
                    <View style={styles.header}>
                        <Text style={styles.title}>Settings</Text>
                        <TouchableOpacity onPress={onClose} style={styles.closeButton}>
                            <Text style={styles.closeButtonText}>Close</Text>
                        </TouchableOpacity>
                    </View>

                    <View style={styles.content}>
                        <Text style={styles.label}>Partial Key</Text>
                        <TextInput
                            style={styles.input}
                            value={partialKey}
                            onChangeText={setPartialKey}
                            placeholder="Enter Partial Key"
                            autoCapitalize="none"
                            autoCorrect={false}
                        />

                        <Text style={styles.label}>Association ID</Text>
                        <TextInput
                            style={styles.input}
                            value={associationId}
                            onChangeText={setAssociationId}
                            placeholder="Enter Association ID"
                            autoCapitalize="none"
                            autoCorrect={false}
                        />

                        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
                            <Text style={styles.saveButtonText}>Save Credentials</Text>
                        </TouchableOpacity>
                    </View>
                </KeyboardAvoidingView>
            </SafeAreaView>
        </Modal>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
    },
    keyboardView: {
        flex: 1,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: '#eee',
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
    },
    closeButton: {},
    closeButtonText: {
        fontSize: 16,
        color: '#007AFF',
    },
    content: {
        padding: 20,
    },
    label: {
        fontSize: 14,
        fontWeight: '600',
        marginBottom: 8,
        color: '#333',
    },
    input: {
        backgroundColor: '#f2f2f7',
        padding: 12,
        borderRadius: 10,
        marginBottom: 20,
        fontSize: 16,
    },
    saveButton: {
        backgroundColor: '#007AFF',
        padding: 16,
        borderRadius: 12,
        alignItems: 'center',
        marginTop: 20,
    },
    saveButtonText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '600',
    },
});

export default SettingsView;
