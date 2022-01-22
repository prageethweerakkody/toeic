
import UIKit

class TodayViewCell: UITableViewCell {
    @IBOutlet weak var textQuestionNum: UILabel!
    @IBOutlet weak var textAnswerSign: UILabel!
    @IBOutlet weak var textTime: UILabel!
    @IBOutlet weak var textQuestion: UITextView!
    
    func setQuestion(question: Question){
        textQuestionNum.text = "\(question.idProperty)"
        let answer = question.missLastTimeProperty
        textAnswerSign.font = textAnswerSign.font.withSize(20)
        if answer {
            textAnswerSign.text = "×"
            textAnswerSign.textColor = UIColor.blue
        } else {
              textAnswerSign.text = "⚪︎"
            textAnswerSign.textColor = UIColor.magenta
        }
        textTime.text = "解答時間 : \(question.timerProperty)"
        textQuestion.text = question.questionProperty
    }
}
