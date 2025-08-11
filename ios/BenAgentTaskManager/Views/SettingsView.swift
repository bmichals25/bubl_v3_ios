import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @State private var appKey: String = ""
    @State private var saved: Bool = false

    var body: some View {
        Form {
            Section("App API Key") {
                TextField("Paste base64 App API Key", text: $appKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Save & Apply") {
                    saved = config.saveAppAPIKey(b64Encoded: appKey)
                }
                if saved { Text("Saved").foregroundColor(.green) }
            }
            if config.isConfigured {
                Section("Resolved") {
                    Text("OpenAI: \(masked(config.openAIKey))")
                    Text("Supabase URL: \(config.supabaseURL?.absoluteString ?? "-")")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear { saved = false }
    }

    private func masked(_ s: String) -> String {
        guard s.count > 8 else { return "••••" }
        let head = s.prefix(4)
        let tail = s.suffix(4)
        return "\(head)••••\(tail)"
    }
}