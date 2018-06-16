//
//  ListController.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import UIKit
import SwipeCellKit
import ObjectMapper
import Alamofire
import RealmSwift
import Toast_Swift

class ListController: UIViewController {
    let realm = migrateRealm()
    @IBOutlet weak var tableview: UITableView!
    var newsArray : [News] = [News]()
    var deletedNews : [Deleted] = [Deleted]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        self.setupUI()
        self.loadNews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        self.navigationItem.rightBarButtonItem = nil
        let btnInfo = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action:#selector(self.gotoInfo))
        btnInfo.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem  = btnInfo
        tableview.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        self.tableview.addSubview(self.refreshControl)
    }
    
    @objc func gotoInfo() {
        
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "InfoController") as! InfoController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        if (checkConnection()) {
            Alamofire.request(HackerNews.Api.search, method: .get).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json = data as! NSDictionary
                    let data = Mapper<News>().mapArray(JSONObject: json.object(forKey: "hits"))

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    try! self.realm.write {
                        var news = self.realm.objects(News.self)
                        self.realm.delete(news)
                        self.realm.add(data!)
                        news = self.realm.objects(News.self)
                        let deleted = self.realm.objects(Deleted.self)
                        self.newsArray = Array(news)
                        self.deletedNews = Array(deleted)
                        self.checkDeleted()
                        self.newsArray = (self.newsArray.sorted(by: { dateFormatter.date(from:$0.createdAt)!.compare(dateFormatter.date(from:$1.createdAt)!) == .orderedDescending }))
                        self.tableview.reloadData()
                        refreshControl.endRefreshing()
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    self.view.makeToast(error.localizedDescription)
                    refreshControl.endRefreshing()
                }
            }
        } else {
            let news = self.realm.objects(News.self)
            self.newsArray = Array(news)
            self.view.makeToast("No connection available, showing last downloaded posts")
            refreshControl.endRefreshing()
        }
    }
    
    func checkDeleted() {
        for j in 0..<self.deletedNews.count {
            self.newsArray = self.newsArray.filter {$0.storyId != self.deletedNews[j].storyId}
        }
    }
    
    @objc func loadNews() {
        startLoading(view: self.view)
        self.newsArray = [News]()
        if (checkConnection()) {
            Alamofire.request(HackerNews.Api.search, method: .get).responseJSON { response in
                switch response.result {
                case .success(let data):
                    stopLoading(view: self.view)
                    let json = data as! NSDictionary
                    let data = Mapper<News>().mapArray(JSONObject: json.object(forKey: "hits"))
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    try! self.realm.write {
                        var news = self.realm.objects(News.self)
                        self.realm.delete(news)
                        self.realm.add(data!)
                        news = self.realm.objects(News.self)
                        let deleted = self.realm.objects(Deleted.self)
                        self.newsArray = Array(news)
                        self.deletedNews = Array(deleted)
                        self.checkDeleted()
                        self.newsArray = (self.newsArray.sorted(by: { dateFormatter.date(from:$0.createdAt)!.compare(dateFormatter.date(from:$1.createdAt)!) == .orderedDescending }))
                        self.tableview.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                    stopLoading(view: self.view)
                    self.view.makeToast(error.localizedDescription)
                }
            }
        } else {
            stopLoading(view: self.view)
            let news = self.realm.objects(News.self)
            self.newsArray = Array(news)
            self.view.makeToast("No connection available, showing last downloaded posts")
        }
    }
}

extension ListController : UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let new : News = self.newsArray[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
//        cell.lblNameCalendar.text = currentCalendar.name
        cell.lblTitle.text = new.storyTitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let date = dateFormatter.date(from: new.createdAt)
        cell.lblAuthorDate.text = new.author + " - " + (date?.timeAgoDisplay())!
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let index = indexPath.row
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: true)
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

            let deleted : Deleted = Deleted()
            deleted.storyId = self.newsArray[index].storyId
            deleted.author = self.newsArray[index].author

            try! self.realm.write {
                print("DELETED ADDED")
                self.realm.add(deleted)
            }

            self.newsArray.remove(at: index)
            action.fulfill(with: .delete)
        }
        
        
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = UIColor.red
        deleteAction.font = UIFont.systemFont(ofSize: 14.0)
        
        return [deleteAction]
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.5
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let index = indexPath.row
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
        
        if (self.newsArray[index].storyUrl.isEmpty || self.newsArray[index].storyUrl == "") {
            self.view.makeToast("the link for this news is not available")
        } else {
            vc.passedLink = self.newsArray[index].storyUrl
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}

