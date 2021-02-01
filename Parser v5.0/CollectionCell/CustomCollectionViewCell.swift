//
//  CustomCollectionViewCell.swift
//  Parser v5.0
//
//  Created by enchtein on 30.01.2021.
//

import UIKit
import Kingfisher

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var cellAvatar: UIImageView!
    
    
    public func setModel(with model: AllInfo?) {
        self.nameLabel.text = model?.name
        self.titleLabel.text = model?.title
        self.typeLabel.text = model?.type
        self.rankLabel.text = String(model?.rank ?? 0)
//        self.durationLabel.text = String(model?.duration ?? 0)
        if model?.duration != nil {
            let sec = String((model?.duration ?? 0) % 60)
            let seconds = sec.count == 1 ? "0"+sec : sec
//            let temp = Double(sec) ?? 0
            self.durationLabel.text = String((model?.duration ?? 0) / 60) + ":\(seconds) min"
        } else {
            self.durationLabel.text = String(0)
        }
        if let cellImage = URL(string: model?.album?.cover ?? "") {
            self.cellAvatar.kf.indicatorType = .activity
            self.cellAvatar.kf.setImage(with: cellImage)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
