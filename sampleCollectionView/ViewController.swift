//
//  ViewController.swift
//  sampleCollectionView
//
//  Created by yuka on 2018/06/28.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var musicList:[[String:Any]] = [[String:Any]]()
 
    // 以下レイアウト用
    let margin:CGFloat = 3.0

    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: "-._~")
        let word = "星野源".addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let num = 30
        //itunesのAPIから情報を20件取得
        guard let url = URL(string: "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=\(word!)&limit=\(num)") else {
            print("cannot create URL")
            return
        }
        
        let request = URLRequest(url:url)

        let group = DispatchGroup()
        group.enter()
        let task = URLSession.shared.dataTask(with: request) {
            (data:Data?,response:URLResponse?,error:Error?) in

            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        print(json["results"],"APIデータ")
                        
                        
                        self.musicList = json["results"] as! [[String:Any]]
                        group.leave()

                    }
                }
                catch {
                    
                    print(error.localizedDescription)
                }
            }
            
        }
        
        group.notify(queue: .main, execute: {
            print("notify closure called")
            
            self.myCollectionView.reloadData()
            self.myIndicator.stopAnimating()
            self.myIndicator.isHidden = true
        })
        
        task.resume()
        
        

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellko", for: indexPath)
        
        cell.backgroundColor = UIColor.brown
        cell.contentView.backgroundColor = UIColor.blue
        
        print(cell.contentView.subviews,indexPath.row)
        let imageView = cell.contentView.subviews.first as! UIImageView
        let url = URL(string: musicList[indexPath.row]["artworkUrl100"] as! String)
        let imageData :Data = (try! Data(contentsOf: url!,options: NSData.ReadingOptions.mappedIfSafe)) //mappedIfSafe: 安全で可能なら、ファイルを仮想メモリに入れる。
        
        imageView.image = UIImage(data:imageData)
        
        let label = cell.contentView.subviews[1] as! UILabel
        label.text = musicList[indexPath.row]["trackName"] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        
        var colNum:CGFloat = 3
        if UIDevice.current.model == "iPad" {
            colNum = 5
        }
        
        let widthOfCol  = (width - margin * (colNum + 1)) / colNum
        let heightOfCol = widthOfCol
        

        return CGSize(width: widthOfCol, height: heightOfCol)
        
    }
    
    // 画面の端からの距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    // collectionView同士の幅、横軸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
}

