import Foundation

protocol AIProviderProtocol {
    var name: String { get }
    func generateResponse(prompt: String, context: [String], style: AIResponseStyle, maxTokens: Int) async throws -> String
    func generateFollowUpQuestions(question: String, context: [String]) async throws -> [String]
    func validateAPIKey(_ key: String) async throws -> Bool
}

class AIService: ObservableObject {
    static let shared = AIService()

    @Published var currentProvider: AIProviderProtocol?

    private var providers: [AIProviderType: AIProviderProtocol] = [:]

    private init() {
        setupProviders()
    }

    private func setupProviders() {
        providers[.openAI] = OpenAIProvider()
        providers[.anthropic] = AnthropicProvider()
        providers[.google] = GoogleProvider()
    }

    func setProvider(_ type: AIProviderType, apiKey: String) {
        guard let provider = providers[type] else { return }

        switch type {
        case .openAI:
            (provider as? OpenAIProvider)?.apiKey = apiKey
        case .anthropic:
            (provider as? AnthropicProvider)?.apiKey = apiKey
        case .google:
            (provider as? GoogleProvider)?.apiKey = apiKey
        default:
            break
        }

        currentProvider = provider
    }

    func generateInterviewResponse(
        transcribedQuestion: String,
        scriptContext: String,
        mode: AIMode,
        style: AIResponseStyle,
        maxLength: Int
    ) async throws -> String {
        guard let provider = currentProvider else {
            throw AIError.noProviderSelected
        }

        let prompt = buildPrompt(
            question: transcribedQuestion,
            context: scriptContext,
            mode: mode,
            style: style,
            maxLength: maxLength
        )

        return try await provider.generateResponse(
            prompt: prompt,
            context: [scriptContext],
            style: style,
            maxTokens: maxLength * 2
        )
    }

    func generateFollowUps(for question: String, context: [String]) async throws -> [String] {
        guard let provider = currentProvider else {
            throw AIError.noProviderSelected
        }

        return try await provider.generateFollowUpQuestions(
            question: question,
            context: context
        )
    }

    private func buildPrompt(
        question: String,
        context: String,
        mode: AIMode,
        style: AIResponseStyle,
        maxLength: Int
    ) -> String {
        let styleInstruction: String
        switch style {
        case .professional:
            styleInstruction = "Use professional language, industry terminology, and formal tone."
        case .casual:
            styleInstruction = "Use conversational language, be friendly and approachable."
        case .concise:
            styleInstruction = "Be brief and to the point, get to the answer quickly."
        case .detailed:
            styleInstruction = "Provide comprehensive details, include examples and specifics."
        }

        let modeInstruction: String
        switch mode {
        case .interviewCoach:
            modeInstruction = "Provide a suggested response to the interviewer's question based on the script context."
        case .qaGenerator:
            modeInstruction = "Generate a complete answer to the question."
        case .starMethod:
            modeInstruction = "Structure the response using STAR method (Situation, Task, Action, Result)."
        case .keywordBooster:
            modeInstruction = "Include relevant industry keywords and buzzwords naturally."
        case .custom:
            modeInstruction = "Respond according to custom instructions if provided."
        }

        return """
        Interview Question: \(question)

        Script/Context: \(context)

        \(modeInstruction)

        \(styleInstruction)

        Keep the response to approximately \(maxLength) words.

        Suggested Response:
        """
    }
}

enum AIError: LocalizedError {
    case noProviderSelected
    case invalidAPIKey
    case rateLimited
    case networkError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noProviderSelected:
            return "No AI provider selected. Please configure an API key."
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        case .rateLimited:
            return "Rate limited. Please wait and try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidResponse:
            return "Invalid response from AI provider."
        }
    }
}
