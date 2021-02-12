//
//  ImageViewController.swift
//  Parser v5.0
//
//  Created by enchtein on 12.02.2021.
//

import UIKit

class ImageViewController: UIViewController {
    var clearDataDelegate: AllInfo?
    var scrollView: ImageScrollView?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.scrollView = ImageScrollView(frame: self.view.bounds)
        self.setConstraints()
        var imagePath = ""
//        dump(clearDataDelegate)
//        fatalError()
        if clearDataDelegate?.picture != nil {
            imagePath = (clearDataDelegate?.picture!)!
        } else {
            imagePath = (clearDataDelegate?.album!.cover!)!
        }
        
        let url = URL(string: imagePath)
        let data = try? Data(contentsOf: url!)
        
        
        guard let scrollView = self.scrollView, let imageD = UIImage(data: data!) else { return }
        scrollView.set(image: imageD)
    }
    func setConstraints() {
        guard let scrollView = self.scrollView else { return }
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        scrollView.backgroundColor = .orange
    }

}
