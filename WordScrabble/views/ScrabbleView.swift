//
//  ScrabbleView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/6/24.
//

import SwiftUI

/*
  - [ ] Break out things into separate views
 */

struct ScrabbleView: View {
    
    @ObservedObject var gameState: GameState
    @FocusState private var isTextFieldFocused: Bool
    @State private var newWord = ""
    @State private var hasGameStarted = false
    @State private var wordProgress: Double = 0.0 // TODO extract progress stuff to a separate view
    
    // TODO extract error stuff to a separate view
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            List {
                // First Section for Game Info
                Section {
                    HStack {
                        Text("Score: \(gameState.score)")
                            .font(.title2)
                            .padding(.top)
                        Spacer()
                        Text("Max: 99")  // Replace with dynamic max score if available
                            .font(.title2)
                            .padding(.top)
                    }
                    
                    HStack {
                        Text("\(gameState.shuffledWord)")
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        Button(action: {
                            gameState.resetShuffledWord()
                        }) {
                            Image(systemName: "arrow.counterclockwise.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 10)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: {
                            gameState.shuffleWord()
                        }) {
                            Image(systemName: "shuffle.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    HStack {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                        
                        Button(action: {
                            addNewWord()
                            isTextFieldFocused = true
                        }) {
                            Image(systemName: "paperplane.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Second Section for Completed Words
                Section(header: Text("Completed Words")) {
                    ForEach(gameState.completedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
        }
        .onSubmit(addNewWord)
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard answer.lowercased() != gameState.word.lowercased() else {
            wordError(title: "Word is identical to root", message: "You need original words")
            return
        }
        
        guard isLengthValid(word: answer) else {
            wordError(title: "Word is too short", message: "You need words longer than 3 characters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(gameState.word)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
//            usedWords.insert(answer, at: 0)
            gameState.completedWords.insert(answer, at: 0)
        }
        gameState.score += answer.count
//        enteredWordCount += 1
        wordProgress = min(Double(gameState.completedWords.count) / Double(gameState.wordList.count), 1.0)
        newWord = ""
    }

    func isOriginal(word: String) -> Bool {
//        !usedWords.contains(word)
        !gameState.completedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        
        var rootCopy = gameState.word
        
        for letter in word {
            if let index = rootCopy.firstIndex(of: letter) {
                rootCopy.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) // UTF-16 length for compatibility
        
        // Check for misspellings
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        // If `misspelledRange.location` is NSNotFound, the word is correctly spelled
        return misspelledRange.location == NSNotFound
    }

    func isLengthValid(word: String) -> Bool {
        guard word.count >= 3 else {
            return false
        }
        
        return true
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

//#Preview {
//    ScrabbleView()
//}

#Preview {
    var previewGameState = GameState(
        word: "Preview",
        score: 150,
        wordList: ["Swift", "UI", "Framework"],
        completedWords: ["Swift", "UI"],
        date: Date()
    )
    
    ScrabbleView(gameState: previewGameState)
}
