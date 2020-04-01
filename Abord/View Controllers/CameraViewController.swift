//
//  CameraViewController.swift
//  Abord
//
//  Created by Mayank on 31/03/20.
//  Copyright © 2020 Mayank. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let post = PFObject(className: "Posts")
        post["caption"] = captionField.text!
        post["author"] = PFUser.current()!
        
        let imageFile = imageView.image!.pngData()
        let file = PFFileObject(data: imageFile!)
        post["image"] = file
        post.saveInBackground { (success, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            } else  {
//                self.dismiss(animated: true, completion: nil)
//                print("saved")
                self.performSegue(withIdentifier: "showFeed", sender: nil)
            }
        }
    }
    
    @IBAction func onCamera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)   {
            picker.sourceType = .camera
        }   else    {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
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
