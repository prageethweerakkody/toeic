
import UIKit

class ExplanationController: UIViewController {
    @IBOutlet weak var mTextQuestion: UITextView!
    @IBOutlet weak var mTextExplanation: UITextView!
    @IBOutlet weak var mTextTranslation: UITextView!
    @IBOutlet weak var mTextWord: UITextView!
    @IBOutlet weak var mTextOverall: UITextView!
    @IBOutlet weak var mToggleBookmark: UIButton!
    @IBOutlet weak var mTextQuestionNum: UILabel!
    @IBOutlet weak var mTextTime: UILabel!
    @IBOutlet weak var mButtonNextOutlet: UIButton!
    @IBOutlet weak var mTextQuestionHeader: UIButton!
    @IBOutlet weak var mTextExplanationHeader: UIButton!
    @IBOutlet weak var mTextTranslationHeader: UIButton!
    @IBOutlet weak var mTextWordHeader: UIButton!
    @IBOutlet weak var mTextOverallHeader: UIButton!

    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        setLayoutOptions()
        setupQuestion()
        setCornerRadius()
    }

    @IBAction func optionMenu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "スタート画面へ", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "explanation-to-start", sender: nil)
            printMessage(message: "User click Edit button")
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        }))
        self.present(alert, animated: true, completion: {
            printMessage(message: "completion block")
        })
    }

    @IBAction func startView(_ sender: Any) {
    }

    private func setupQuestion() {
        let question = AppDelegate.QUESTION_MANAGER.getCurrentQuestion()
        guard question != nil else {
            return
        }
        mTextQuestionNum.text = AppDelegate.QUESTION_MANAGER.getQuestionString()
        mToggleBookmark.setTitle(ViewUtil.getBookmarkString(bookmark: (question?.bookmarkProperty)!), for: .normal)
        mTextQuestion.text = ViewUtil.getQuestionAndAnswerSentence(question: question!)
        mTextExplanation.text = question?.explanationProperty
        mTextTranslation.text = question?.translationProperty
        mTextWord.text = question?.getWordSentence()
        mTextOverall.text = question?.getOverallSentence()
        mTextTime.text = question?.timerProperty
    }

    private func setLayoutOptions() {
        mToggleBookmark.layer.cornerRadius = 4
        mButtonNextOutlet.layer.cornerRadius = 4
        mTextQuestionHeader.layer.cornerRadius = 4
        mTextExplanationHeader.layer.cornerRadius = 4
        mTextTranslationHeader.layer.cornerRadius = 4
        mTextWordHeader.layer.cornerRadius = 4
        mTextOverallHeader.layer.cornerRadius = 4
    }

    @IBAction func mButtonNext(_ sender: Any) {
        let question = AppDelegate.QUESTION_MANAGER.getNextQuestion()
        if (question == nil) { // 全問終了
            self.performSegue(withIdentifier: "today-overview-segue", sender: nil)
        } else { // 次の問題
            self.performSegue(withIdentifier: "back-to-questions-segue", sender: nil)
        }
    }
    
    @IBAction func changeBookmarkStatusButton(_ sender: Any) {
        AppDelegate.QUESTION_MANAGER.setBookmark()
        if AppDelegate.QUESTION_MANAGER.getBookmark() {
            mToggleBookmark.setTitle("★", for: UIControlState.normal)
        } else {
            mToggleBookmark.setTitle("☆", for: UIControlState.normal)
        }
    }
    
    private func setCornerRadius() {
        mTextQuestion.layer.cornerRadius = 4
        mTextExplanation.layer.cornerRadius = 4
        mTextTranslation.layer.cornerRadius = 4
        mTextWord.layer.cornerRadius = 4
        mTextOverall.layer.cornerRadius = 4
    }
}
