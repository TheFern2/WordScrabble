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
import SwiftData

struct SaveLoadView: View {
    //    @State private var gameStates: [GameState] = [
    //        GameState(word: "Example", score: 120, wordList: ["Swift", "UI", "Framework"], completedWords: ["Swift", "UI"], date: Date()),
    //        GameState(word: "Swift", score: 200, wordList: ["Example", "Code", "Sample"], completedWords: ["Example", "Code", "Sample"], date: Date().addingTimeInterval(-86400)),
    //        GameState(word: "Game", score: 150, wordList: ["Play", "Test", "Load"], completedWords: ["Play"], date: Date().addingTimeInterval(-172800))
    //    ]
    
    @Environment(\.modelContext) private var modelContext
    @Query private var savedGameStates: [GameState]
    @ObservedObject var gameState: GameState
    @State private var showAlert = false
    @State private var selectedGameState: GameState?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(savedGameStates, id: \.self) { savedState in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(savedState.word)
                                .font(.headline)
                            Spacer()
                            Text("\(savedState.completedWords.count)/\(savedState.wordList.count) words")
                                .font(.subheadline)
                            Spacer()
                            Text("Score: \(savedState.score)")
                                .font(.subheadline)
                            Button(action: {
                                selectedGameState = savedState
//                                loadGame()
                                showAlert = true
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
            .alert("Load Game", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Load", role: .destructive) {
                    loadGame()
                }
            } message: {
                Text("This will replace your current game state. Do you want to proceed?")
            }
        }
    }
    
    private func loadGame() {
        // Logic to load the game state
        guard let selectedState = selectedGameState else { return }
        print("Loading game: \(selectedState.word)")
        
        // Replace the current `gameState` properties with those of the selected state
        gameState.word = selectedState.word
        gameState.score = selectedState.score
        gameState.wordList = selectedState.wordList
        gameState.completedWords = selectedState.completedWords
        gameState.date = selectedState.date
        gameState.resetShuffledWord()
    }
    
    private func deleteGameState(at offsets: IndexSet) {
        for index in offsets {
            let gameState = savedGameStates[index] // Get the GameState to delete
            modelContext.delete(gameState) // Delete from SwiftData context
        }
        
        // Save the context to persist the deletion
        do {
            try modelContext.save()
        } catch {
            print("Error deleting game state: \(error)")
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
    var previewGameState = GameState(
        word: "Preview",
        score: 150,
        wordList: ["Swift", "UI", "Framework"],
        completedWords: ["Swift", "UI"],
        date: Date()
    )
    SaveLoadView(gameState: previewGameState)
}
