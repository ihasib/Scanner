//
//  TablePageViewController.swift
//  Scanner
//
//  Created by S. M. Hasibur Rahman on 4/9/24.
//

import UIKit

class TablePageViewController: UIViewController {
    @IBOutlet weak var pageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self
        pageCollectionView.register(UINib(nibName: "SingleViewCollectionViewCell", bundle: Bundle.module), forCellWithReuseIdentifier: "SingleViewCollectionViewCellId")
    }
    
    

}

extension TablePageViewController: UICollectionViewDelegate {
   
}

extension TablePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        return ScannerViewController.batchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleViewCollectionViewCellId", for: indexPath) as! SingleViewCollectionViewCell
        let url = Bundle.main.url(forResource: "pic", withExtension: "png")
        cell.imageView.image = UIImage(contentsOfFile: url!.path)
        if let image = ScannerViewController.batchResult[indexPath.row].enhancedScan?.image {
            print("set captured image")
            cell.imageView.image = image
        }

        return cell
    }
    
}


extension TablePageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function)
        print("collectionView frame= \(collectionView.frame.size)")
        print("collectionView bounds= \(collectionView.bounds.size)")
        var superviewSize = collectionView.frame.size
//        superviewSize = CGSize(width: 120.0, height: 120.0)
        return superviewSize
    }
    
    
}


