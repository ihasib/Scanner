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
        pageCollectionView.register(UINib(nibName: "SingleViewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SingleViewCollectionViewCellId")
    }
    
    

}

extension TablePageViewController: UICollectionViewDelegate {
   
}

extension TablePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function)
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleViewCollectionViewCellId", for: indexPath) as! SingleViewCollectionViewCell
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


