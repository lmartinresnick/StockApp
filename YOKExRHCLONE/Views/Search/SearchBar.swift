//
//  SearchBar.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var onTextChanged: (String) -> Void
//UISearchResultsUpdating
    class Coordinator: NSObject, UISearchBarDelegate {
        var onTextChanged: (String) -> Void
        @Binding var text: String
        

        init(text: Binding<String>, onTextChanged: @escaping (String) -> Void) {
            _text = text
            self.onTextChanged = onTextChanged
        }

        // Show cancel button when the user begins editing the search text
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            onTextChanged(text)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
            // Send back empty string text to search view, trigger self.model.searchResults.removeAll()
            onTextChanged(text)
        }
        
//        func updateSearchResults(for searchController: UISearchController) {
//            guard let inputText = searchController.searchBar.text,
//                  inputText.count > 0 else { return }
//            text = inputText
//
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadSearch), object: nil)
//            perform(#selector(loadSearch), with: nil, afterDelay: 0.5)
//        }
//
//        @objc func loadSearch() {
//            //print("load search with \(text)")
//            let load = StockViewModel()
//            load.fetchStock()
//
//        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, onTextChanged: onTextChanged)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search for a stock"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = false
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

