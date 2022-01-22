
import Foundation

public class NewWord {
    private var word: String
    private var meaning: String

    public init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
    }

    public var wordProperty: String {
        get {
            return self.word
        }

        set(word) {
            self.word = word
        }
    }

    public var meaningProperty: String {
        get {
            return self.meaning
        }

        set(meaning) {
            self.meaning = meaning
        }
    }
}
