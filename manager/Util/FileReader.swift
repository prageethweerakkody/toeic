
import Foundation

public class FileReader {
    public func setupQuestion(DBController: DataBaseController) {
        var aNewWordList = Array<NewWord>()
        if let path = Bundle.main.path(forResource: "toeic_questions", ofType: "tsv") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let line = data.components(separatedBy: .newlines)
                for (_, value) in line.enumerated() {
                    let lineStr = value.split(separator: "\t")
                    if lineStr.isEmpty {
                        continue
                    }
                    let page = lineStr[0]
                    let question = lineStr[1]
                    let answerA = lineStr[2]
                    let answerB = lineStr[3]
                    let answerC = lineStr[4]
                    let answerD = lineStr[5]
                    let answer = lineStr[6]
                    let explanation = lineStr[7]
                    let translation = lineStr[8]
                    let category = lineStr[9]
                    let toeicScore = lineStr[10]
                    aNewWordList.removeAll()

                    if lineStr.count >= 13 {
                        let word = lineStr[11]
                        let meaning = lineStr[12]
                        aNewWordList.append(NewWord(word: String(word), meaning: String(meaning)))
                    } else {
                        aNewWordList.append(NewWord(word: "", meaning: ""))
                    }

                    if lineStr.count >= 15 {
                        let word = lineStr[13]
                        let meaning = lineStr[14]
                        aNewWordList.append(NewWord(word: String(word), meaning: String(meaning)))
                    } else {
                        aNewWordList.append(NewWord(word: "", meaning: ""))
                    }

                    if lineStr.count >= 17 {
                        let word = lineStr[15]
                        let meaning = lineStr[16]
                        aNewWordList.append(NewWord(word: String(word), meaning: String(meaning)))
                    } else {
                        aNewWordList.append(NewWord(word: "", meaning: ""))
                    }

                    if lineStr.count >= 19 {
                        let word = lineStr[17]
                        let meaning = lineStr[18]
                        aNewWordList.append(NewWord(word: String(word), meaning: String(meaning)))
                    } else {
                        aNewWordList.append(NewWord(word: "", meaning: ""))
                    }

                    if lineStr.count >= 21 {
                        let word = lineStr[19]
                        let meaning = lineStr[20]
                        aNewWordList.append(NewWord(word: String(word), meaning: String(meaning)))
                    } else {
                        aNewWordList.append(NewWord(word: "", meaning: ""))
                    }

                    DBController.insertRecord(question: String(question),
                                              answerA: String(answerA),
                                              answerB: String(answerB),
                                              answerC: String(answerC),
                                              answerD: String(answerD),
                                              answer: String(answer),
                                              explanation: String(explanation),
                                              translation: String(translation),
                                              category: String(category),
                                              toeicScore: Int(toeicScore)!,
                                              newWrordList: aNewWordList)
                }
            } catch {
                print(error)
            }
        }
    }
}
