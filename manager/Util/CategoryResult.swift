
import Foundation

public class CategoryResult {
    private var category: String
    private var correctNum: Int
    private var questionNum: Int

    public init (category: String, correctNum: Int, questionNum: Int) {
        self.category = category
        self.correctNum = correctNum
        self.questionNum = questionNum
    }

    public func getCategory() -> String {
        return self.category
    }

    public func getCorrectNum() -> Int {
        return self.correctNum
    }

    public func getQuestionNum() -> Int {
        return self.questionNum
    }

    public func correctRate() -> Int {
        if questionNum > 0 {
            return (100 * correctNum / questionNum)
        }
        return 0
    }

    public func toStringCorrectRate() -> String {
        return "正解率 \(correctRate()) %\n \(getCorrectNum())問/全 \(getQuestionNum())問"
    }

}
