//
//  Meme.swift
//  MemeMe
//
//  Created by Noah Anderson on 4/11/16.
//  Copyright © 2016 Noah Anderson. All rights reserved.
//

import UIKit

class Meme {
    var tf1:String?
    var tf2:String?
    var img:UIImage?
    var imgMemed:UIImage?
    init(){
        self.tf1 = nil
        self.tf2 = nil
        self.img = nil
        self.imgMemed = nil
    }
    
    init(tf1: String?, tf2: String?, img: UIImage?, imgMemed: UIImage?){
        self.tf1 = tf1
        self.tf2 = tf2
        self.img = img
        self.imgMemed = imgMemed
    }
    func setMemedImg (imgMemed: UIImage){
        self.imgMemed = imgMemed
    }
}
