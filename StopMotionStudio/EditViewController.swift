//
//  EditViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/5/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit
import AVFoundation

final class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagesView: UICollectionView!
    @IBOutlet weak var editableView: UICollectionView!
    @IBOutlet weak var firstSecond: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput = AVCapturePhotoOutput()
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var images = [UIImage]()
    
    var picker: UIImagePickerController = UIImagePickerController()
    
    var isPlay = false
    
    var timer = Timer()
    
    var projectName = ""
    
    var sourceIndexPath = IndexPath(item: 0, section: 0)
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        let layout = UICollectionViewFlowLayout()
        var frame = imagesView.frame as CGRect
        layout.itemSize = CGSize(width: view.frame.width, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        imagesView.collectionViewLayout = layout
        imagesView.isHidden = true
        imagesView.isPagingEnabled = true
        frame = editableView.frame as CGRect
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: frame.width / 5, height: frame.height)
        layout2.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout2.scrollDirection = .horizontal
        editableView.collectionViewLayout = layout2
        resetFrame()
        
        scrollView.delegate = self
    }
    
    func resetFrame() {
        let frame = imagesView.frame as CGRect
        var editableFrame = editableView.frame as CGRect
        editableView.frame = CGRect(x: view.frame.width / 2 - (frame.width / 5 / 2), y: 0, width: CGFloat(images.count * Int(frame.width) / 5), height: editableFrame.height)
        editableFrame = editableView.frame as CGRect
        scrollView.contentSize = CGSize(width: editableFrame.width + editableFrame.minX * 2, height: editableFrame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Notifies the view controller that its view is about to be added to a view hierarchy.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSet" {
            let controller = segue.destination as? SettingsViewController
            controller?.projectName = self.projectName
        } else if segue.identifier == "addTitle" {
            let controller = segue.destination as? AddTitleController
            controller?.image = images[currentIndex]
            controller?.index = self.currentIndex
            controller?.preVC = self
        }
    }
    
    @IBAction func showSettings(_: Any) {
        self.performSegue(withIdentifier: "showSet", sender: nil)
    }
    
    @IBAction func chengeEditor(_: Any) {
        print("changeValue!")
        if firstSecond.selectedSegmentIndex == 0 {
            print(true)
            imagesView.isHidden = true
            captureSession.startRunning()
        } else {
            print(false)
            imagesView.isHidden = false
            captureSession.stopRunning()
        }
    }
    
    @IBAction func pushCameraButton(_: Any) {
        if self.currentDevice != nil {
            let settings = AVCapturePhotoSettings()
            // フラッシュの設定
            settings.flashMode = .auto
            // 撮影された画像をdelegateメソッドで処理
            self.photoOutput.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
        }
    }
    
    @IBAction func pickUpPhoto(_: Any) {
        //PhotoLibraryから画像を選択
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        //デリゲートを設定する
        picker.delegate = self
        
        //現れるピッカーNavigationBarの文字色を設定する
        picker.navigationBar.tintColor = UIColor.white
        
        //現れるピッカーNavigationBarの背景色を設定する
        picker.navigationBar.barTintColor = UIColor.gray
        
        //ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }
    
    // 再生/停止
    @IBAction func play(_: Any) {
        if !isPlay {
            self.timer = Timer.scheduledTimer(timeInterval: UserDefaults.standard.double(forKey: self.projectName), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlay = true
        } else {
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlay = false
        }
    }
    
    func play2() {
        if !isPlay {
            self.timer = Timer.scheduledTimer(timeInterval: UserDefaults.standard.double(forKey: self.projectName), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlay = true
        } else {
            timer.invalidate()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlay = false
        }
    }
    
    // コマを進める（はず）
    @objc func timerUpdate() {
        if currentIndex < images.count {
            imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真を取得する
        let image = info[.originalImage] as! UIImage
        images.append(image)
        self.imagesView.reloadData()
        self.editableView.reloadData()
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    //画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: カメラ設定メソッド
extension EditViewController {
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        // currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            if let currentDevice = self.currentDevice {
                // 指定したデバイスを使用するために入力を初期化
                let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
                // 指定した入力をセッションに追加
                captureSession.addInput(captureDeviceInput)
                // 出力データを受け取るオブジェクトの作成
                photoOutput = AVCapturePhotoOutput()
                // 出力ファイルのフォーマットを指定
                photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                captureSession.addOutput(photoOutput)
            }
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer, at: 0)
    }
}

extension EditViewController: AVCapturePhotoCaptureDelegate {
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            guard let image = UIImage(data: imageData) else { return }
            images.append(image)
            self.imagesView.insertItems(at: [IndexPath(item: images.count - 1, section: 0)])
        }
    }
}

extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        sourceIndexPath = indexPath
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.images[indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        sourceIndexPath = indexPath
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.images[indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let indexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        images.insert(images.remove(at: sourceIndexPath.row), at: indexPath.row)
        editableView.moveItem(at: sourceIndexPath, to: indexPath)
        imagesView.moveItem(at: sourceIndexPath, to: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // ドラッグ元が自分のアプリかどうかを判断
        if session.localDragSession != nil {
            // 新しいアイテムの挿入なのでinsertAtDestinationIndexPathを使用
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            // 新しいアイテムの挿入なのでinsertAtDestinationIndexPathを使用
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resetFrame()
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === imagesView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath)
            let imageView = cell.viewWithTag(1) as? UIImageView
            imageView?.image = images[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCell", for: indexPath)
            let imageView = cell.viewWithTag(1) as? UIImageView
            imageView?.image = images[indexPath.row]
            return cell
        }
    }
    
    // メニューを出すよ
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        // ①プレビューの定義
        let previewProvider: () -> PreviewViewController = { [unowned self] in
            let controller = PreviewViewController()
            controller.image = self.images[indexPath.row]
            return controller
        }
        
        // ②メニューの定義
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let remove = UIAction(title: "削除", image: UIImage(systemName: "trash")) { _ in
                self.images.remove(at: indexPath.row)
                self.editableView.deleteItems(at: [indexPath])
                self.imagesView.deleteItems(at: [indexPath])
            }
            let menu: UIMenu = {
                let share = UIAction(title: "このコマを共有", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    let activityVC = UIActivityViewController(activityItems: [self.images[indexPath.row]], applicationActivities: nil)
                    let sourceView = collectionView.cellForItem(at: indexPath)
                    activityVC.popoverPresentationController?.sourceView = sourceView
                    // UIActivityViewControllerを表示
                    self.present(activityVC, animated: true, completion: nil)
                }
                return UIMenu(title: "その他", image: nil, identifier: nil, children: [share])
            }()
            return UIMenu(title: "編集", image: nil, identifier: nil, children: [remove, menu])
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider, actionProvider: actionProvider)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === self.scrollView {
            let contentOffset = scrollView.contentOffset
            print("スクロールしたよ contantsOffset.x: \(contentOffset.x)")
            let frame = self.view.frame as CGRect
            self.currentIndex = Int(round(contentOffset.x / (frame.width / 5)))
            self.imagesView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        }
    }

}
