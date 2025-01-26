//
//  CardCandidateListView.swift
//  LearningMentor
//
//  显示 GPT 提取到的卡片候选，用户多选后导入Anki
//

import SwiftUI

struct CardCandidateListView: View {
    @Binding var cards: [ExtractedCard]
    
    @State private var selections: Set<UUID> = []
    
    var onConfirm: ([ExtractedCard]) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("GPT 提取到以下卡片，请选择要导入Anki：")
                .font(.headline)
                .padding(.bottom, 8)
            
            List(selection: $selections) {
                ForEach(cards) { card in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(card.type.uppercased()) - \(card.front)")
                            .font(.subheadline).bold()
                        
                        Text("Back: \(card.back)")
                            .font(.footnote)
                        
                        if !card.example.isEmpty {
                            Text("Example: \(card.example)")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        
                        if !card.note.isEmpty {
                            Text("Note: \(card.note)")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Spacer()
                Button("取消", action: onCancel)
                Button("导入所选") {
                    let selected = cards.filter { selections.contains($0.id) }
                    onConfirm(selected)
                }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
    }
}
