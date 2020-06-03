//
//  ProjectsViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/1/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class ProjectsViewController: UICollectionViewController {
    
    /// Project Names.
    var projects = [String]()
    
    /// Editable Projects.
    var editProjects = [String]()

    /// ビューを読み込んだ後、追加の設定を行います。
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = saveImage(image: UIImage(systemName: "plus")!, at: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/" + "plus"))
        
        projects = try! FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/Documents")
        projects.insert("", at: 0)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 4 - 20, height: view.frame.width / 4 - 20)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
        self.collectionView.allowsMultipleSelection = false
    }
    
    @IBAction func insertNewObjects() {
        let alert = UIAlertController(title: "新規コマ撮り", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "作成", style: .default, handler: { _ in
            let fileName = alert.textFields?[0].text!
            if !(fileName?.isEmpty ?? false) {
                if !(fileName?.contains("/"))! {
                    if !FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Documents/" + fileName!) {
                        if let fileName = fileName {
                            do {
                                try self.createDir(atPath: NSHomeDirectory() + "/Documents/" + fileName)
                                self.projects.insert(fileName, at: 1)
                                self.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                            } catch {
                                let alert = UIAlertController(title: "プロジェクトを作成できませんでした。", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alert, animated: true)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: """
コマ撮り "\(fileName!)" は既に存在します。
""", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                } else {
                    let alert = UIAlertController(title: """
名前には "/"（スラッシュ）は含めないでください。
""", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "名前は必須です。", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func edit() {
        if navigationItem.leftBarButtonItem?.title == "編集" {
            navigationItem.leftBarButtonItem?.title = "完了"
            navigationItem.leftBarButtonItem?.style = .done
            // 複数選択を許可
            self.collectionView.allowsMultipleSelection = true
        } else {
            navigationItem.leftBarButtonItem?.title = "編集"
            navigationItem.leftBarButtonItem?.style = .plain
            self.collectionView.allowsMultipleSelection = false
            for i in 0..<projects.count {
                let cell = collectionView.cellForItem(at: IndexPath(item: i, section: projects.count - 1)) as? CustomCell
                cell?.isMarked = false
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Project", for: indexPath) as! CustomCell
        let label = cell.viewWithTag(1) as! UILabel; label.text = projects[indexPath.row]
        var files = [String]()
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/Documents/" + projects[indexPath.row])
        } catch {
            
        }
        if files.count != 0 {
            if let image = UIImage(contentsOfFile: "\(NSHomeDirectory())/Documents/\(projects[indexPath.row])/\(files[0])") {
                let imageView = cell.viewWithTag(2) as! UIImageView; imageView.image = image
            }
        }
        cell.backgroundColor = UIColor.systemGray6
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: CustomCell = collectionView.cellForItem(at: indexPath) as? CustomCell else { return }
        if self.collectionView.allowsMultipleSelection {
            if cell.isMarked {
                cell.isMarked = false
            } else {
                editProjects.append(projects[indexPath.row])
                cell.isMarked = true
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
