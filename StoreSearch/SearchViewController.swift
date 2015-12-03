//
//  ViewController.swift
//  StoreSearch
//
//  Created by huxianming on 15/11/29.
//  Copyright © 2015年 chuanyue. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    //将多处使用的字符串定义到结构体内，方便使用
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //程序启动后，立即弹出键盘
        searchBar.becomeFirstResponder()
        
        tableView.rowHeight = 80
        tableView.contentInset = UIEdgeInsets.init(top: 64, left: 0, bottom: 0, right: 0)
        
        //获取设计好的cell并注册到tableView
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        //nothingFoundCell没有其它属性，直接注册nib(.xib)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func urlWithSearchText (searchText:String) -> NSURL{
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@",  escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func performStoreRequestWithURL(url:NSURL) -> String?{
        do{
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        }catch{
            print("Downdoad Error:\(error)")
            return nil
        }
    }

    func parseJSON(jsonString:String)->[String:AnyObject]?{
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            else{return nil}
        do{
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        }catch{
            print("JSON Error:\(error)")
            return nil
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(dictionary:[String:AnyObject]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults = [SearchResult]()
        
        
        for resultDict in array {
            if let resultDict = resultDict as? [String:AnyObject]{
                
                var searchResult: SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String{
                    switch wrapperType {
                    case "track" :
                        searchResult = parseTrack(resultDict)
                    case "audiobook":
                        searchResult = parseAudioBook(resultDict)
                    case "software":
                        searchResult = parseSoftware(resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String
                    where kind == "ebook" {
                        searchResult = parseEBook(resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }

            }
        }
        return searchResults
    }
    
    func parseTrack(dictionary:[String:AnyObject]) -> SearchResult{
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["trackPrice"] as? Double { searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre }
        
        return searchResult
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre }
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        return searchResult
    }
    
    func kindForDisplay(kind: String) -> String { switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
}

extension SearchViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            //让键盘在点击search后消失
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(searchBar.text!)
            
            if let jsonString = performStoreRequestWithURL(url){
                if let dictionary = parseJSON(jsonString){
            
                    searchResults = parseDictionary(dictionary)
                }
                searchResults.sortInPlace(<)
                tableView.reloadData()
                return
            }
        }
        showNetworkError()
    }
    
    //消除搜索栏上面的空白部分
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
        }
    }

extension SearchViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }
        else if searchResults.count == 0{
            return 1
        }
        else{
        return searchResults.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if searchResults.count == 0 {
            
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty { cell.artistNameLabel.text = "Unknown"
            } else {
            cell.artistNameLabel.text = String(format: "%@ (%@)",searchResult.artistName, kindForDisplay(searchResult.kind))
            
            }
            return cell
        }
    }
}

extension SearchViewController:UITableViewDelegate {
    
    //点击row时产生动画效果并消除被选择状态
    func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}