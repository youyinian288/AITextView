//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import AITextView

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var editorView: AITextView!
    var htmlTextView: UITextView!

    lazy var toolbar: AITextToolbar = {
        let toolbar = AITextToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = AITextDefaultOption.all
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEditorView()
    }
    
    private func setupUI() {
        // 创建editorView
        editorView = AITextView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editorView)
        
        // 创建htmlTextView
        htmlTextView = UITextView()
        htmlTextView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            htmlTextView.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            htmlTextView.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        htmlTextView.font = UIFont(name: "CourierNewPSMT", size: 14)
        htmlTextView.isEditable = false
        htmlTextView.text = "HTML Preview"
        view.addSubview(htmlTextView)
        
        // 添加toolbar
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置约束
        setupConstraints()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // editorView占上半部分
            editorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            editorView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.5, constant: -22),
            
            // toolbar在editorView底部
            toolbar.topAnchor.constraint(equalTo: editorView.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            
            // htmlTextView占下半部分
            htmlTextView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            htmlTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            htmlTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            htmlTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupEditorView() {
        editorView.delegate = self
        editorView.placeholder = "Edit here"
        
        // 使用新的键盘工具栏功能 - 更简洁的方式
        editorView.showsKeyboardToolbar = true
        editorView.keyboardToolbarDoneButtonText = "Done"
        
        toolbar.delegate = self
        toolbar.editor = editorView
        editorView.html = "<b>Jesus is God.</b> He saves by grace through faith alone. Soli Deo gloria! <a href='https://perfectGod.com'>perfectGod.com</a>"
    }
    
    // MARK: - Image Selection Methods
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func presentImageURLInput() {
        let alertController = UIAlertController(title: "输入图片URL", message: "请输入图片的网络地址", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "https://example.com/image.jpg"
            textField.keyboardType = .URL
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let urlString = textField.text,
               !urlString.isEmpty {
                self.insertImageFromURL(urlString)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func insertImageFromURL(_ urlString: String) {
        editorView.insertImage(urlString, alt: "Online Image")
    }
    
    private func insertLocalImage(_ image: UIImage) {
        // 将本地图片转换为base64格式插入
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            let dataURL = "data:image/jpeg;base64,\(base64String)"
            editorView.insertImage(dataURL, alt: "Local Image")
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let editedImage = info[.editedImage] as? UIImage {
                self.insertLocalImage(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                self.insertLocalImage(originalImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}

extension ViewController: AITextDelegate {

    func aiText(_ editor: AITextView, heightDidChange height: Int) { }

    func aiText(_ editor: AITextView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

    func aiTextTookFocus(_ editor: AITextView) { }
    
    func aiTextLostFocus(_ editor: AITextView) { }
    
    func aiTextDidLoad(_ editor: AITextView) { }
    
    func aiText(_ editor: AITextView, shouldInteractWith url: URL) -> Bool { return true }

    func aiText(_ editor: AITextView, handleCustomAction content: String) { }
    
}

extension ViewController: AITextToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors = [
            UIColor.red,
            UIColor.orange,
            UIColor.yellow,
            UIColor.green,
            UIColor.blue,
            UIColor.purple
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func aiTextToolbarChangeTextColor(_ toolbar: AITextToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func aiTextToolbarChangeBackgroundColor(_ toolbar: AITextToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func aiTextToolbarInsertImage(_ toolbar: AITextToolbar) {
        let alertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        // 从相册选择
        let photoLibraryAction = UIAlertAction(title: "从相册选择", style: .default) { _ in
            self.presentImagePicker()
        }
        alertController.addAction(photoLibraryAction)
        
        // 输入在线图片URL
        let urlAction = UIAlertAction(title: "输入图片URL", style: .default) { _ in
            self.presentImageURLInput()
        }
        alertController.addAction(urlAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        // 设置iPad的popover
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }

    func aiTextToolbarInsertLink(_ toolbar: AITextToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
//       if let hasSelection = toolbar.editor?.rangeSelectionExists(), hasSelection {
//           toolbar.editor?.insertLink("http://github.com/cjwirth/AITextView", title: "Github Link")
//       }
    }
}
