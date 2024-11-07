//
//  Score.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//


import SwiftUI
import SwiftData

@Model
class Score {
    var word: String
    var wordCount: Int
    var wordListCount: Int
    var score: Int
    var date: Date
    
    init(word: String, wordCount: Int, wordListCount: Int, score: Int, date: Date) {
        self.word = word
        self.wordCount = wordCount
        self.wordListCount = wordListCount
        self.score = score
        self.date = date
    }
}
