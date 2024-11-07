//
//  HomeView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//


import SwiftUI

struct HomeView: View {
    
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationView {
            ScrabbleView(gameState: gameState)
                .navigationTitle("Word Scrabble")
//                .onSubmit(addNewWord)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Game") {
                            gameState.startGame()
                        }
                    }
                }
                .onAppear {
                    if !gameState.hasGameStarted {
                        gameState.startGame()
                        gameState.hasGameStarted = true // Set to true so `startGame` isn’t called again
//                        isTextFieldFocused = true
                    }
                    //                    startGame()
                    //                    isTextFieldFocused = true
                }
        }
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
