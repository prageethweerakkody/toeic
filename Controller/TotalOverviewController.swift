
import UIKit

class TotalOverviewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var resultList = [CategoryResult]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutOptions()
        let prop = CategoryProp()
        for i in 0...(prop.getCategorySize() - 1) {
            let category = prop.getCategory(idInt: i)
            printMessage(message: "category\(String(describing: category))")
            let id = AppDelegate.QUESTION_MANAGER.getQuestionNumPreferences()
            printMessage(message: "id\(id)")
            let questionNum = AppDelegate.DB_CONTROLLER.queryCategoryQuestionNum(category: category!, id: id)
            printMessage(message: "questionNum\(questionNum)")
            let correctNum = AppDelegate.DB_CONTROLLER.queryCategoryCorrectNum(category: category!, id: id)
            printMessage(message: "correctNum\(correctNum)")
            resultList.append(CategoryResult(category: category!, correctNum: correctNum, questionNum: questionNum))
        }
        printMessage(message: "mResultListsize\(resultList.count)")
    }

    @IBAction func openMenu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "スタート画面へ", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "total-to-start", sender: nil)
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
        headerButton.layer.cornerRadius = 4
        nextButton.layer.cornerRadius = 4
    }
}

extension TotalOverviewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = resultList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "totalViewCell") as! TotalViewCell
        cell.setTotalOverview(result: result)
        return cell
    }
}

