
import UIKit

class TotalViewCell: UITableViewCell {
    @IBOutlet weak var textCategory: UILabel!
    @IBOutlet weak var UIProgressView: UIProgressView!
    @IBOutlet weak var textCorrectRate: UILabel!
    
    func setTotalOverview (result: CategoryResult){
        textCorrectRate.numberOfLines = 0
        textCategory.text = result.getCategory()
        UIProgressView.progress = Float((Float(result.correctRate()) / Float(100)))
        textCorrectRate.text = result.toStringCorrectRate()
    }
}

