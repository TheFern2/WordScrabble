import SwiftUI
import SwiftData

@Model
class GameState: ObservableObject {
    var word: String
    var shuffledWord: String // Starts as an empty string or could be initialized with word
    var score: Int
//    var wordList: [Word]
//    var completedWords: [Word]
//    var wordList: Data
//    var completedWords: Data
    private var wordListData: Data // Store encoded array as Data
    private var completedWordsData: Data // Store encoded array as Data
    var date: Date
    var hasGameStarted = false
    
    init(word: String, score: Int, wordList: [String], completedWords: [String], date: Date) {
        self.word = word
        self.shuffledWord = word // Initial copy of word or empty string
        self.score = score
        self.wordListData = (try? JSONEncoder().encode(wordList)) ?? Data()
        self.completedWordsData = (try? JSONEncoder().encode(completedWords)) ?? Data()
        self.date = date
    }
    
//    init(word: String, score: Int, wordList: [String], completedWords: [String], date: Date) {
//            self.word = word
//            self.shuffledWord = String(word) // Initialize shuffledWord from word
//            self.score = score
//            self.wordList = wordList.joined(separator: ",") // Join array into a single string
//            self.completedWords = completedWords.joined(separator: ",") // Join array into a single string
//            self.date = date
//        }
//        
//        var wordListArray: [String] {
//            get { wordList.components(separatedBy: ",") } // Convert back to array
//            set { wordList = newValue.joined(separator: ",") } // Store as a joined string
//        }
//        
//        var completedWordsArray: [String] {
//            get { completedWords.components(separatedBy: ",") }
//            set { completedWords = newValue.joined(separator: ",") }
//        }
    
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
