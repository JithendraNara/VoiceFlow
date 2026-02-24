import Foundation

class AnthropicProvider: AIProviderProtocol {
    var name: String = "Anthropic"
    var apiKey: String = ""

    private let baseURL = "https://api.anthropic.com/v1"

    func generateResponse(prompt: String, context: [String], style: AIResponseStyle, maxTokens: Int) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.invalidAPIKey
        }

        let url = URL(string: "\(baseURL)/messages")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.networkError
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw AIError.invalidAPIKey
        case 429:
            throw AIError.rateLimited
        default:
            throw AIError.networkError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }

        return text
    }

    func generateFollowUpQuestions(question: String, context: [String]) async throws -> [String] {
        let prompt = """
        Based on this interview question, suggest 3 natural follow-up questions an interviewer might ask:

        Question: \(question)

        Provide exactly 3 questions, one per line.
        """

        let response = try await generateResponse(
            prompt: prompt,
            context: context,
            style: .concise,
            maxTokens: 100
        )

        return response
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(3)
            .map { String($0) }
    }

    func validateAPIKey(_ key: String) async throws -> Bool {
        let originalKey = apiKey
        apiKey = key

        do {
            _ = try await generateResponse(
                prompt: "Hi",
                context: [],
                style: .concise,
                maxTokens: 5
            )
            return true
        } catch {
            apiKey = originalKey
            return false
        }
    }
}
