//
//  FeedViewController.swift
//  Abord
//
//  Created by Mayank on 30/03/20.
//  Copyright © 2020 Mayank. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var posts = [PFObject]()
    

    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        //For Example, if you only want to query the last 20
        query.limit = 20
        query.findObjectsInBackground { (posts,Error) in
            if posts != nil{
                self.posts = posts!
                self.postTableView.reloadData()
            }   else    {
                print(Error?.localizedDescription)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = postTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        let caption = post["caption"] as! String
        tableCell.usernameLabel.text = user.username
        tableCell.CaptionLabel.text = caption
        
//        let userImageFile = post["image"] as! PFFileObject
//        userImageFile.getDataInBackground { (imageData: Data?, error: Error?) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else if let imageData = imageData {
//                print("image found!")
//                let image = UIImage(data:imageData)
//                tableCell.postPhotoView.image = image
//            }
//        }
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let imageURL = URL(string: urlString)!
        print(imageURL)
        tableCell.postPhotoView.af_setImage(withURL: imageURL)
        
        return tableCell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
