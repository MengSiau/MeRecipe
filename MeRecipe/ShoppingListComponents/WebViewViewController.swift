//
//  WebViewViewController.swift
//  MeRecipe
//
//  Created by Meng Siau on 30/5/2024.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UISearchBarDelegate {
    
    let webview = WKWebView()
    let searchBar = UISearchBar()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let searchBarHeight: CGFloat = 50
        searchBar.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: searchBarHeight)
        webview.frame = CGRect(x: 0, y: view.safeAreaInsets.top + searchBarHeight, width: view.frame.width, height: view.frame.height - searchBarHeight - view.safeAreaInsets.top)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search bar //
        searchBar.delegate = self
        searchBar.placeholder = "Enter website URL"
        view.addSubview(searchBar)
        
        // Set up the webview //
        webview.navigationDelegate = self
        webview.uiDelegate = self
        view.addSubview(webview)
        
        guard let url = URL(string: "https://woolworths.com.au") else {
            return
        }
        webview.load(URLRequest(url: url))
    }
    
    // Delegate methods for the UISearchBar //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let urlString = searchBar.text, isValidUrl(urlString: urlString) ,let url = URL(string: urlString) {
            webview.load(URLRequest(url: url))
        } else {
            displayMessage(title: "Error", message: "Please ensure that input is in URL format")
        }
    }
    
    // WKNavigationDelegate methods //
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        displayMessage(title: "Error", message: "Unable to find your requested URL. Please try again")
    }

    // Helper func -> Ensures that user input is actually a URL. //
    func isValidUrl(urlString: String) -> Bool {
        let pattern = "^(http|https)://" // accept http also.
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex?.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) != nil // ensures the https:// is at the start
    }

}
