//
//  ContentView.swift
//  WordScrabble
//
//  Created by Fernando Balandran on 11/5/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    //@Query private var items: [Item]
    @StateObject var gameState = GameState(
            word: "",
            score: 0,
            wordList: [],
            completedWords: [],
            date: Date()
        )
    
    var body: some View {
        TabView {
            HomeView(gameState: gameState)
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }
            
            ScoreboardView()
                .tabItem {
                    Label("Scoreboard", systemImage: "list.number")
                }
            
            SaveLoadView()
                .tabItem {
                    Label("Save/Load", systemImage: "square.and.arrow.down")
                }
        }
    }
    
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//    
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
