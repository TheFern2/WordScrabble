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
    
    var body: some View {
        NavigationView {
            ScrabbleView(gameState: gameState)
                .navigationTitle("Word Scrabble")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Save Game") {
                            saveOrUpdateGameState()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Game") {
                            gameState.startGame()
                        }
                    }
                }
                .onAppear {
                    if !gameState.hasGameStarted {
                        gameState.startGame()
                        gameState.hasGameStarted = true
                    }
                }
        }
    }
    
    private func saveOrUpdateGameState() {
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
    var previewGameState = GameState(
        word: "Preview",
        score: 150,
        wordList: ["Swift", "UI", "Framework"],
        completedWords: ["Swift", "UI"],
        date: Date()
    )
    HomeView(gameState: previewGameState)
}
