//
//  WordList.swift
//  DrawBerry
//
//  Created by Calvin Chen on 18/4/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

struct WordList {
    let words: [TopicWord]
    private var index = 0

    init(words: [TopicWord]) {
        self.words = words
    }

    /// Constructs a `WordList` from database
    init?(databaseDescription: String) {
        let substrings = databaseDescription.split(separator: "/").map { String($0) }
        let words = substrings.map { TopicWord($0) }
        self.init(words: words)
    }

    /// Gets the next word in the list
    /// Wraps around if list ends
    mutating func getNextWord() -> TopicWord {
        let nextWord = words[index]
        index = (index + 1) % words.count

        return nextWord
    }

    func getWord(at index: Int) -> TopicWord? {
        return words[index]
    }

    /// Gets description for storage in database.
    func getDatabaseDescription() -> String {
        var description = ""
        let separator = "/"
        for i in 0..<words.count {
            if i != words.count - 1 {
                description += (words[i].value + separator)
            } else {
                description += words[i].value
            }
        }

        return description
    }

}
