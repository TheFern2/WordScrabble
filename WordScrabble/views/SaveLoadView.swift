//
//  SaveLoadView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//

/*
    This view will allow the user to save and load data.
    Need a GameState class word, wordCount, score, wordList, completedWords.
    The ui should have a list of saved game states that the user can select to load.
    A row should display in one HStack word, completed words, score, and load button and swipe to delete. and date below word.
 */

import SwiftUI

struct SaveLoadView: View {
    @State private var gameStates: [GameState] = [
        GameState(word: "Example", score: 120, wordList: ["Swift", "UI", "Framework"], completedWords: ["Swift", "UI"], date: Date()),
        GameState(word: "Swift", score: 200, wordList: ["Example", "Code", "Sample"], completedWords: ["Example", "Code", "Sample"], date: Date().addingTimeInterval(-86400)),
        GameState(word: "Game", score: 150, wordList: ["Play", "Test", "Load"], completedWords: ["Play"], date: Date().addingTimeInterval(-172800))
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach($gameStates, id: \.self) { $gameState in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(gameState.word)
                                .font(.headline)
                            Spacer()
                            Text("\(gameState.completedWords.count)/\(gameState.wordList.count) words")
                                .font(.subheadline)
                            Spacer()
                            Text("Score: \(gameState.score)")
                                .font(.subheadline)
                            Button(action: {
                                loadGame(gameState)
                            }) {
                                Text("Load")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text("Date: \(gameState.date, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteGameState)
            }
            .navigationTitle("Saved Games")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func loadGame(_ gameState: GameState) {
        // Logic to load the game state
        print("Loading game: \(gameState.word)")
    }
    
    private func deleteGameState(at offsets: IndexSet) {
        gameStates.remove(atOffsets: offsets)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    SaveLoadView()
}
