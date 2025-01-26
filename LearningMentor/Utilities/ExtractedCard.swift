//
//  ExtractedCard.swift
//  LearningMentor
//
//  GPT 提取出来的候选卡片，用于 Anki 导入
//

import Foundation

struct ExtractedCard: Decodable, Identifiable {
    let id = UUID()
    
    let type: String
    let front: String
    let back: String
    let example: String
    let note: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case type, front, back, example, note, tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        front = try container.decode(String.self, forKey: .front)
        back = try container.decode(String.self, forKey: .back)
        example = try container.decode(String.self, forKey: .example)
        note = try container.decode(String.self, forKey: .note)
        tags = try container.decode([String].self, forKey: .tags)
        // id 保持自动生成的 UUID()
    }
}
