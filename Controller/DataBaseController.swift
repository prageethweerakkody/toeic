
import Foundation
import SQLite

public class DataBaseController: NSObject {
    public static let INSTANCE = DataBaseController()

    public final let QUERY_QUESTION_BY_ID = "queryQuestionById"
    public final let QUERY_BOOKMARK = "queryBookmark"
    public final let QUERY_MISS_LAST_TIME = "queryMissLastTime"
    public final let QUERY_MISS_ONCE = "queryMissOnce"

    private let questionTable = Table("question")
    private let columnId = Expression<Int>("id")
    private let columnQuestion = Expression<String>("question")
    private let columnA = Expression<String>("a")
    private let columnB = Expression<String>("b")
    private let columnC = Expression<String>("c")
    private let columnD = Expression<String>("d")
    private let columnAnswer = Expression<String>("answer")
    private let columnExplanation = Expression<String>("explanation")
    private let columnTranslation = Expression<String>("translation")
    private let columnCategory = Expression<String>("category")
    private let columnToeicScore = Expression<Int>("toeic_score")
    private let columnWord1 = Expression<String?>("word1")
    private let columnMeaning1 = Expression<String?>("meaning1")
    private let columnWord2 = Expression<String?>("word2")
    private let columnMeaning2 = Expression<String?>("meaning2")
    private let columnWord3 = Expression<String?>("word3")
    private let columnMeaning3 = Expression<String?>("meaning3")
    private let columnWord4 = Expression<String?>("word4")
    private let columnMeaning4 = Expression<String?>("meaning4")
    private let columnWord5 = Expression<String?>("word5")
    private let columnMeaning5 = Expression<String?>("meaning5")
    private let columnMissLastTime = Expression<Bool>("miss_last_time")
    private let columnMissOnce = Expression<Bool>("miss_once")
    private let columnBookmark = Expression<Bool>("bookmark")

    private var databaseConnection: Connection!
    private var filterCondition = ""

    public override init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("question").appendingPathExtension("sqlite3")
            databaseConnection = try Connection(fileUrl.path)
        } catch {
            print(error)
        }
    }

    public func createQuestionTable() {
        do {
            try self.databaseConnection.run(questionTable.create(ifNotExists: true) { table in
                table.column(columnId, primaryKey: true)
                table.column(columnQuestion)
                table.column(columnA)
                table.column(columnB)
                table.column(columnC)
                table.column(columnD)
                table.column(columnAnswer)
                table.column(columnExplanation)
                table.column(columnTranslation)
                table.column(columnCategory)
                table.column(columnToeicScore)
                table.column(columnWord1)
                table.column(columnMeaning1)
                table.column(columnWord2)
                table.column(columnMeaning2)
                table.column(columnWord3)
                table.column(columnMeaning3)
                table.column(columnWord4)
                table.column(columnMeaning4)
                table.column(columnWord5)
                table.column(columnMeaning5)
                table.column(columnMissLastTime)
                table.column(columnMissOnce)
                table.column(columnBookmark)
            })
        } catch {
            print(error)
        }
    }

    public func insertRecord(question: String,
                             answerA: String,
                             answerB: String,
                             answerC: String,
                             answerD: String,
                             answer: String,
                             explanation: String,
                             translation: String,
                             category: String,
                             toeicScore: Int,
                             newWrordList: Array<NewWord>) {
        guard newWrordList.count == 5 else {
            return
        }
        var newWord1: NewWord!
        var newWord2: NewWord!
        var newWord3: NewWord!
        var newWord4: NewWord!
        var newWord5: NewWord!
        for (index, newWord) in newWrordList.enumerated() {
            if index == 0 {
                newWord1 = newWord
            }
            if index == 1 {
                newWord2 = newWord
            }
            if index == 2 {
                newWord3 = newWord
            }
            if index == 3 {
                newWord4 = newWord
            }
            if index == 4 {
                newWord5 = newWord
            }
        }
        do {
            try self.databaseConnection.run(questionTable.insert(self.columnQuestion <- question,
                                                                 self.columnA <- answerA,
                                                                 self.columnB <- answerB,
                                                                 self.columnC <- answerC,
                                                                 self.columnD <- answerD,
                                                                 self.columnAnswer <- answer,
                                                                 self.columnExplanation <- explanation,
                                                                 self.columnTranslation <- translation,
                                                                 self.columnCategory <- category,
                                                                 self.columnToeicScore <- toeicScore,
                                                                 self.columnWord1 <- newWord1!.wordProperty,
                                                                 self.columnMeaning1 <- newWord1!.meaningProperty,
                                                                 self.columnWord2 <- newWord2!.wordProperty,
                                                                 self.columnMeaning2 <- newWord2!.meaningProperty,
                                                                 self.columnWord3 <- newWord3!.wordProperty,
                                                                 self.columnMeaning3 <- newWord3!.meaningProperty,
                                                                 self.columnWord4 <- newWord4!.wordProperty,
                                                                 self.columnMeaning4 <- newWord4!.meaningProperty,
                                                                 self.columnWord5 <- newWord5!.wordProperty,
                                                                 self.columnMeaning5 <- newWord5!.meaningProperty,
                                                                 self.columnMissLastTime <- false,
                                                                 self.columnMissOnce <- false,
                                                                 self.columnBookmark <- false
            ))

        } catch {
            print(error)
        }
    }

    public func dropQuestionTable() {
        do {
            try self.databaseConnection.run(questionTable.drop(ifExists: true))
        } catch {
            print(error)
        }
    }

    public func queryCategoryQuestionNum(category: String, id: Int) -> Int {
        do {
            return try self.databaseConnection.scalar(questionTable.filter(self.columnCategory == category && self.columnId < id).count)
        } catch {
            return 0
        }
    }

    public func queryCategoryCorrectNum(category: String, id: Int) -> Int {
        do {
            return try self.databaseConnection.scalar(questionTable.filter(
                self.columnCategory == category &&
                    self.columnMissLastTime == false &&
                    self.columnId < id).count)
        } catch {
            return 0
        }
    }

    public func queryBookMarkQuestion() -> Array<Question> {
        var questionList = [Question]()
        do {
            questionList = (try getAllInputQuestion(filterCondition: QUERY_BOOKMARK, id: 0, num: 0))!
        } catch {
            print(error)
        }
        return questionList
    }

    public func queryMissLastTimeQuestion() -> Array<Question> {
        var questionList = [Question]()
        do {
            questionList = (try getAllInputQuestion(filterCondition: QUERY_MISS_LAST_TIME, id: 0, num: 0))!
        } catch {
            print(error)
        }
        return questionList
    }

    public func queryMissOnceQuestion() -> Array<Question> {
        var questionList = [Question]()
        do {
            questionList = (try getAllInputQuestion(filterCondition: QUERY_MISS_ONCE, id: 0, num: 0))!
        } catch {
            print(error)
        }
        return questionList
    }

    public func queryQuestionById(id: Int, num: Int) -> [Question] {
        var questionList = [Question]()
        do {
            questionList = (try getAllInputQuestion(filterCondition: QUERY_QUESTION_BY_ID, id: id, num: num))!
        } catch {
            print(error)
        }
        return questionList
    }

    public func queryQuestionById(id: Int) -> [Question] {
        var questionList = [Question]()
        var filter: Table?
        filter = questionTable.filter(self.columnId == id)
        do {
            let questions = try self.databaseConnection.prepare(filter!)
            for row in questions {
                try printMessage(message: "\(row.get(self.columnId))")
                let question = try Question(id: row.get(self.columnId),
                                            question: row.get(self.columnQuestion),
                                            answerA: row.get(self.columnA),
                                            answerB: row.get(self.columnB),
                                            answerC: row.get(self.columnC),
                                            answerD: row.get(self.columnD),
                                            answer: row.get(self.columnAnswer),
                                            explanation: row.get(self.columnExplanation),
                                            translation: row.get(self.columnTranslation),
                                            category: row.get(self.columnCategory),
                                            missLastTime: row.get(self.columnMissLastTime),
                                            missOnce: row.get(self.columnMissOnce),
                                            bookmark: row.get(self.columnBookmark),
                                            toeicScore: row.get(self.columnToeicScore),
                                            word1: row.get(self.columnWord1)!,
                                            meaning1: row.get(self.columnMeaning1)!,
                                            word2: row.get(self.columnWord2)!,
                                            meaning2: row.get(self.columnMeaning2)!,
                                            word3: row.get(self.columnWord3)!,
                                            meaning3: row.get(self.columnMeaning3)!,
                                            word4: row.get(self.columnWord4)!,
                                            meaning4: row.get(self.columnMeaning4)!,
                                            word5: row.get(self.columnWord5)!,
                                            meaning5: row.get(self.columnMeaning5)!)
                questionList.append(question)
            }
        } catch {
            print(error)
        }
        return questionList
    }

    public func updateMissLastTimeById(id: Int, miss: Bool) {
        let question = questionTable.filter(self.columnId == id)
        do {
            if miss {
                try self.databaseConnection.run(question.update(self.columnMissLastTime <- true))
            } else {
                try self.databaseConnection.run(question.update(self.columnMissLastTime <- false))
            }
        } catch {
            print(error)
        }
    }


    public func updateMissOnceById(id: Int) {
        let question = questionTable.filter(self.columnId == id)
        do {
            try self.databaseConnection.run(question.update(self.columnMissOnce <- true))
        } catch {
            print(error)
        }
    }

    public func updateBookmarkById(id: Int, bookmark: Bool) {
        let question = questionTable.filter(self.columnId == id)
        do {
            try self.databaseConnection.run(question.update(self.columnBookmark <- bookmark))
        } catch {
            print(error)
        }
    }
    
    public func updateTimeById(id: Int, bookmark: Bool) {
        let question = questionTable.filter(self.columnId == id)
        do {
            try self.databaseConnection.run(question.update(self.columnBookmark <- bookmark))
        } catch {
            print(error)
        }
    }

    public func initMissLastTimeQuestion() {
        do {
            try self.databaseConnection.run(questionTable.update(self.columnMissLastTime <- false))
        } catch {
            print(error)
        }
    }

    public func initBookmarkQuestion() {
        do {
            try self.databaseConnection.run(questionTable.update(self.columnBookmark <- false))
        } catch {
            print(error)
        }
    }

    public func initMissOnceQuestion() {
        do {
            try self.databaseConnection.run(questionTable.update(self.columnMissOnce <- false))
        } catch {
            print(error)
        }
    }

    public func getAllInputQuestion(filterCondition: String, id: Int, num: Int) throws -> [Question]? {
        var questionList = [Question]()
        var filter: Table?
        switch filterCondition {
        case QUERY_QUESTION_BY_ID:
            filter = questionTable.filter(self.columnId >= id && self.columnId < (id + num))
        case QUERY_BOOKMARK:
            filter = questionTable.filter(self.columnBookmark == true)
        case QUERY_MISS_LAST_TIME:
            filter = questionTable.filter(self.columnMissLastTime == true)
        case QUERY_MISS_ONCE:
            filter = questionTable.filter(self.columnMissOnce == true)
        default:
            filter = questionTable.filter(self.columnId == 1)
        }
        let questions = try self.databaseConnection.prepare(filter!)

        for row in questions {
            try printMessage(message: "\(row.get(self.columnId))")
            let question = try Question(id: row.get(self.columnId),
                                        question: row.get(self.columnQuestion),
                                        answerA: row.get(self.columnA),
                                        answerB: row.get(self.columnB),
                                        answerC: row.get(self.columnC),
                                        answerD: row.get(self.columnD),
                                        answer: row.get(self.columnAnswer),
                                        explanation: row.get(self.columnExplanation),
                                        translation: row.get(self.columnTranslation),
                                        category: row.get(self.columnCategory),
                                        missLastTime: row.get(self.columnMissLastTime),
                                        missOnce: row.get(self.columnMissOnce),
                                        bookmark: row.get(self.columnBookmark),
                                        toeicScore: row.get(self.columnToeicScore),
                                        word1: row.get(self.columnWord1)!,
                                        meaning1: row.get(self.columnMeaning1)!,
                                        word2: row.get(self.columnWord2)!,
                                        meaning2: row.get(self.columnMeaning2)!,
                                        word3: row.get(self.columnWord3)!,
                                        meaning3: row.get(self.columnMeaning3)!,
                                        word4: row.get(self.columnWord4)!,
                                        meaning4: row.get(self.columnMeaning4)!,
                                        word5: row.get(self.columnWord5)!,
                                        meaning5: row.get(self.columnMeaning5)!)

            try question.addNewWord(newWord: NewWord(
                word: row.get(self.columnWord1)!,
                meaning: row.get(self.columnMeaning1)!))

            try question.addNewWord(newWord: NewWord(
                word: row.get(self.columnWord2)!,
                meaning: row.get(self.columnMeaning2)!))

            try question.addNewWord(newWord: NewWord(
                word: row.get(self.columnWord3)!,
                meaning: row.get(self.columnMeaning3)!))

            try question.addNewWord(newWord: NewWord(
                word: row.get(self.columnWord4)!,
                meaning: row.get(self.columnMeaning4)!))

            try question.addNewWord(newWord: NewWord(
                word: row.get(self.columnWord5)!,
                meaning: row.get(self.columnMeaning5)!))

            if try row.get(self.columnMissLastTime) == false {
                question.missLastTimeProperty = false
            } else {
                question.missLastTimeProperty = true
            }

            if try row.get(self.columnMissOnce) == false {
                question.missOnceProperty = false
            } else {
                question.missOnceProperty = true
            }

            if try row.get(self.columnBookmark) == false {
                question.bookmarkProperty = false
            } else {
                question.bookmarkProperty = true
            }
            questionList.append(question)
        }
        return questionList
    }
}
