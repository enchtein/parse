//
//  ImageScrollView.swift
//  Parser v5.0
//
//  Created by enchtein on 12.02.2021.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        self.imageView = UIImageView(image: image)
        self.addSubview(imageView!)
        
        self.configurateFor(imageSize: image.size)
//        self.minimumZoomScale = 0.1
//        self.maximumZoomScale = 2.0
        self.setCustomZoomScale()
        self.zoomScale = self.minimumZoomScale
//        self.centered()
    }
    
    private func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.centered()
    }
    
    private func setCustomZoomScale() {
        let boundsSize = self.bounds.size
//        let boundsSize = self.frame.size
        let imageSize = self.imageView?.bounds.size
        
        guard let imageSizeD = imageSize else { return }
        
        let xImage = boundsSize.width / imageSizeD.width
        let yImage = boundsSize.height / imageSizeD.height
        
        let minScale = min(xImage, yImage)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    private func centered() {
        let boundsSize = self.bounds.size
        
        guard let imageView = self.imageView else { return }
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < bounds.size.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < bounds.size.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
