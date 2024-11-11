//
//  HomeView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//


import SwiftUI
import SwiftData

struct HomeView: View {
    
    @ObservedObject var gameState: GameState
    @Environment(\.modelContext) private var modelContext
    @Query private var savedGameStates: [GameState]
    @Binding var newWord: String
    
    var body: some View {
        NavigationView {
            ScrabbleView(gameState: gameState, newWord: $newWord)
                .navigationTitle("Word Scrabble")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Game") {
                            gameState.startGame()
                            newWord = ""
                        }
                    }
                }
                .onAppear {
                    if !gameState.hasGameStarted {
                        gameState.startGame()
                        gameState.hasGameStarted = true
                    }
                }
                .onChange(of: gameState.completedWords) { _,_ in
                    saveOrUpdateGameState()
                }
        }
    }
    
    private func saveOrUpdateGameState() {
        // Only save if the score is greater than zero
        guard gameState.score > 0 else { return }
        
        // Check if this game state already exists based on unique criteria (e.g., `word`)
        if let existingState = savedGameStates.first(where: { $0.word == gameState.word }) {
            // Update existing state
            existingState.score = gameState.score
            existingState.wordList = gameState.wordList
            existingState.completedWords = gameState.completedWords
            existingState.date = Date()
        } else {
            // Insert a new state
            let newGameState = GameState(
                word: gameState.word,
                score: gameState.score,
                wordList: gameState.wordList,
                completedWords: gameState.completedWords,
                date: Date()
            )
            modelContext.insert(newGameState)
        }
        
        // Save the context to persist changes
        try? modelContext.save()
    }
}

#Preview {
    @Previewable @State var newWord = ""
    let previewGameState = GameState(
        word: "Preview",
        score: 150,
        wordList: ["Swift", "UI", "Framework"],
        completedWords: ["Swift", "UI"],
        date: Date()
    )
    HomeView(gameState: previewGameState, newWord: $newWord)
}
