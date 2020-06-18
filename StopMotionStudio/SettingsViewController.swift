//
//  SettingsViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/12/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var projectName = ""

    /// Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        slider.setValue(Float(UserDefaults.standard.double(forKey: projectName)), animated: false)
        set()
    }
    
    func set() {
        currentTime.frame = CGRect(
            x: slider.thumbFrame.minX - slider.thumbFrame.width - 3,
            y: currentTime.frame.minY,
            width: currentTime.frame.width,
            height: currentTime.frame.height
        )
        currentTime.text = String(round(slider.value * 100) / 100)
        UserDefaults.standard.set(Double(slider.value), forKey: projectName)
    }
    
    @IBAction func setTimer(_: Any) {
        set()
    }
    
    @IBAction func set01() {
        slider.setValue(0.1, animated: true)
        set()
    }
    
    @IBAction func set005() {
        slider.setValue(0.05, animated: true)
        set()
    }
    
    @IBAction func set10() {
        slider.setValue(10, animated: true)
        set()
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

extension UISlider {
    
    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }
    
    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }
    
    var thumbBounds: CGRect {
        return thumbRect(forBounds: frame, trackRect: trackBounds, value: value)
    }
    
    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
}
