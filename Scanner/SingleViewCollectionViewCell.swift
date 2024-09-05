//
//  SingleViewCollectionViewCell.swift
//  Scanner
//
//  Created by S. M. Hasibur Rahman on 5/9/24.
//

import UIKit

class SingleViewCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(#function)
    }

//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        print(#function)
//        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//
//        attributes.size = .init(width: 250, height: 100)
//
//        return attributes
//    }
}

//extension SingleViewCollectionViewCell: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(#function)
//        let superviewSize = collectionView.frame.size
//        return superviewSize
//    }
//}
