
import Foundation
public class ViewUtil {

    public static func getQuestionAndAnswerSentence(question: Question) -> String {
        let sentence = "\(question.questionProperty)\n\n"
            + "(A) \(question.answerAProperty)\n"
            + "(B) \(question.answerBProperty)\n"
            + "(C) \(question.answerCProperty)\n"
            + "(D) \(question.answerDProperty)\n"
            + "解答 : \(question.answerProperty)"
        return sentence
    }

    public static func getAnswerString(answerCorrect: Bool) -> String {
        if !answerCorrect {
            return "◯"
        }
            else {
                return "×"
        }
    }

    public static func getBookmarkString(bookmark: Bool) -> String {
        if (bookmark) {
            return "★"
        }
            else {
                return "☆"
        }
    }

}
