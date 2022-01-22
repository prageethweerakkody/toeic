
import UIKit

class TodayOverviewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var aQuestionsListSize = 0
    private var aQuestionList = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutOptions()
        aQuestionsListSize = AppDelegate.QUESTION_MANAGER.getQuestionSize()
        guard aQuestionsListSize > 0 else {
            printMessage(message: "no questions")
            return
        }
        for i in 0...(aQuestionsListSize - 1) {
            aQuestionList.append(AppDelegate.QUESTION_MANAGER.getQuestion(index: i)!)
        }
    }

    @IBAction func openMneu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "スタート画面へ", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "today-to-start", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        }))
        self.present(alert, animated: true, completion: {
            printMessage(message: "completion block")
        })
    }

    private func setLayoutOptions() {
        navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        resultButton.layer.cornerRadius = 4
        nextButton.layer.cornerRadius = 4
    }
}

extension TodayOverviewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        printMessage(message: "questionsListSize\(aQuestionsListSize)")
        return aQuestionsListSize
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let question = aQuestionList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") as! TodayViewCell
        cell.setQuestion(question: question)
        return cell
    }
}

