import Foundation
import Observation

/// Live-validation helper for the API Keys wizard. The whole point is
/// to turn "you'll find out your key is typo'd when your agent
/// silently fails an hour from now" into "press Test, get a green
/// check in 2 seconds".
///
/// Each provider gets a minimal, cheap call:
/// - Anthropic: POST /v1/messages with max_tokens=1
/// - OpenAI:    GET  /v1/models
/// - Google:    GET  /v1beta/models?key=…
/// - Groq:      GET  /openai/v1/models
/// - OpenRouter: GET /api/v1/models with Bearer auth
/// - Mistral:   GET  /v1/models
///
/// Unknown-auth or missing providers just short-circuit to a helpful
/// message so the UI never hangs forever.
@MainActor
@Observable
final class ProviderKeyTester {
    enum Status: Equatable {
        case idle
        case testing
        case ok(String)        // friendly success line
        case failed(String)    // short, user-legible error
    }

    /// Per-provider status keyed by ModelProvider.id.
    var statuses: [String: Status] = [:]

    func status(for providerID: String) -> Status {
        statuses[providerID] ?? .idle
    }

    func test(provider: ModelProvider, apiKey: String) {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statuses[provider.id] = .failed("Paste a key first.")
            return
        }

        statuses[provider.id] = .testing
        Task { [weak self] in
            let result = await Self.runCheck(provider: provider, key: trimmed)
            await MainActor.run { self?.statuses[provider.id] = result }
        }
    }

    // MARK: - Provider-specific probes

    private static func runCheck(provider: ModelProvider, key: String) async -> Status {
        do {
            switch provider.id {
            case "anthropic":
                return try await pingAnthropic(key: key)
            case "openai":
                return try await pingGET(
                    url: URL(string: "https://api.openai.com/v1/models")!,
                    headers: ["Authorization": "Bearer \(key)"]
                )
            case "google":
                return try await pingGET(
                    url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(key)")!,
                    headers: [:]
                )
            case "groq":
                return try await pingGET(
                    url: URL(string: "https://api.groq.com/openai/v1/models")!,
                    headers: ["Authorization": "Bearer \(key)"]
                )
            case "openrouter":
                return try await pingGET(
                    url: URL(string: "https://openrouter.ai/api/v1/models")!,
                    headers: ["Authorization": "Bearer \(key)"]
                )
            case "mistral":
                return try await pingGET(
                    url: URL(string: "https://api.mistral.ai/v1/models")!,
                    headers: ["Authorization": "Bearer \(key)"]
                )
            default:
                return .failed("No live check available for this provider yet.")
            }
        } catch {
            return .failed("Network error: \(error.localizedDescription)")
        }
    }

    /// Anthropic wants a real messages call to validate auth + access.
    /// We use max_tokens=1 and a 1-word prompt so the cost is trivial.
    private static func pingAnthropic(key: String) async throws -> Status {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5",
            "max_tokens": 1,
            "messages": [["role": "user", "content": "ok"]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        return interpret(response: response, data: data, successMessage: "Key works — Anthropic accepted the request.")
    }

    /// GET-based probe used for providers that expose an authed models
    /// listing endpoint — cheapest possible auth check.
    private static func pingGET(url: URL, headers: [String: String]) async throws -> Status {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        for (k, v) in headers { request.setValue(v, forHTTPHeaderField: k) }

        let (data, response) = try await URLSession.shared.data(for: request)
        return interpret(response: response, data: data, successMessage: "Key works — provider accepted auth.")
    }

    /// Map an HTTPURLResponse onto a friendly Status. We treat 2xx as a
    /// pass even if body JSON isn't perfect — the point is to confirm
    /// the key auths; we're not testing deep capability here.
    private static func interpret(response: URLResponse, data: Data, successMessage: String) -> Status {
        guard let http = response as? HTTPURLResponse else {
            return .failed("No HTTP response from the provider.")
        }

        if (200..<300).contains(http.statusCode) {
            return .ok(successMessage)
        }

        // Try to pull a useful message from the error body so the user
        // can actually do something with it.
        if let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = payload["error"] as? [String: Any],
           let message = error["message"] as? String {
            return .failed("\(http.statusCode): \(message)")
        }

        switch http.statusCode {
        case 401, 403:
            return .failed("\(http.statusCode): key was rejected. Double-check you pasted the full key.")
        case 429:
            return .failed("429: rate-limited. Try again in a minute.")
        default:
            return .failed("HTTP \(http.statusCode) — unexpected response from provider.")
        }
    }
}
