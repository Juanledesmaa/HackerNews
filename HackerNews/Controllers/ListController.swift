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
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(self.loadNews(_:)), for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.cyan
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadNews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableview.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        self.tableview.addSubview(self.refreshControl)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        if (checkConnection()) {
            Alamofire.request(HackerNews.Api.search, method: .get).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json = data as! NSDictionary
                    let data = Mapper<News>().mapArray(JSONObject: json.object(forKey: "hits"))
                    self.newsArray = data!
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    self.newsArray = (data?.sorted(by: { dateFormatter.date(from:$0.createdAt)!.compare(dateFormatter.date(from:$1.createdAt)!) == .orderedDescending }))!
                    self.tableview.reloadData()
                    refreshControl.endRefreshing()
                case .failure(let error):
                    print(error)
                    self.view.makeToast(error.localizedDescription)
                    refreshControl.endRefreshing()
                }
            }
        } else {

            self.view.makeToast("No connection available, showing last downloaded posts")
            refreshControl.endRefreshing()
        }

    
    
    
    
    
    }
    
    @objc func loadNews() {
        startLoading(view: self.view)
        
        if (checkConnection()) {
            Alamofire.request(HackerNews.Api.search, method: .get).responseJSON { response in
                switch response.result {
                case .success(let data):
                    stopLoading(view: self.view)
                    let json = data as! NSDictionary
                    let data = Mapper<News>().mapArray(JSONObject: json.object(forKey: "hits"))
                    
                    self.newsArray = data!
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    self.newsArray = (data?.sorted(by: { dateFormatter.date(from:$0.createdAt)!.compare(dateFormatter.date(from:$1.createdAt)!) == .orderedDescending }))!
                    self.tableview.reloadData()
                case .failure(let error):
                    print(error)
                    stopLoading(view: self.view)
                    self.view.makeToast(error.localizedDescription)
                }
            }
        } else {
            
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
        
        let section = indexPath.section
        let index = indexPath.row
//        let calendars : [CalendarModel] = self.dictCalendars[self.groupKeyArray[section]]!
//        let currentCalendar : CalendarModel = calendars[index]
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
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
        self.tabBarController?.navigationItem.title = ""
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
        vc.passedLink = self.newsArray[index].storyUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

