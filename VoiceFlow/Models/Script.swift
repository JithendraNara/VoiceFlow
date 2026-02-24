import Foundation

struct Script: Codable {
    var content: String
    var lastModified: Date

    init(content: String = "") {
        self.content = content
        self.lastModified = Date()
    }

    var wordCount: Int {
        content.split(separator: " ").count
    }

    var characterCount: Int {
        content.count
    }
}
