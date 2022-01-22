
import Foundation

public class CategoryProp {
    var categoryList = [Categories]()

    public init() {
        categoryList.append(Categories(id: 0, category: "文型"))
        categoryList.append(Categories(id: 1, category: "品詞"))
        categoryList.append(Categories(id: 2, category: "動詞の活用"))
        categoryList.append(Categories(id: 3, category: "時制"))
        categoryList.append(Categories(id: 4, category: "完了形"))
        categoryList.append(Categories(id: 5, category: "助動詞"))
        categoryList.append(Categories(id: 6, category: "不定詞"))
        categoryList.append(Categories(id: 7, category: "分詞"))
        categoryList.append(Categories(id: 8, category: "動名詞"))
        categoryList.append(Categories(id: 9, category: "名詞"))
        categoryList.append(Categories(id: 10, category: "比較"))
        categoryList.append(Categories(id: 11, category: "接続詞"))
        categoryList.append(Categories(id: 12, category: "前置詞"))
        categoryList.append(Categories(id: 13, category: "仮定法"))
        categoryList.append(Categories(id: 14, category: "語彙"))
        categoryList.append(Categories(id: 15, category: "熟語"))
        categoryList.append(Categories(id: 16, category: "その他"))
    }

    public func getCategorySize() -> Int {
        return self.categoryList.count
    }

    public func getCategoryList() -> [Categories] {
        return self.categoryList
    }

    public func getId(categoryString: String) -> Int {
        for category in categoryList {
            if category.categoryProperty == categoryString {
                return category.idProperty
            }
        }
        return -1
    }

    public func getCategory(idInt: Int) -> String? {
        for category in categoryList {
            if category.idProperty == idInt {
                return category.categoryProperty
            }
        }
        return nil
    }
}

public class Categories {
    private var id: Int
    private var category: String

    public init(id: Int, category: String) {
        self.id = id
        self.category = category
    }

    public var idProperty: Int {
        get {
            return self.id
        }

        set(id) {
            self.id = id
        }
    }

    public var categoryProperty: String {
        get {
            return self.category
        }

        set(category) {
            self.category = category
        }
    }
}
