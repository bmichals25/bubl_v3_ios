import Foundation
import Security

final class AppConfig: ObservableObject {
    @Published private(set) var isConfigured: Bool = false

    @Published private(set) var openAIKey: String = ""
    @Published private(set) var supabaseURL: URL?
    @Published private(set) var supabaseAnonKey: String = ""

    private let keychainService = "com.example.BenAgentTaskManager"
    private let keychainAccount = "AppAPIKey"

    func bootstrapIfPossible() {
        if let b64 = readFromKeychain(), !b64.isEmpty {
            _ = applyAppAPIKey(b64Encoded: b64)
        }
    }

    func saveAppAPIKey(b64Encoded: String) -> Bool {
        guard applyAppAPIKey(b64Encoded: b64Encoded) else { return false }
        saveToKeychain(b64Encoded)
        return true
    }

    @discardableResult
    private func applyAppAPIKey(b64Encoded: String) -> Bool {
        guard let data = Data(base64Encoded: b64Encoded) else { return false }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }
        guard let openai = json["openai"] as? String,
              let supaURLString = json["supabase_url"] as? String,
              let supaURL = URL(string: supaURLString),
              let supaAnon = json["supabase_anon"] as? String else {
            return false
        }
        DispatchQueue.main.async {
            self.openAIKey = openai
            self.supabaseURL = supaURL
            self.supabaseAnonKey = supaAnon
            self.isConfigured = true
        }
        return true
    }

    private func saveToKeychain(_ value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
        var attrs = query
        attrs[kSecValueData as String] = data
        SecItemAdd(attrs as CFDictionary, nil)
    }

    private func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}