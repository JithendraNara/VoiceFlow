import Foundation

enum AIProviderType: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case google = "Google"
    case deepseek = "DeepSeek"
    case xAI = "xAI"
    case minimax = "Minimax"

    var id: String { rawValue }

    var models: [String] {
        switch self {
        case .openAI: return ["gpt-5.2", "gpt-5.1", "gpt-realtime-mini"]
        case .anthropic: return ["claude-opus-4.5", "claude-sonnet-4.5", "claude-haiku-3.5"]
        case .google: return ["gemini-2.5-pro", "gemini-2.0-flash"]
        case .deepseek: return ["deepseek-chat", "deepseek-coder"]
        case .xAI: return ["grok-2", "grok-2-vision"]
        case .minimax: return ["text-01"]
        }
    }
}

struct AIProvider: Codable {
    var type: AIProviderType
    var apiKey: String
    var model: String
    var isEnabled: Bool

    init(type: AIProviderType, apiKey: String = "", model: String? = nil, isEnabled: Bool = false) {
        self.type = type
        self.apiKey = apiKey
        self.model = model ?? type.models.first ?? ""
        self.isEnabled = isEnabled
    }
}

enum AIMode: String, CaseIterable, Identifiable {
    case interviewCoach = "Interview Coach"
    case qaGenerator = "Q&A Generator"
    case starMethod = "STAR Method"
    case keywordBooster = "Keyword Booster"
    case custom = "Custom"

    var id: String { rawValue }
}

enum AIResponseStyle: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case casual = "Casual/Friendly"
    case concise = "Concise"
    case detailed = "Detailed"

    var id: String { rawValue }
}
