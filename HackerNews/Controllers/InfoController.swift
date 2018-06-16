//
//  InfoController.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import UIKit

class InfoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLinkedInPressed(_ sender: UIButton) {
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
            vc.passedLink = "https://www.linkedin.com/in/juanmanuelledesma/"
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnGitHubPressed(_ sender: UIButton) {
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
        vc.passedLink = "https://github.com/Juanledesmaa/HackerNews"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
