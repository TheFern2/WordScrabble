import SwiftUI
import SwiftData

@Model
class GameState: ObservableObject {
    var word: String
    var shuffledWord: String
    var score: Int
    private var wordListData: Data
    private var completedWordsData: Data
    var date: Date
    var hasGameStarted = false
    var hasShownConfetti = false
    
    init(word: String, score: Int, wordList: [String], completedWords: [String], date: Date) {
        self.word = word
        self.shuffledWord = word
        self.score = score
        self.wordListData = (try? JSONEncoder().encode(wordList)) ?? Data()
        self.completedWordsData = (try? JSONEncoder().encode(completedWords)) ?? Data()
        self.date = date
    }
    
    var wordList: [String] {
            get {
                (try? JSONDecoder().decode([String].self, from: wordListData)) ?? []
            }
            set {
                wordListData = (try? JSONEncoder().encode(newValue)) ?? Data()
            }
        }
        
        var completedWords: [String] {
            get {
                (try? JSONDecoder().decode([String].self, from: completedWordsData)) ?? []
            }
            set {
                completedWordsData = (try? JSONEncoder().encode(newValue)) ?? Data()
            }
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
        hasShownConfetti = false
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
