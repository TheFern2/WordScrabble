//
//  Words.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/7/24.
//

import UIKit

@MainActor
func isValidWord(_ word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledRange.location == NSNotFound
}

func generateWords(from rootWord: String) async -> [String] {
    var validWords = Set<String>()
    
    let letters = Array(rootWord)
    for length in 3...letters.count {
        let combinations = getAllCombinations(letters, length: length)
        
        for combination in combinations {
            let permutations = getAllPermutations(Array(combination))
            
            for permutation in permutations {
                if await isValidWord(permutation) {
                    validWords.insert(permutation)
                }
            }
        }
    }

    return Array(validWords).sorted()
}

// Helper function to get all combinations of a certain length
func getAllCombinations(_ letters: [Character], length: Int) -> [String] {
    if length == 0 { return [""] }
    if letters.isEmpty { return [] }

    var results = [String]()
    for (index, letter) in letters.enumerated() {
        let remaining = Array(letters[(index + 1)...])
        let subCombinations = getAllCombinations(remaining, length: length - 1)
        results += subCombinations.map { String(letter) + $0 }
    }

    return results
}

// Helper function to get all permutations of a given array of characters
func getAllPermutations(_ characters: [Character]) -> [String] {
    if characters.count <= 1 {
        return [String(characters)]
    }
    
    var results = [String]()
    for (index, char) in characters.enumerated() {
        var remainingChars = characters
        remainingChars.remove(at: index)
        let subPermutations = getAllPermutations(remainingChars)
        results += subPermutations.map { String(char) + $0 }
    }
    
    return results
}
