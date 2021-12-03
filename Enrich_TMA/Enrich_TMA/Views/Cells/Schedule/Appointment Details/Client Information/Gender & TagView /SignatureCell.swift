//
//  SignatureCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 10/04/20.
//  Copyright © 2020 e-zest. All rights reserved.
//

import UIKit

protocol SingatureCellDelegate: class {
    func actionClearSignature()
    func actionSaveSignature(image: UIImage)
    func actionCaptureSignature()
}

class SignatureCell: UITableViewCell {

    @IBOutlet private weak var signatureView: YPDrawSignatureView!
    @IBOutlet private weak var bottomView: UIStackView!

    weak var delegate: SingatureCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        signatureView.delegate = self
        bottomView.isHidden = true
    }

    @IBAction func actionClear(_ sender: UIButton) {
        self.signatureView.clear()
        bottomView.isHidden = true
        delegate?.actionClearSignature()
    }

    @IBAction func actionSaveSignature(_ sender: UIButton) {
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
           // UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            //self.signatureView.clear()
            delegate?.actionSaveSignature(image: signatureImage)
        }
    }

}

extension SignatureCell: YPSignatureDelegate {

    func didStart(_ view: YPDrawSignatureView) {
    }

    func didFinish(_ view: YPDrawSignatureView) {
        bottomView.isHidden = false
        delegate?.actionCaptureSignature()
    }
}
