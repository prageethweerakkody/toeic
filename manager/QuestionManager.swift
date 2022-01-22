
import Foundation

public class QuestionManager: NSObject {
    public static let SINGLETON = QuestionManager()
    public static let QUESTION_ID_PREF_KEY = "question_id"
    public static let QUESTION_TYPE_PREF_KEY = "question_type"
    public static let QUESTION_1SET_NUM = 5
    public static let
    QUESTION_TYPE_CONTINUE = 1,
        QUESTION_TYPE_BEGINNING = 2,
        QUESTION_TYPE_MISS_LAST_TIME = 3,
        QUESTION_TYPE_MISS_ONCE = 4,
        QUESTION_TYPE_BOOKMARK = 5

    private var aQuestionList = Array<Question>()
    private var aCurrentQuestionIndex: Int?
    private var aBaseIndex: Int?
    private var aDBController: DataBaseController
    private var aPreferences = UserDefaults.standard

    public override init() {
        aDBController = DataBaseController.INSTANCE
        aCurrentQuestionIndex = 0
        aBaseIndex = 0
        super.init()
    }

    public func getBaseIndex() -> Int {
        return aBaseIndex!
    }

    public func setup(DBController: DataBaseController) {
        setDB(DBController: DBController)
    }

    public func setDB(DBController: DataBaseController) {
        aDBController = DBController
    }

    public func initByBeginning() {
        aCurrentQuestionIndex = 0
        updateQuestionNumPreferences(aInit: true)
        aDBController.initMissLastTimeQuestion()
    }

    public func initAll() {
        aCurrentQuestionIndex = 0
        updateQuestionNumPreferences(aInit: true)
        aDBController.initBookmarkQuestion()
        aDBController.initMissLastTimeQuestion()
        aDBController.initMissOnceQuestion()
    }

    public func setQuestionTypePreferences(type: Int) {
        aPreferences.set(type, forKey: QuestionManager.QUESTION_TYPE_PREF_KEY)
    }

    public func doesQuestionPrefUse() -> Bool {
        let type = getQuestionTypePreferences()
        if (type == QuestionManager.QUESTION_TYPE_CONTINUE ||
                type == QuestionManager.QUESTION_TYPE_BEGINNING) {
            return true
        } else {
            return false
        }
    }

    public func getQuestionTypePreferences() -> Int {
        return aPreferences.integer(forKey: QuestionManager.QUESTION_TYPE_PREF_KEY)
    }

    public func updateQuestionNumPreferences(aInit: Bool) {
        if (aInit) {
            aPreferences.set(1, forKey: QuestionManager.QUESTION_ID_PREF_KEY)
        } else {
            aPreferences.set(aBaseIndex! + aCurrentQuestionIndex! + 2, forKey: QuestionManager.QUESTION_ID_PREF_KEY)
        }
    }

    public func getQuestionNumPreferences() -> Int {
        return aPreferences.integer(forKey: QuestionManager.QUESTION_ID_PREF_KEY)
    }

    public func setupQuestionList(questionType: Int, DBController: DataBaseController) -> Int {
        var ret = 0
        aQuestionList.removeAll()
        aCurrentQuestionIndex = 0
        aBaseIndex = 0

        switch questionType {
        case QuestionManager.QUESTION_TYPE_CONTINUE:
            var id = aPreferences.integer(forKey: QuestionManager.QUESTION_ID_PREF_KEY)
            if (id == 0){
                id = 1
            }
            aBaseIndex = id - 1
            aQuestionList = DBController.queryQuestionById(id: id, num: QuestionManager.QUESTION_1SET_NUM)
            if (aQuestionList.count == 0) {
                printMessage(message: "no question any more.")
                ret = -1
            }
        case QuestionManager.QUESTION_TYPE_BEGINNING:
            aQuestionList = DBController.queryQuestionById(id: 1, num: QuestionManager.QUESTION_1SET_NUM)
            if (aQuestionList.count == 0) {
                ret = -1
                aBaseIndex = 0
            }
        case QuestionManager.QUESTION_TYPE_MISS_LAST_TIME:
            aQuestionList = DBController.queryMissLastTimeQuestion()
            if (aQuestionList.count == 0) {
                ret = -1
            }
        case QuestionManager.QUESTION_TYPE_MISS_ONCE:
            aQuestionList = DBController.queryMissOnceQuestion()
            if (aQuestionList.count == 0) {
                ret = -1
            }
        case QuestionManager.QUESTION_TYPE_BOOKMARK:
            aQuestionList = DBController.queryBookMarkQuestion()
            if (aQuestionList.count == 0) {
                ret = -1
            }
        default:
            break
        }
        return ret
    }

    public func getQuestionSize() -> Int {
        return aQuestionList.count
    }

    public func getQuestionString() -> String {
        return "第\(aCurrentQuestionIndex! + 1) 問/全 \(aQuestionList.count) 中"
    }

    public func correctAnswer(userAnswer: String) -> Bool {
        let currentQuestion = aQuestionList[aCurrentQuestionIndex!]
        return userAnswer == currentQuestion.answerProperty
    }

    public func updateQuestion(answerCorrect: Bool) {
        let question = aQuestionList[aCurrentQuestionIndex!]
        if (answerCorrect) {
            question.missLastTimeProperty = false
            aDBController.updateMissLastTimeById(id: question.idProperty, miss: false)
        } else {
            question.missLastTimeProperty = true
            question.missOnceProperty = true
            aDBController.updateMissLastTimeById(id: question.idProperty, miss: true)
            aDBController.updateMissOnceById(id: question.idProperty)
        }
    }

    public func isCurrentBookmark() -> Bool {
        let question = aQuestionList[aCurrentQuestionIndex!]
        return question.bookmarkProperty
    }

    public func setBookmark() {
        let question = aQuestionList[aCurrentQuestionIndex!]
        var questionList = Array<Question>()
        questionList = aDBController.queryQuestionById(id: question.idProperty)
        if questionList[0].bookmarkProperty {
            aDBController.updateBookmarkById(id: question.idProperty, bookmark: false)
        } else {
            aDBController.updateBookmarkById(id: question.idProperty, bookmark: true)
        }
    }

    public func getBookmark() -> Bool {
        var questionList = Array<Question>()
        let question = aQuestionList[aCurrentQuestionIndex!]
        questionList = aDBController.queryQuestionById(id: question.idProperty)
        return questionList[0].bookmarkProperty
    }

    public func getQuestion(index: Int) -> Question? {
        if (index >= 0 && aQuestionList.count > index) {
            return aQuestionList[index]
        } else {
            return nil
        }
    }

    public func getCurrentAnswer() -> String? {
        let question = aQuestionList[aCurrentQuestionIndex!]
        return question.answerProperty
    }

    public func getCurrentQuestion() -> Question? {
        if (aQuestionList.count <= 0 || aCurrentQuestionIndex! >= aQuestionList.count) {
            return nil
        } else {
            var questionList = Array<Question>()
            let question = aQuestionList[aCurrentQuestionIndex!]
            questionList = aDBController.queryQuestionById(id: question.idProperty)
            questionList[0].timerProperty = aQuestionList[aCurrentQuestionIndex!].timerProperty
            return questionList[0]
        }
    }

    public func getNextQuestion() -> Question? {
        aCurrentQuestionIndex! += 1
        if (aCurrentQuestionIndex! < aQuestionList.count) {
            return aQuestionList[aCurrentQuestionIndex!]
        }
            else {
                return nil
        }
    }
    
    public func setTimer(time: String){
        let question = aQuestionList[aCurrentQuestionIndex!]
        question.timerProperty = time
    }
}
