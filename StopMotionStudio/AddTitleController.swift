//
//  AddTitleController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/13/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit
import AMColorPicker

class AddTitleController: UIViewController, AMColorPickerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    var image: UIImage?
    var index = 0
    
    let colorPickerViewController = AMColorPickerViewController()
    
    var preVC: EditViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func add(_ sender: Any) {
        let textMaker = TITextImage()
        let textImage = textMaker.addText(toImage: image!, string: textView.text ?? "", textColor: colorPickerViewController.selectedColor)
        let controller = self.preVC
        controller?.images.remove(at: self.index)
        controller?.images.insert(textImage, at: self.index)
        controller?.imagesView.reloadData()
        controller?.editableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectColor(_ sender: Any) {
        colorPickerViewController.selectedColor = .red
        colorPickerViewController.delegate = self
        colorPickerViewController.popoverPresentationController?.sourceView = okButton.customView
        colorPickerViewController.popoverPresentationController?.sourceRect = okButton.customView?.bounds as! CGRect
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor) {
        
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
