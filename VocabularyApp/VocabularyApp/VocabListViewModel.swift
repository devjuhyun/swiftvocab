//
//  VocabListViewModel.swift
//  VocabularyApp
//
//  Created by Juhyun Yun on 1/2/24.
//

import Foundation
import RealmSwift

enum SortOption: String {
    case newestFirst
    case oldestFirst
}

enum DisplayOption: String {
    case all
    case checkedWords
    case uncheckedWords
}

class VocabListViewModel {
    // MARK: - Properties
    var inSearchMode: Bool = false
    private(set) var token: NotificationToken?
    let category: Observable<Category>
    private let allVocabulariesInDB = DBManager.shared.read(Vocabulary.self)
    private(set) var vocabularies: Observable<[Vocabulary]> = Observable([])
    private(set) var filteredVocabularies: Observable<[Vocabulary]> = Observable([])
    private(set) var sortOption: Observable<SortOption>
    private(set) var displayOption: Observable<DisplayOption>
    var shouldDisplayAllVocabulariesInDB: Bool
    private(set) var selectedVocabularies: Observable<[Vocabulary]> = Observable([])
    
    var navTitle: String {
        return "\(selectedVocabularies.value.count)/\(vocabulariesToDisplay.count)"
    }
    
    var vocabulariesToDisplay: [Vocabulary] {
        return inSearchMode ? filteredVocabularies.value : vocabularies.value
    }
    
    // MARK: - Lifecycle
    init(category: Category, sortOption: SortOption, displayOption: DisplayOption, shouldDisplayAllVocabulariesInDB: Bool) {
        self.category = Observable(category)
        self.sortOption = Observable(sortOption)
        self.displayOption = Observable(displayOption)
        self.shouldDisplayAllVocabulariesInDB = shouldDisplayAllVocabulariesInDB
        token = allVocabulariesInDB.observe { [weak self] _ in
            self?.fetchVocabularies()
        }
    }
    
    // MARK: - Work With Vocabulary
    func fetchVocabularies() {
        vocabularies.value = shouldDisplayAllVocabulariesInDB ? Array(allVocabulariesInDB) : Array(category.value.vocabularies)
        sortVocabularies()
        filterVocabularies()
    }
    
    private func sortVocabularies() {
        switch sortOption.value {
        case .newestFirst:
            vocabularies.value.sort { $0.date > $1.date }
        case .oldestFirst:
            vocabularies.value.sort { $0.date < $1.date }
        }
    }
    
    // TODO: - call this only when category is changed
    private func filterVocabularies() {
        switch displayOption.value {
        case .checkedWords:
            vocabularies.value = vocabularies.value.filter { $0.isChecked }
        case .uncheckedWords:
            vocabularies.value = vocabularies.value.filter { !$0.isChecked }
        case .all:
            break
        }
    }
    
    func checkVocabulary(_ vocabulary: Vocabulary) {
        DBManager.shared.update(vocabulary) { vocabulary in
            vocabulary.isChecked.toggle()
        }
    }
    
    func checkSelectedVocabularies(isChecking: Bool) {
        for vocabulary in selectedVocabularies.value {
            DBManager.shared.update(vocabulary) { vocabulary in
                vocabulary.isChecked = isChecking
            }
        }
    }
    
    func updateSelectedVocabularies(indexPaths: [IndexPath]?) {
        if let indexPaths = indexPaths {
            let indices = indexPaths.map{$0.row}
            selectedVocabularies.value = indices.map { vocabulariesToDisplay[$0] }
        } else {
            selectedVocabularies.value = []
        }
    }
    
    func deleteVocabularies() {
        selectedVocabularies.value.forEach { DBManager.shared.delete($0) }
    }
    
    func moveVocabularies(to selectedCategory: Category) {
        DBManager.shared.move(selectedVocabularies.value, to: selectedCategory)
    }
    
    // MARK: - Work With Category
    func passCategory() -> Category? {
        shouldDisplayAllVocabulariesInDB ? nil : category.value
    }
    
    func resetCategory() {
        category.value = DBManager.shared.fetchCategoryList().categories[0]
        shouldDisplayAllVocabulariesInDB = true
    }
    
    // MARK: - Work With UserDefaults
    func updateSortOption(_ sortOption: SortOption) {
        UserDefaults.standard.set(sortOption.rawValue, forKey: "sortOption")
        self.sortOption.value = sortOption
    }
    
    func updateDisplayOption(_ displayOption: DisplayOption) {
        UserDefaults.standard.set(displayOption.rawValue, forKey: "displayOption")
        self.displayOption.value = displayOption
    }
    
    func getSubtitleAndActionIndexOfSortMenu() -> (String, Int) {
        switch sortOption.value {
        case .newestFirst:
            return ("Newest First".localized(), 0)
        case .oldestFirst:
            return ("Oldest First".localized(), 1)
        }
    }
    
    func getSubtitleAndActionIndexOfDisplayMenu() -> (String, Int) {
        switch displayOption.value {
        case .all:
            return ("All".localized(), 0)
        case .checkedWords:
            return ("Checked Words".localized(), 1)
        case .uncheckedWords:
            return ("Unchecked Words".localized(), 2)
        }
    }
    
    // MARK: - Search Functions
    public func setInSearchMode(isSearching: Bool, searchText: String) {
        inSearchMode = isSearching && !searchText.isEmpty
    }
    
    public func updateSearchController(searchBarText: String?) {
        if let searchText = searchBarText?.lowercased() {
            filteredVocabularies.value = vocabularies.value.filter { $0.word.lowercased().contains(searchText) || $0.meaning.contains(searchText) }
        }
    }
}
