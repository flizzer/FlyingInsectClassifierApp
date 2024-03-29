//
//  ViewController.swift
//  FlyingInsectClassifierApp
//
//  Created by Brian Davis on 7/16/19.
//  Copyright © 2019 Brian Davis. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController
    , UIImagePickerControllerDelegate
    , UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController
        , didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked =
            info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage {
                imageView.image = imagePicked
            
            guard let ciImage = CIImage(image: imagePicked)
                else {
                fatalError("Could not convert UIImage to CIImage!")
            }
            
            detect(ciImage: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(ciImage: CIImage)
    {
        guard let model = try? VNCoreMLModel(
            for: FlyingInsectImageClassifierWithAugs_UpdatedPics().model) else {
                fatalError("Loading of Model failed!")
        }
        
        let request = VNCoreMLRequest(model: model) {
            (request, error) in
            guard let results = request.results
                as? [VNClassificationObservation]
                else
            {
                fatalError("Could not get request results!")
            }
            
            if let classification = results.first {
                switch (classification.identifier) {
                case "Bee":
                    self.navigationItem.title =
                    "Bee - \(classification.confidence * 100)% confidence!"
                case "Dirt Dauber":
                    self.navigationItem.title =
                    "Dirt Dauber - \(classification.confidence * 100)% confidence!"
                case "Hornet":
                    self.navigationItem.title =
                    "Hornet - \(classification.confidence * 100)% confidence!"
                case "Yellow Jacket":
                    self.navigationItem.title =
                    "Yellow Jacket - \(classification.confidence * 100)% confidence!"
                case "Wasp":
                    self.navigationItem.title =
                    "Wasp - \(classification.confidence * 100)% confidence!"
                default:
                    self.navigationItem.title =
                    "Unknown"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    
}

