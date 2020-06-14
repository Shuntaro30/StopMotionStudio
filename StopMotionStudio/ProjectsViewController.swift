//
//  ProjectsViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/1/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ProjectsViewController: UICollectionViewController {
    
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var remove: UIView!
    
    var objects = [ProjectItem]()
    
    var editingProjects = [ProjectItem]()
    
    var isEdit = false
    
    var selectedName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        remove.isHidden = true
        
        removeButton.isEnabled = false
        
        _ = try? FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/新規作成")
        
        let objects = try! FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/Documents")
        for i in 0..<objects.count {
            var images = [String]()
            do {
                images = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/Documents")
            } catch {
                let alert = UIAlertController(title: """
                    プロジェクト "\(objects[i])" を表示できません。破損している可能性があります。
                    """, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
            }
            if objects[i] != "新規作成" {
                if images.count != 0 {
                    self.objects.append(ProjectItem(image: UIImage(contentsOfFile: NSHomeDirectory() + "/Documents/" + objects[i] + "/" + images[0]), forName: objects[i]))
                } else {
                    self.objects.append(ProjectItem(image: nil, forName: objects[i]))
                }
            }
        }
        self.objects.insert(ProjectItem(image: UIImage(systemName: "plus"), forName: "新規作成"), at: 0)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 4 - 20, height: view.frame.width / 4 - 20)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
    }
    
    @IBAction func removeItems(_: Any) {
        let alert = UIAlertController(title: "\(editingProjects.count)項目を削除しますか?", message: "このムービーは完全に削除されます。この操作は取り消せません。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            let zen = self.editingProjects.count
            self.remove.isHidden = false
            print("zen: \(zen)")
            if zen != 1 {
                for i in 0..<zen {
                    if let index = self.objects.firstIndex(of: self.editingProjects[zen - i - 1]) {
                        print("index: \(index)")
                        print("i: \(i)")
                        do {
                            if i != 0 {
                                if self.editingProjects.count >= zen - i - 1 {
                                    print("削除しています... パス: \(NSHomeDirectory() + "/Documents/" + self.editingProjects[zen - i - 1].string!)")
                                    print("zen - i: \(zen - i)")
                                    try FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/\(self.editingProjects[zen - i - 1].string ?? "")")
                                } else {
                                    self.remove.isHidden = true
                                    let alert = UIAlertController(title: "削除できませんでした。", message: nil, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true)
                                    return
                                }
                            } else {
                                try FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/\(self.editingProjects[zen - i - 1].string ?? "")")
                            }
                            
                        } catch {
                            print("'\(self.editingProjects[zen - i - 1].string!)' を削除できませんんでした。エラー: \(error.localizedDescription)")
                            self.remove.isHidden = true
                            let alert = UIAlertController(title: "削除できませんでした。", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            return
                        }
                        UserDefaults.standard.removeObject(forKey: self.editingProjects[zen - i - 1].string!)
                        if i != 0 {
                            if let index = self.objects.firstIndex(of: self.editingProjects[zen - i - 1]) {
                                self.objects.remove(at: index)
                                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                            }
                            self.editingProjects.remove(at: zen - i - 1)
                        } else {
                            if let index = self.objects.firstIndex(of: self.editingProjects[zen - 1]) {
                                self.objects.remove(at: index)
                                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                            }
                            self.editingProjects.remove(at: zen - 1)
                        }
                    }
                }
            } else {
                for i in 1...zen {
                    print("i: \(i)")
                    do {
                        if i != 0 {
                            if self.editingProjects.count >= zen - i {
                                print("削除しています... パス: \(NSHomeDirectory() + "/Documents/" + self.editingProjects[zen - i].string!)")
                                print("zen - i: \(zen - i)")
                                try FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/\(self.editingProjects[zen - i].string ?? "")")
                            } else {
                                self.remove.isHidden = true
                                let alert = UIAlertController(title: "削除できませんでした。", message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true)
                                return
                            }
                        } else {
                            try FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Documents/\(self.editingProjects[zen - 1].string ?? "")")
                        }
                    } catch {
                        print("'\(self.editingProjects[zen - i].string!)' を削除できませんんでした。エラー: \(error.localizedDescription)")
                        self.remove.isHidden = true
                        let alert = UIAlertController(title: "削除できませんでした。", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        return
                    }
                    UserDefaults.standard.removeObject(forKey: self.editingProjects[zen - i].string!)
                    if i != 0 {
                        if let index = self.objects.firstIndex(of: self.editingProjects[zen - i]) {
                            self.objects.remove(at: index)
                            self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                        }
                        self.editingProjects.remove(at: zen - i)
                    } else {
                        if let index = self.objects.firstIndex(of: self.editingProjects[zen - 1]) {
                            self.objects.remove(at: index)
                            self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                        }
                        self.editingProjects.remove(at: zen - 1)
                    }
                }
            }
            self.removeButton.isEnabled = false
            self.remove.isHidden = true
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func insertNewObjects(sender _: Any?) {
        let alert = UIAlertController(title: "新規コマ撮り", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "作成", style: .default, handler: { _ in
            let fileName = alert.textFields?[0].text!
            if fileName! != "新規作成" {
                if !(fileName?.isEmpty ?? false) {
                    if !(fileName?.contains("/"))! {
                        if !FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Documents/" + fileName!) {
                            let strings = try? FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/Documents/" + fileName!)
                            if let image = UIImage(contentsOfFile: "\(NSHomeDirectory())/Documents/\(fileName ?? "")/\(strings?[0] ?? "")") {
                                if !self.objects.contains(ProjectItem(image: image, forName: fileName!)) {
                                    if let fileName = fileName {
                                        do {
                                            try self.createDir(atPath: NSHomeDirectory() + "/Documents/" + fileName)
                                            self.objects.insert(ProjectItem(image: nil, forName: fileName), at: 1)
                                            self.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                                            UserDefaults.standard.set(0.1, forKey: fileName)
                                        } catch {
                                            let alert = UIAlertController(title: "プロジェクトを作成できませんでした。", message: error.localizedDescription, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        }
                                    }
                                }
                            } else {
                                if !self.objects.contains(ProjectItem(image: nil, forName: fileName!)) {
                                    if let fileName = fileName {
                                        do {
                                            try self.createDir(atPath: NSHomeDirectory() + "/Documents/" + fileName)
                                            self.objects.insert(ProjectItem(image: nil, forName: fileName), at: 1)
                                            self.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                                            UserDefaults.standard.set(0.1, forKey: fileName)
                                        } catch {
                                            let alert = UIAlertController(title: "プロジェクトを作成できませんでした。", message: error.localizedDescription, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        }
                                    }
                                }
                            }
                        } else {
                            let alert = UIAlertController(title: """
    コマ撮り "\(fileName!)" は既に存在します。
    """, message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                self.insertNewObjects(sender: nil)
                            }))
                            self.present(alert, animated: true)
                        }
                    } else {
                        let alert = UIAlertController(title: """
    名前には "/"（スラッシュ）は含めないでください。
    """, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.insertNewObjects(sender: nil)
                        }))
                        self.present(alert, animated: true)
                    }
                } else {
                    let alert = UIAlertController(title: "名前は必須です。", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.insertNewObjects(sender: nil)
                    }))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: """
名前に "新規作成" は使用しないでください。
""", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.insertNewObjects(sender: nil)
                }))
                self.present(alert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func edit() {
        removeButton.isEnabled = false
        if navigationItem.leftBarButtonItem?.title == "編集" {
            navigationItem.leftBarButtonItem?.title = "完了"
            navigationItem.leftBarButtonItem?.style = .done
            objects.remove(at: 0)
            self.collectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
            self.isEdit = true
        } else {
            self.isEdit = false
            navigationItem.leftBarButtonItem?.title = "編集"
            navigationItem.leftBarButtonItem?.style = .plain
            self.editingProjects.removeAll()
            self.objects.insert(ProjectItem(image: UIImage(systemName: "plus"), forName: "新規作成"), at: 0)
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = true
            let indexPaths = self.collectionView.indexPathsForSelectedItems!
            indexPaths.forEach { indexPath in
                let cell: CustomCell? = self.collectionView.cellForItem(at: indexPath) as? CustomCell
                cell?.clearCheckmark()
                self.collectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Project", for: indexPath) as! CustomCell
        let label = cell.viewWithTag(1) as! UILabel; label.text = objects[indexPath.row].string ?? ""
        let imageView = cell.viewWithTag(2) as! UIImageView; imageView.image = objects[indexPath.row].image
        imageView.tintColor = UIColor.white
        if objects[indexPath.row].string == "新規作成" {
            imageView.frame = CGRect(x: Int((view.frame.width / 4.0 - 20.0)) / 4, y: Int((view.frame.width / 4.0 - 20.0)) / 4 - 15, width: Int((view.frame.width / 4.0 - 20.0)) / 2, height: Int((view.frame.width / 4.0 - 20.0)) / 2)
        }
        cell.backgroundColor = .darkGray
        cell.layer.cornerRadius = 7.5
        cell.clearCheckmark()
        return cell
    }
    
    // Cell がタップで選択されたときに呼ばれる
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: CustomCell = collectionView.cellForItem(at: indexPath) as? CustomCell else { return }
        if isEdit {
            if objects[indexPath.row].string ?? "" != "" {
                if objects[indexPath.row].string != "新規作成" {
                    cell.isMarked = true
                    editingProjects.insert(objects[indexPath.row], at: 0)
                    if editingProjects.count == 0 {
                        removeButton.isEnabled = false
                    } else {
                        removeButton.isEnabled = true
                    }
                }
            }
        } else {
            if objects[indexPath.row].string == "新規作成" {
                self.insertNewObjects(sender: nil)
            } else {
                self.performSegue(withIdentifier: "showEditor", sender: nil)
                self.selectedName = objects[indexPath.row].string ?? ""
            }
        }
    }
    
    // Cell がタップで選択解除されたときに呼ばれる
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: CustomCell = collectionView.cellForItem(at: indexPath) as? CustomCell else { return }
        if isEdit {
            cell.isMarked = false
            if editingProjects.count != 0 {
                if objects[indexPath.row].string != "新規作成" {
                    editingProjects.remove(at: editingProjects.firstIndex(of: objects[indexPath.row])!)
                    if editingProjects.count == 0 {
                        removeButton.isEnabled = false
                    } else {
                        removeButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    /// Save the Image.
    private func saveImage(image: UIImage, at url: URL) -> Bool {
        //pngで保存する場合
        let pngImageData = image.pngData()
        do {
            try pngImageData!.write(to: url)
        } catch {
            //エラー処理
            return false
        }
        return true
    }
    
    /// Create the Directory.
    func createDir(atPath dirPath: String) throws {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // エラーの場合
            throw NSError(domain: error.localizedDescription, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? EditViewController
        controller?.projectName = selectedName
        controller?.navigationItem.title = selectedName
    }

}
