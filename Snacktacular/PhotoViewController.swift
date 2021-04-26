//
//  PhotoViewController.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/26/21.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PhotoViewController: UIViewController {

    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!    
    @IBOutlet weak var photoImageView: UIImageView!
        
    var spot: Spot!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else  {
            print("ERROR: no spot passed to PhotoViewController.swift")
            return
        }
        
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    func updateUserInterface(){
        postedByLabel.text = "by: \(photo.photoUserEmail)"
        dateLabel.text = "on: \(dateFormatter.string(from: photo.date))"
        descriptionTextView.text = photo.description
        photoImageView.image = photo.image
        
        if photo.documentID == "" {
            addBorderToEditableObjects()
        }else {
            if photo.photoUserID = Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBorderToEditableObjects()
                self.navigationController?.setToolbarHidden(false, animated: true)
            }else {
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(photo.photoUserEmail)"

                descriptionTextView.isEditable = false
                descriptionTextView.backgroundColor = .white
            }
        }
    }
    
    func addBorderToEditableObjects(){
        descriptionTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leaveViewController(){
        let isPresentingInAddMode =  presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)

    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)

    }
    
    func accessCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            present(imagePickerController, animated: true, completion: nil)
        }else{
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}

