//
//  ScrabbleView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/6/24.
//

import SwiftUI
import SwiftData

/*
 - [ ] Extract error handling to a separate view
 - [ ] Extract progress stuff to a separate view
 - [x] maxScore should show max score from scoreboard scores
 */

struct ScrabbleView: View {
    
    @ObservedObject var gameState: GameState
    @FocusState private var isTextFieldFocused: Bool
    @State private var newWord = ""
    @State private var hasGameStarted = false
    @State private var wordProgress: Double = 0.0 // TODO extract progress stuff to a separate view
    @Query private var scores: [Score] // Fetch all Score instances from ScoreboardView
    @State private var maxScore: Int = 0 // Track the max score for display
    @Environment(\.modelContext) private var modelContext // Access model context
    
    // TODO extract error stuff to a separate view
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var showConfetti = false
//    @State private var hasShownConfetti = false
    
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
                        Text("Max: \(maxScore)")  // Replace with dynamic max score if available
                            .font(.title2)
                            .padding(.top)
                    }
                    .onChange(of: gameState.score) { _, newScore in
                        checkAndUpdateCurrentWordScore(newScore: newScore)
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
            
            // Show confetti when `showConfetti` is true
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            calculateOverallMaxScore() // Calculate max score on view load// Initial calculation when the view appears
            calculateAllWords()
        }
        .onSubmit(addNewWord)
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        
        
    }
    
    private func calculateOverallMaxScore() {
        // Calculate the overall max score from all Score entries
        maxScore = scores.map { $0.score }.max() ?? 0
    }
    
    private func checkAndUpdateCurrentWordScore(newScore: Int) {
        guard newScore > 0 else { return } // Only proceed if the score is larger than 0
        
        // Find the score entry for the current word, if it exists
        if let existingScore = scores.first(where: { $0.word == gameState.word }) {
            // Update the existing score if the new score is higher than the saved score for this word
            if newScore > existingScore.score {
                existingScore.score = newScore
                existingScore.wordCount = gameState.completedWords.count
                existingScore.date = Date()
                
                // Persist the updated score for the current word
                try? modelContext.save()
            }
        } else {
            // Insert a new score entry only if no entry exists and score is larger than 0
            let newScoreEntry = Score(
                word: gameState.word,
                wordCount: gameState.completedWords.count,
                wordListCount: gameState.wordList.count,
                score: newScore,
                date: Date()
            )
            modelContext.insert(newScoreEntry)
            
            // Persist the new score entry
            try? modelContext.save()
        }
        
        // Update overall maxScore in case the new score exceeds it
        if newScore > maxScore {
            maxScore = newScore
            
            // Show confetti if it hasn't been shown yet
            if !gameState.hasShownConfetti {
                triggerConfetti()
                gameState.hasShownConfetti = true
            }
        }
    }
    
    func triggerConfetti() {
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConfetti = false
        }
    }
    
    func calculateAllWords() {
        Task {
            gameState.wordList = await calculateWords(from: gameState.word)
        }
    }
    
    // Calculation function (replacing previous progress-based function)
    func calculateWords(from rootWord: String) async -> [String] {
        let validWords = await generateWords(from: rootWord) // Assumes generateWords is async
        //        print("Valid words: \(validWords)")
        return validWords // Return total valid word count
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
