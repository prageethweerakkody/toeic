
import Foundation

public class Question {
    public static let
    ANSWER_A = 0,
        ANSWER_B = 1,
        ANSWER_C = 2,
        ANSWER_D = 3
    public static let WORD_MAX_NUM = 5
    private static let staticId = 1

    private var id: Int
    private var question: String
    private var answerA: String
    private var answerB: String
    private var answerC: String
    private var answerD: String
    private var answer: String
    private var explanation: String
    private var translation: String
    private var category: String
    private var toeicScore: Int // TOEICの点数（問題のレベル）
    private var newWordList: [NewWord]// 語彙
    private var missLastTime: Bool // 前回間違えた: true, 正解した: false（正解したら0に変更）
    private var missOnce: Bool // 過去に一度でも間違えたらtrue
    private var bookmark: Bool // ユーザーがブックマークしたい問題
    private var timer: String

    public init (
        id: Int,
        question: String,
        answerA: String,
        answerB: String,
        answerC: String,
        answerD: String,
        answer: String,
        explanation: String,
        translation: String,
        category: String,
        missLastTime: Bool,
        missOnce: Bool,
        bookmark: Bool,
        toeicScore: Int,
        word1: String?, meaning1: String?,
        word2: String?, meaning2: String?,
        word3: String?, meaning3: String?,
        word4: String?, meaning4: String?,
        word5: String?, meaning5: String?) {

        self.id = id
        self.question = question
        self.answerA = answerA
        self.answerB = answerB
        self.answerC = answerC
        self.answerD = answerD
        self.answer = answer
        self.explanation = explanation
        self.translation = translation
        self.category = category
        self.missLastTime = missLastTime
        self.missOnce = missOnce
        self.bookmark = bookmark
        self.timer = ""
        self.toeicScore = toeicScore
        self.newWordList = [NewWord]()

        printMessage(message: "id\(id)")
        printMessage(message: "category\(category)")
        printMessage(message: "toeicScore\(toeicScore)")

        guard word1 != nil || meaning1 != nil else {
            print("inside guard")
            return
        }


    }

    public var idProperty: Int {
        get {
            return self.id
        }
        set(id) {
            self.id = id
        }
    }

    public var questionProperty: String {
        get {
            return self.question
        }
        set(question) {
            self.question = question
        }
    }

    public var answerAProperty: String {
        get {
            return self.answerA
        }
        set(answerA) {
            self.answerA = answerA
        }
    }

    public var answerBProperty: String {
        get {
            return self.answerB
        }
        set(answerB) {
            self.answerB = answerB
        }
    }

    public var answerCProperty: String {
        get {
            return self.answerC
        }
        set(answerC) {
            self.answerC = answerC
        }
    }

    public var answerDProperty: String {
        get {
            return self.answerD
        }
        set(answerD) {
            self.answerD = answerD
        }
    }

    public var answerProperty: String {
        get {
            return self.answer
        }
        set(answer) {
            self.answer = answer
        }
    }

    public var explanationProperty: String {
        get {
            return self.explanation
        }
        set(explanation) {
            self.explanation = explanation
        }
    }

    public var translationProperty: String {
        get {
            return self.translation
        }
        set(translation) {
            self.translation = translation
        }
    }

    public var categoryProperty: String {
        get {
            return self.category
        }
        set(category) {
            self.category = category
        }
    }


    public var toeicScoreProperty: Int {
        get {
            return self.toeicScore
        }
        set(toeicScore) {
            self.toeicScore = toeicScore
        }
    }

    public var missLastTimeProperty: Bool {
        get {
            return self.missLastTime
        }
        set(missLastTime) {
            self.missLastTime = missLastTime
        }
    }

    public var missOnceProperty: Bool {
        get {
            return self.missOnce
        }
        set(missOnce) {
            self.missOnce = missOnce
        }
    }

    public var bookmarkProperty: Bool {
        get {
            return self.bookmark
        }
        set(bookmark) {
            self.bookmark = bookmark
        }
    }

    public var newWordListProperty: [NewWord] {
        get {
            return self.newWordList
        }
        set(newWordList) {
            self.newWordList = newWordList
        }
    }

    public var timerProperty: String {
        get {
            return self.timer
        }
        set(timer) {
            self.timer = timer
        }
    }

    public func addNewWord(newWord: NewWord) {
        self.newWordList.append(newWord)
    }

    public func getWordNum() -> Int {
        return newWordList.count
    }

    public func getWordSentence() -> String {
        var sentence = ""
        for (_, element) in newWordList.enumerated() {
            if element.wordProperty == "" {
                continue
            }
            sentence += element.wordProperty + " : " + element.meaningProperty
            sentence += "\n"
        }
        return sentence
    }

    public func getOverallSentence() -> String {
        var overallSentence = "問題カテゴリー：  \(category) "
        overallSentence += "\n"
        overallSentence += "TOEICのターゲットスコア：  \(toeicScore)"
        return overallSentence
    }

    public func toString() -> String {
        return "timer= \(timer) , bookmark=  \(bookmark)"
    }

}
