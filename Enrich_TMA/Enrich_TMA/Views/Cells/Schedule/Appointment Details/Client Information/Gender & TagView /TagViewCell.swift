//
//  TagViewCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 04/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit
import TagListView

protocol TagViewSelectionDelegate: class {
    func actionTagSelection(tag: String, index: Int)
}

class TagViewCell: UITableViewCell, TagListViewDelegate {

    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var tagListView: TagListView!
    @IBOutlet weak private var asteriskIcon: UIImageView!

    var indexPath: IndexPath?
    var isSingleSelection = false
    weak var delegate: TagViewSelectionDelegate?
    var tagViewModel: TagViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(model: TagViewModel) {
        tagViewModel = model
        isSingleSelection = (model.field_type == .radio)
        if let font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 16) {
            tagListView.textFont = font
        }
        lblTitle.text = model.title
        tagListView.delegate = self
        tagListView.removeAllTags()
        tagListView.alignment = .center
        asteriskIcon.isHidden = !model.isRequired

        model.tagView.forEach {
            tagListView.addTag($0.text)
            tagListView.tagViews.last?.isSelected = $0.isSelected
        }

    }

    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        let status = !tagView.isSelected
        if isSingleSelection {tagListView.selectedTags().forEach {$0.isSelected = false}}
        tagView.isSelected = status
        if let indexPath = indexPath {
            self.delegate?.actionTagSelection(tag: title, index: indexPath.row)
        }

        if isSingleSelection {
            self.tagViewModel?.tagView.forEach {$0.isSelected = false}
            let tags = self.tagViewModel?.tagView.filter {$0.text == title}
            tags?.first?.isSelected = status
        }
        else {
            let tags = self.tagViewModel?.tagView.filter {$0.text == title}
            tags?.first?.isSelected = status
        }

    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        // sender.removeTagView(tagView)
    }

}

enum FieldType: String {
    case radio = "radio"
    case checkbox = "checkboxes"
    case commentBox = "text"
    case signature = "file_upload"
}

class TagViewString {
    let text: String
    var isSelected: Bool

    init(text: String, isSelected: Bool) {
        self.text = text
        self.isSelected = isSelected
    }
}

class TagViewModel {
    let title: String
    let tagView: [TagViewString]
    var value: String
    let id: String
    let size: String
    let field_type: FieldType
    let isRequired: Bool

    init(title: String, tagView: [TagViewString], value: String, id: String, size: String, field_type: FieldType, isRequired: Bool) {
        self.title = title
        self.tagView = tagView
        self.value = value
        self.id = id
        self.size = size
        self.field_type = field_type
        self.isRequired = isRequired
    }
}
