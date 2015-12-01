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

}

extension SearchViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            //让键盘在点击search后消失
            searchBar.resignFirstResponder()
            
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(searchBar.text!)
            print("URL:\(url)")
            
            if let jsonString = performStoreRequestWithURL(url){
                print("Received JSON string:\(jsonString)")
            }
            
            hasSearched = true
            tableView.reloadData()
            }
        
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
            cell.artistNameLabel.text = searchResult.artistName
            
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