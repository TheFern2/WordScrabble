import SwiftUI
import SwiftData

@Model
class GameState: ObservableObject {
    var word: String
    var shuffledWord: String // Starts as an empty string or could be initialized with word
    var score: Int
    var wordList: [String]
    var completedWords: [String]
    var date: Date
    var hasGameStarted = false
    
    init(word: String, score: Int, wordList: [String], completedWords: [String], date: Date) {
        self.word = word
        self.shuffledWord = word // Initial copy of word or empty string
        self.score = score
        self.wordList = wordList
        self.completedWords = completedWords
        self.date = date
    }
    
    func shuffleWord() {
        shuffledWord = String(word.shuffled())
    }
    
    func resetShuffledWord() {
        shuffledWord = word
    }
    
    func startGame() {
        // Clear previous state
        completedWords.removeAll()
        score = 0
        
        // Load a new word from `start.txt`
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
           let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
            let allWords = startWords.components(separatedBy: "\n")
            word = allWords.randomElement() ?? "silkworm"
        } else {
            fatalError("Could not load start.txt from bundle.")
        }
        resetShuffledWord()
    }
}
