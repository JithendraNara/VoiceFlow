import Foundation

class GoogleProvider: AIProviderProtocol {
    var name: String = "Google"
    var apiKey: String = ""

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"

    func generateResponse(prompt: String, context: [String], style: AIResponseStyle, maxTokens: Int) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.invalidAPIKey
        }

        let url = URL(string: "\(baseURL)/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "maxOutputTokens": maxTokens,
                "temperature": 0.7
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
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw AIError.invalidResponse
        }

        return text
    }

    func generateFollowUpQuestions(question: String, context: [String]) async throws -> [String] {
        let prompt = """
        Suggest 3 follow-up questions for this interview question:
        \(question)

        One per line, no numbering.
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
