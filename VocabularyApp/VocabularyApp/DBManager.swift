//
//  DatabaseManager.swift
//  VocabularyApp
//
//  Created by Juhyun Yun on 12/21/23.
//

import RealmSwift

final class DBManager {
    
    static let shared = DBManager()
    private let realm = try! Realm()
    
    private init() {
        checkCategoryList()
    }
    
    private func checkCategoryList() {
        let categoryList = realm.object(ofType: CategoryList.self, forPrimaryKey: 0)
        if categoryList == nil {
            try! realm.write {
                let categoryList = CategoryList()
                categoryList.categories.append(Category(name: "All"))
                realm.add(categoryList)
            }
        }
    }
    
    func getLocationOfDefaultRealm() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
    
    func read<T: Object>(_ object: T.Type) -> Results<T> {
        return realm.objects(object)
    }
    
    func update<T: Object>(_ object: T, completion: @escaping ((T) -> ())) {
        do {
            try realm.write {
                completion(object)
            }
        } catch {
            print("Error updating object: \(error)")
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting an object: \(error)")
        }
    }
    
    func deleteCategory(_ category: Category) {
        do {
            try realm.write {
                realm.delete(category.vocabularies)
                realm.delete(category)
            }
        } catch {
            print("Error deleting a category: \(error)")
        }
    }
    
    func fetchCategoryList() -> CategoryList {
        guard let categoryList = realm.object(ofType: CategoryList.self, forPrimaryKey: 0) else { fatalError("Error: no categoryList") }
        return categoryList
    }
    
    func move(_ vocabularies: [Vocabulary], to selectedCategory: Category) {
        for vocabulary in vocabularies {
            let newVocabulary = copyVocabulary(vocabulary)
            DBManager.shared.update(selectedCategory) { selectedCategory in
                selectedCategory.vocabularies.append(newVocabulary)
            }
            delete(vocabulary)
        }
    }
    
    private func copyVocabulary(_ vocabulary: Vocabulary) -> Vocabulary {
        let newVocabulary = Vocabulary(word: vocabulary.word, meaning: vocabulary.meaning, example: vocabulary.example)
        newVocabulary.isChecked = vocabulary.isChecked
        newVocabulary.date = vocabulary.date
        return newVocabulary
    }
}
