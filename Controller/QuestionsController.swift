
import UIKit

class QuestionsController: UIViewController {
    @IBOutlet weak var mTextQuestion: UILabel!
    @IBOutlet weak var mButtonA: UIButton!
    @IBOutlet weak var mButtonB: UIButton!
    @IBOutlet weak var mButtonC: UIButton!
    @IBOutlet weak var mButtonD: UIButton!
    @IBOutlet weak var mButtonExplanation: UIButton!
    @IBOutlet weak var mButtonNext: UIButton!
    @IBOutlet weak var mTextId: UILabel!
    @IBOutlet weak var mTextQuestionNum: UILabel!
    @IBOutlet weak var mTextTime: UILabel!
    @IBOutlet weak var mToggle: UIButton!
    @IBOutlet weak var A: UILabel!
    @IBOutlet weak var C: UILabel!
    @IBOutlet weak var B: UILabel!
    @IBOutlet weak var D: UILabel!

    private var labelView: UIView?
    private var questionType: Int?
    private var fixedSelection = false
    private var timer = Timer()
    private var timerIsOn = false
    private var startTime = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        questionType = AppDelegate.QUESTION_MANAGER.getQuestionTypePreferences()
        setCornerRadius()
        fixedSelection = false
        resetAnswer()
        restartTimer()

        let question = AppDelegate.QUESTION_MANAGER.getCurrentQuestion()
        if question == nil {
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: "問題が見つかりません。",
                                                             preferredStyle: UIAlertControllerStyle.alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                printMessage(message: "Cancel")
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            setQuestionParams(question: question!)
            mToggle.setTitle(ViewUtil.getBookmarkString(bookmark: (question?.bookmarkProperty)!), for: .normal)
        }
    }

    @IBAction func optionsMenu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "スタート画面へ", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "questions-to-start", sender: nil)
            printMessage(message: "User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        }))
        self.present(alert, animated: true, completion: {
            printMessage(message: "completion block")
        })
    }

    private func setQuestionParams(question: Question) {
        mTextId.text = "\(question.idProperty)"
        mTextQuestionNum.text = AppDelegate.QUESTION_MANAGER.getQuestionString()
        if question.bookmarkProperty {
            mToggle.setTitle("★", for: UIControlState.normal)
        } else {
            mToggle.setTitle("☆", for: UIControlState.normal)
        }
        mTextQuestion.text = question.questionProperty
        mButtonA.setTitle(question.answerAProperty, for: UIControlState.normal)
        mButtonB.setTitle(question.answerBProperty, for: UIControlState.normal)
        mButtonC.setTitle(question.answerCProperty, for: UIControlState.normal)
        mButtonD.setTitle(question.answerDProperty, for: UIControlState.normal)
    }

    @IBAction func mButtonA(_ sender: Any) {
        answerButtonPressed(answer: "A")
    }

    @IBAction func mButtonB(_ sender: Any) {
        answerButtonPressed(answer: "B")
    }

    @IBAction func mButtonC(_ sender: Any) {
        answerButtonPressed(answer: "C")
    }

    @IBAction func mButtonD(_ sender: Any) {
        answerButtonPressed(answer: "D")
    }

    private func answerButtonPressed(answer: String) {
        if (fixedSelection) {
            return
        }
        fixedSelection = true
        if let timeStr = mTextTime.text {
            if let question = AppDelegate.QUESTION_MANAGER.getCurrentQuestion() {
                question.timerProperty = timeStr
                AppDelegate.QUESTION_MANAGER.setTimer(time: timeStr)
            } else {
                printMessage(message: "question nil")
            }
        }
        if (AppDelegate.QUESTION_MANAGER.doesQuestionPrefUse()) {
            AppDelegate.QUESTION_MANAGER.updateQuestionNumPreferences(aInit: false)
        }
        resetTimer()
        updateAnswer(userAnswer: answer)
    }

    @IBAction func mButtonExplanation(_ sender: Any) {
    }

    @IBAction func mButtonNext(_ sender: Any) {
        let question = AppDelegate.QUESTION_MANAGER.getNextQuestion()
        if (question == nil) { // 全問終了
            self.performSegue(withIdentifier: "question-to-today-segue", sender: nil)
        } else { // 次の問題
            resetAnswer()
            setQuestionParams(question: question!)
            resetTimer()
            restartTimer()
            fixedSelection = false
        }
    }

    private func restartTimer() {
        startTime = Date().timeIntervalSince1970 * 1000
        if !timerIsOn {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.timerRunning)), userInfo: nil, repeats: true)
            timerIsOn = true
        }
    }

    private func resetTimer() {
        timer.invalidate()
        timerIsOn = false
        startTime = 0
    }

    @objc func timerRunning() {
        let endTime = Date().timeIntervalSince1970 * 1000
        let elapsedTime = endTime - startTime
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.S"
        mTextTime.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(elapsedTime / 1000)))
    }

    /// 解答前のUIに戻す
    private func resetAnswer() {
        UIView.animate(withDuration: 0.0, animations: {
            self.mButtonExplanation.backgroundColor = UIColor.clear
        })
        self.mButtonExplanation.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.0, animations: {
            self.mButtonNext.backgroundColor = UIColor.clear
        })
        mButtonNext.isUserInteractionEnabled = false
        mButtonA.backgroundColor = UIColor.init(red: 0.00, green: 0.60, blue: 0.00, alpha: 1.0)
        mButtonB.backgroundColor = UIColor.init(red: 0.00, green: 0.60, blue: 0.00, alpha: 1.0)
        mButtonC.backgroundColor = UIColor.init(red: 0.00, green: 0.60, blue: 0.00, alpha: 1.0)
        mButtonD.backgroundColor = UIColor.init(red: 0.00, green: 0.60, blue: 0.00, alpha: 1.0)
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        } else {
            printMessage(message: "no subview")
        }
    }

    private func setCornerRadius() {
        mButtonA.layer.cornerRadius = 4
        mButtonB.layer.cornerRadius = 4
        mButtonC.layer.cornerRadius = 4
        mButtonD.layer.cornerRadius = 4
        mButtonExplanation.layer.cornerRadius = 4
        mButtonNext.layer.cornerRadius = 4
        mTextId.layer.cornerRadius = 4
        mTextId.layer.masksToBounds = true
        mTextQuestionNum.layer.cornerRadius = 4
        mTextQuestionNum.layer.masksToBounds = true
        mTextTime.layer.cornerRadius = 4
        mTextTime.layer.masksToBounds = true
        mToggle.layer.cornerRadius = 4
        A.layer.masksToBounds = true
        A.layer.cornerRadius = 4
        B.layer.masksToBounds = true
        B.layer.cornerRadius = 4
        C.layer.masksToBounds = true
        C.layer.cornerRadius = 4
        D.layer.masksToBounds = true
        D.layer.cornerRadius = 4
        navigationItem.hidesBackButton = true
        mTextQuestion.numberOfLines = 0
    }

    private func showAnswerSign(answerCorrect: Bool) {
        let screenHeight = UIScreen.main.bounds.height
        let screenwith = UIScreen.main.bounds.width
        labelView = UIView(frame: CGRect(x: (screenwith / 2), y: (screenHeight / 2 - 20), width: 50, height: 50))
        if answerCorrect {
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: CGFloat(20), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.init(red: 0.00, green: 0.58, blue: 1.00, alpha: 1.0).cgColor
            shapeLayer.lineWidth = 7.0

            labelView?.layer.addSublayer(shapeLayer)
        } else {
            let screenHeight = UIScreen.main.bounds.height
            let screenwith = UIScreen.main.bounds.width
            labelView = UIView(frame: CGRect(x: (screenwith / 2 - 20), y: (screenHeight / 2 - 40), width: 50, height: 50))
            let toLeft = UIBezierPath()
            toLeft.move(to: CGPoint(x: 0, y: 0))
            toLeft.addLine(to: CGPoint(x: 40, y: 40))

            let toRight = UIBezierPath()
            toRight.move(to: CGPoint(x: 40, y: 0))
            toRight.addLine(to: CGPoint(x: 0, y: 40))

            let shapeLayerToLeft = CAShapeLayer()
            shapeLayerToLeft.path = toLeft.cgPath
            shapeLayerToLeft.strokeColor = UIColor.init(red: 1.00, green: 0.40, blue: 1.00, alpha: 1.0).cgColor
            shapeLayerToLeft.lineWidth = 7.0

            let shapeLayerToRight = CAShapeLayer()
            shapeLayerToRight.path = toRight.cgPath
            shapeLayerToRight.strokeColor = UIColor.init(red: 1.00, green: 0.40, blue: 1.00, alpha: 1.0).cgColor
            shapeLayerToRight.lineWidth = 7.0

            labelView?.layer.addSublayer(shapeLayerToLeft)
            labelView?.layer.addSublayer(shapeLayerToRight)
        }
        labelView?.tag = 100
        self.view.addSubview(labelView!)
    }

    private func showCorrectAnswerButton(answer: String) {
        switch answer {
        case "A":
            mButtonA.backgroundColor = UIColor.orange
        case "B":
            mButtonB.backgroundColor = UIColor.orange
        case "C":
            mButtonC.backgroundColor = UIColor.orange
        case "D":
            mButtonD.backgroundColor = UIColor.orange
        default:
            printMessage(message: "answer does not match")
        }
    }

    private func showAnswer(userAnswer: String, answer: String) {
        showAnswerSign(answerCorrect: userAnswer == answer)
        showCorrectAnswerButton(answer: answer)
    }

    private func updateAnswer(userAnswer: String) {
        if let answer = AppDelegate.QUESTION_MANAGER.getCurrentAnswer() {
            AppDelegate.QUESTION_MANAGER.updateQuestion(answerCorrect: userAnswer == answer)
            showAnswer(userAnswer: userAnswer, answer: answer)
        } else {
            printMessage(message: "updateAnswer nil")
        }
        UIView.animate(withDuration: 0.0, animations: {
            self.mButtonExplanation.backgroundColor = UIColor.init(red: 1.00, green: 0.40, blue: 1.00, alpha: 1.0)
        })
        self.mButtonExplanation.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.0, animations: {
            self.mButtonNext.backgroundColor = UIColor.init(red: 0.20, green: 0.80, blue: 1.00, alpha: 1.0)
        })
        mButtonNext.isUserInteractionEnabled = true
    }

    @IBAction func changeBookmarkStatusButton(_ sender: Any) {
        AppDelegate.QUESTION_MANAGER.setBookmark()
        if AppDelegate.QUESTION_MANAGER.getBookmark() {
            mToggle.setTitle("★", for: UIControlState.normal)
        } else {
            mToggle.setTitle("☆", for: UIControlState.normal)
        }
    }
}
