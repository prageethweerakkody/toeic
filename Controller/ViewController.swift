
import UIKit
import SQLite
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var products = [SKProduct]()
    private let preferences = UserDefaults.standard
    private let BILLING_BASE_INDEX = 20
    private var mIsPremium = false; // 購入済み
    private let productID = "com.dstarsystems.ToeicGrammar"
    private var ret = false
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var addSpace: UIButton!
    @IBOutlet weak var mButtonContinue: UIButton!
    @IBOutlet weak var mButtonBookMark: UIButton!
    @IBOutlet weak var mButtonBeginning: UIButton!
    @IBOutlet weak var mButtonMissLastTime: UIButton!
    @IBOutlet weak var mButtonMissOnce: UIButton!

   
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
         print(response.products)
        let count : Int = response.products.count
        if (count > 0) {
            var validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productID) {
                purchase(product: .consumable)
            }
        }

    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        print("Error Fetching product information");
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState)
            print(transaction.error)
            switch transaction.transactionState {
            case.purchased:
                print("purchased")
                if preferences.bool(forKey: AppDelegate.IS_PREMIUM) {
                } else {
                    self.preferences.set(true, forKey: AppDelegate.IS_PREMIUM)
                    self.performSegue(withIdentifier: "questions-segue", sender: nil)
                    AppDelegate.paymentQueue.finishTransaction(transaction)
                }
            case .purchasing:
                print("purchasing")
            case .failed:
                print("failed")
                AppDelegate.paymentQueue.finishTransaction(transaction)
            case .restored:
                if !preferences.bool(forKey: AppDelegate.RESTORE_BUTTON) {
                } else {
                    self.preferences.set(true, forKey: AppDelegate.IS_PREMIUM)
                    self.performSegue(withIdentifier: "questions-segue", sender: nil)
                    AppDelegate.paymentQueue.finishTransaction(transaction)
                    self.preferences.set(false, forKey: AppDelegate.RESTORE_BUTTON)
                }
                print("Already Purchased");
            case .deferred:
                print("deferred")
            }
        }
    }

    func getProducts() {
        let products: Set = [IAPProduct.consumable.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    }

    func purchase(product: IAPProduct) {
        guard let ProductToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first
            else { return }
        let payment = SKPayment(product: ProductToPurchase)
        AppDelegate.paymentQueue.add(payment as SKPayment)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCornerRadius()
        AppDelegate.QUESTION_MANAGER.setDB(DBController: AppDelegate.DB_CONTROLLER)

        if !preferences.bool(forKey: AppDelegate.FIRST_START) {
            //初めての時の処理
            AppDelegate.DB_CONTROLLER.dropQuestionTable()
            AppDelegate.DB_CONTROLLER.createQuestionTable()
            let fileReader = FileReader()
            fileReader.setupQuestion(DBController: AppDelegate.DB_CONTROLLER)
            preferences.set(true, forKey: AppDelegate.FIRST_START)
        } else {
            printMessage(message: "not first time")
        }
        
        AppDelegate.paymentQueue.add(self)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func openMenu(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "総合結果", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "start-to-totaloverview", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "初期化", style: .default, handler: { (UIAlertAction) in
            self.initialization()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }


    public func startQuestionFromBeginning() {
        AppDelegate.QUESTION_MANAGER.setupQuestionList(questionType: QuestionManager.QUESTION_TYPE_BEGINNING, DBController: AppDelegate.DB_CONTROLLER)
        self.performSegue(withIdentifier: "questions-segue", sender: nil)
    }

    @IBAction func mButtonContinue(_ sender: Any) {
        startContinueTask()
    }

    private func startContinueTask() {
        var ret: Int
        AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_CONTINUE)
        ret = AppDelegate.QUESTION_MANAGER.setupQuestionList(questionType: QuestionManager.QUESTION_TYPE_CONTINUE, DBController: AppDelegate.DB_CONTROLLER)
        if (ret == -1) { // 全問終了していたら
            let alert: UIAlertController = UIAlertController(title: "初期化",
                                                             message: "「全問題が終了しています。はじめから実施しますか？",
                                                             preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                self.startQuestionFromBeginning()
            })

            let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })

            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        } else {
            // billing
            if (AppDelegate.QUESTION_MANAGER.getBaseIndex() >= BILLING_BASE_INDEX) {
                if preferences.bool(forKey: AppDelegate.IS_PREMIUM) {
                    self.performSegue(withIdentifier: "questions-segue", sender: nil)
                } else {
                    // Can make payments
                    if (SKPaymentQueue.canMakePayments()) {
                        buyProduct()
                    } else {
                        let alert: UIAlertController = UIAlertController(title: "アイテムの購入可否",
                                                                         message: "購入処理が無効になっている",
                                                                         preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                            (action: UIAlertAction!) -> Void in
                        })
                        alert.addAction(cancelAction)
                        present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "questions-segue", sender: nil)
            }
        }
    }

    private func buyProduct() {
        let alert: UIAlertController = UIAlertController(title: "購入",
                                                         message: "問題を続行するためにはアプリをご購入いただく必要があります。",
                                                         preferredStyle: UIAlertControllerStyle.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(title: "購入します", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.getProducts()
        })
        
        let restoreAction: UIAlertAction = UIAlertAction(title: "購入情報の復元", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            if (SKPaymentQueue.canMakePayments()) {
                 self.preferences.set(true, forKey: AppDelegate.RESTORE_BUTTON)
                AppDelegate.paymentQueue.restoreCompletedTransactions()
            }
        })

        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        })

        alert.addAction(defaultAction)
        alert.addAction(restoreAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func buttonBeginning(_ sender: Any) {
        startBeginningButton()
    }

    private func startBeginningTask() {
        let questionNum = AppDelegate.QUESTION_MANAGER.getQuestionNumPreferences()
        if questionNum != -1 && questionNum != 1 {
            let alert: UIAlertController = UIAlertController(title: "初期化",
                                                             message: "「ブックマークしている問題」と「一度でも間違えたことのある問題」以外が初期化します。よろしいですか？",
                                                             preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                AppDelegate.QUESTION_MANAGER.initByBeginning()
                AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_BEGINNING)
                self.startQuestionFromBeginning()
            })

            let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
            })

            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_BEGINNING)
            startQuestionFromBeginning()
        }
    }

    private func initialization() {
        let alert: UIAlertController = UIAlertController(title: "初期化",
                                                         message: "初期化します。よろしいですか？",
                                                         preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
            self.preferences.set(false, forKey: AppDelegate.START_FROM_BEGINNING)
            AppDelegate.QUESTION_MANAGER.initAll()
        })

        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
        })

        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    private func startBeginningButton() {
        if preferences.bool(forKey: AppDelegate.START_FROM_BEGINNING) {
            let alert: UIAlertController = UIAlertController(title: "初期化",
                                                             message: "「ブックマークしている問題」と「一度でも間違えたことのある問題」以外が初期化します。よろしいですか？",
                                                             preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                AppDelegate.QUESTION_MANAGER.initByBeginning()
                AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_BEGINNING)
                self.startQuestionFromBeginning()
            })

            let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
            })

            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            preferences.set(true, forKey: AppDelegate.START_FROM_BEGINNING)
            AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_BEGINNING)
            startQuestionFromBeginning()
        }
    }

    @IBAction func mButtonBookmark(_ sender: Any) {
        AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_BOOKMARK)
        let ret = AppDelegate.QUESTION_MANAGER.setupQuestionList(questionType: QuestionManager.QUESTION_TYPE_BOOKMARK, DBController: AppDelegate.DB_CONTROLLER)
        if (ret == -1) {
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: "ブックマークしている問題がありません。",
                                                             preferredStyle: UIAlertControllerStyle.alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "questions-segue", sender: nil)
        }
    }


    @IBAction func mButtonMissLastTime(_ sender: Any) {
        AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_MISS_LAST_TIME)
        let ret = AppDelegate.QUESTION_MANAGER.setupQuestionList(questionType: QuestionManager.QUESTION_TYPE_MISS_LAST_TIME, DBController: AppDelegate.DB_CONTROLLER)
        if (ret == -1) {
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: "問題がありません。",
                                                             preferredStyle: UIAlertControllerStyle.alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "questions-segue", sender: nil)
        }
    }


    @IBAction func mButtonMissOnce(_ sender: Any) {
        AppDelegate.QUESTION_MANAGER.setQuestionTypePreferences(type: QuestionManager.QUESTION_TYPE_MISS_ONCE)
        let ret = AppDelegate.QUESTION_MANAGER.setupQuestionList(questionType: QuestionManager.QUESTION_TYPE_MISS_ONCE, DBController: AppDelegate.DB_CONTROLLER)
        if (ret == -1) {
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: "問題がありません。",
                                                             preferredStyle: UIAlertControllerStyle.alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "questions-segue", sender: nil)
        }
    }

    private func setCornerRadius() {
        mButtonContinue.layer.cornerRadius = 4
        mButtonBookMark.layer.cornerRadius = 4
        mButtonBeginning.layer.cornerRadius = 4
        mButtonMissLastTime.layer.cornerRadius = 4
        mButtonMissOnce.layer.cornerRadius = 4
        navigationItem.hidesBackButton = true
        addSpace.isHidden = true
    }
}



