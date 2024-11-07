//
//  ScoreboardView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//

/*
     Scoreboard need to be in the following format:
     word, wordCount, score, date and swipe to delete.
     When a player surpases the previous score, the new score should be updated.
 */

import SwiftUI
import SwiftData

struct ScoreboardView: View {
   // @State private var scores: [Score] = [
//        Score(word: "Swift", wordCount: 5, score: 100, date: Date()),
//        Score(word: "UI", wordCount: 2, score: 200, date: Date().addingTimeInterval(-86400)),
//        Score(word: "Framework", wordCount: 9, score: 150, date: Date().addingTimeInterval(-172800))
  //  ]
    
    @Query private var scores: [Score] // Fetch all saved scores from SwiftData
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            List {
                ForEach(scores, id: \.self) { score in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(score.word)
                                .font(.headline)
                            Spacer()
                            Text("\(score.wordCount) words")
                                .font(.subheadline)
                            Spacer()
                            Text("Score: \(score.score)")
                                .font(.subheadline)
                        }
                        Text("Date: \(score.date, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteScore)
            }
            .navigationTitle("Scoreboard")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func deleteScore(at offsets: IndexSet) {
        for index in offsets {
            let score = scores[index]
            modelContext.delete(score) // Delete from SwiftData context
        }
        
        // Save the context to persist the deletion
        do {
            try modelContext.save()
        } catch {
            print("Error deleting score: \(error)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    ScoreboardView()
}
