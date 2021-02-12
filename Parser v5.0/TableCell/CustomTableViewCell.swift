//
//  CustomTableViewCell.swift
//  Parser v5.0
//
//  Created by enchtein on 30.01.2021.
//

import UIKit
import Kingfisher

class CustomTableViewCell: UITableViewCell {
    var delegateCell: SomeCellProtocol?
    var row: Int?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var cellAvatar: UIImageView!
    @IBOutlet weak var addToFaritesTag: UIButton!
    @IBOutlet weak var deleteFromFavoritesTag: UIButton!
    

    
    @IBOutlet weak var heartButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var durationLabelTop: NSLayoutConstraint!
    @IBOutlet weak var rankLabelTop: NSLayoutConstraint!
    @IBOutlet weak var typeLabelTop: NSLayoutConstraint!
    
    var selectedSegmentControl: String?
    

    
    private func setConstrains(with model: AllInfo) {
//        self.heartButton.isHidden = true
        self.heartButtonWidth.constant = 0
        if model.type == nil {
            typeLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            typeLabelTop.constant = 0
        }
        if model.rank == nil {
            rankLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            rankLabelTop.constant = 0
        }
        if model.duration == nil {
            durationLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            durationLabelTop.constant = 0
        } else {
            self.heartButtonWidth.constant = 30
        }
        if selectedSegmentControl == "Favorites" {
            self.addToFaritesTag.isHidden = true
            self.addToFaritesTag.isEnabled = false
            self.deleteFromFavoritesTag.isHidden = false
            self.deleteFromFavoritesTag.isEnabled = true
        } else {
            self.addToFaritesTag.isHidden = false
            self.addToFaritesTag.isEnabled = true
            self.deleteFromFavoritesTag.isHidden = true
            self.deleteFromFavoritesTag.isEnabled = false
        }
    }
    
    public func setModel(with model: AllInfo) {
        self.setConstrains(with: model)
        
        self.nameLabel.text = model.name
        self.titleLabel.text = model.title
        self.typeLabel.text = model.type

        self.rankLabel.text = String(model.rank ?? 0) + " rank"
        if model.duration != nil {
//            let sec = String(format: "%.2f", Double(model.duration! % 60)*0.01)
            let sec = String(model.duration! % 60)
            let seconds = sec.count == 1 ? "0"+sec : sec
//            let temp = Double(sec) ?? 0
            self.durationLabel.text = String(model.duration! / 60) + ":\(seconds) min"
        } else {
            self.durationLabel.text = String(0)
        }
        if let cellImage = URL(string: model.picture ?? "") {
            self.cellAvatar.kf.indicatorType = .activity
            self.cellAvatar.kf.setImage(with: cellImage)
        } else if let cellImage = URL(string: model.album?.cover ?? "") {
            self.cellAvatar.kf.indicatorType = .activity
            self.cellAvatar.kf.setImage(with: cellImage)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let iTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender:)))
        iTap.numberOfTapsRequired = 1
        self.cellAvatar.addGestureRecognizer(iTap)
        self.cellAvatar.isUserInteractionEnabled = true
    }
    @objc func imageTapped(sender: UIGestureRecognizer) {
//        print(self.cellAvatar)
        let row = self.addToFaritesTag.tag
//        print(row)
        delegateCell?.imageTapped(row: row)
//        let vc = self.
        print("image was tapped")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


protocol SomeCellProtocol {
    func imageTapped(row: Int)
}
