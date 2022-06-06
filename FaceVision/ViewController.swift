//
//  ViewController.swift
//  FaceVision
//
//  Created by Tony Low on 16/02/2018.
//  Copyright © 2017 Gotcha Studio. All rights reserved.
//

import UIKit
import GoogleSignIn

@available(iOS 11.0, *)
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var loadingbar: UIActivityIndicatorView!
    
    var image: UIImage!
    
    @IBAction func skipBtnPressed(_ sender: UIButton) {
        //TODO skip login function
        // create the alert
        let alert = UIAlertController(title: "請將你的樣子置中及拍照", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        
        let picker = UIImagePickerController()
        // add an action (button)
        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: { action in
            picker.delegate = self
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                
                let size = self.view.frame.width * 0.7
                let xcoordinate = self.view.frame.width * 0.15
                let ycoordinate = self.view.frame.height * 0.5 - self.view.frame.width * 0.35
                
                let overLayImg:UIImageView = UIImageView(frame:CGRect(x:xcoordinate, y:ycoordinate, width:size, height:size))
                overLayImg.image = UIImage(named: "frame")
                imagePicker.cameraOverlayView = overLayImg
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadingbar.isHidden = true
        let transform = CGAffineTransform(scaleX: 2, y: 2)
        loadingbar.transform = transform
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: UIButton) {
        
    }
    
    func takePhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {action in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        performSegue(withIdentifier: "showImageSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageSegue" {
            if let imageViewController = segue.destination as? ImageViewController {
                imageViewController.image = self.image
            }
            loadingbar.isHidden = false
            loadingbar.startAnimating()
        }
    }
    
    @IBAction func exit(unwindSegue: UIStoryboardSegue) {
        image = nil
        loadingbar.isHidden = true
        loadingbar.stopAnimating()
    }
}

extension UIImagePickerController
{
    override open var shouldAutorotate: Bool {
        return false
    }
}


