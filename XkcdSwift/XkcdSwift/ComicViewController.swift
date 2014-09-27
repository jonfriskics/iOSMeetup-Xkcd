//
//  ComicViewController.swift
//  XkcdSwift
//
//  Created by Jon Friskics on 9/27/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController, UIScrollViewDelegate {

    // MARK: ------ Property declarations

    var comicToLoad:NSDictionary
    var comicInfo:NSDictionary?
    
    // MARK: ------ Lazy Initializers

    lazy var session:NSURLSession? = {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }()
    
    lazy var imageScrollView:UIScrollView? = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.maximumZoomScale = 5.0
        sv.backgroundColor = UIColor.lightGrayColor()
        return sv
    }()
    
    lazy var imageViewInScrollView:UIImageView? = {
        let iv = UIImageView()
        iv.userInteractionEnabled = true
        return iv
    }()
    
    lazy var comicTitle:UILabel? = {
        let label = UILabel()
        label.textAlignment = .Center
        return label
    }()

    // MARK: ------ Initializers
    
    init(passedInComic: NSDictionary) {
        comicToLoad = passedInComic
        
        super.init(nibName: nil, bundle: nil)

        automaticallyAdjustsScrollViewInsets = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ------ View Controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let longPressOnImage = UILongPressGestureRecognizer(target: self, action:"imageLongPressed:")
        imageViewInScrollView?.addGestureRecognizer(longPressOnImage)
        
        imageScrollView?.addSubview(imageViewInScrollView!)

        if let isv = imageScrollView {
            view.addSubview(isv)
        }
        
        if let ct = comicTitle {
            view.addSubview(ct)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let comicNum:Int = comicToLoad["comicNumber"] as Int
        let comicNumber = String(comicNum)
        let comicURLString = "http://xkcd.com/" + comicNumber + "/info.0.json"
        let comicURL = NSURL(string: comicURLString)
        let comicURLRequest = NSURLRequest(URL: comicURL)
        
        if let s = session {
            let task:NSURLSessionDataTask = s.dataTaskWithRequest(comicURLRequest, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) in
                
                var jsonParsingError:NSError?
                
                var jsonResponse:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &jsonParsingError) as NSDictionary?
                
                if let jsonResp = jsonResponse {
                    self.comicInfo = jsonResp
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if let ci = self.comicInfo {
                            let month = ci["month"] as NSString
                            let day = ci["day"] as NSString
                            let year = ci["year"] as NSString
                            self.title = month + "-" + day + "-" + year
                        }
                    })
                    
                    self.displayComic()
                } else {
                    if let error = jsonParsingError {
                        println("Error reading json " + error.localizedDescription)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if(imageViewInScrollView?.frame.size.height > 400) {
            imageScrollView?.frame = CGRect(x: 0, y: topLayoutGuide.length, width: 320, height: 400)
        } else {
            imageScrollView?.frame = CGRect(x: 0, y: topLayoutGuide.length, width: 320, height: imageViewInScrollView!.frame.size.height)
        }
        imageScrollView?.contentSize = CGSize(width: imageViewInScrollView!.frame.size.width, height: imageViewInScrollView!.frame.size.height)
            
        comicTitle?.frame = CGRect(x: 0, y: CGRectGetMaxY(imageScrollView!.frame), width: 320, height: 30)
    }
    
    // MARK: ------ Scroll view delegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageViewInScrollView
    }
    
    // MARK: ------ Helper methods
    
    func displayComic() {
        dispatch_async(dispatch_get_main_queue(), {
            self.comicTitle?.text = self.comicInfo!["safe_title"] as? String
            self.comicTitle?.sizeToFit()
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: self.comicInfo!["img"] as String)
            
            let data = NSData(contentsOfURL: url)
            
            let img = UIImage(data: data)
            
            let size = img.size
            
            dispatch_async(dispatch_get_main_queue(), {
                self.imageViewInScrollView?.image = img
                self.imageViewInScrollView?.contentMode = UIViewContentMode.ScaleAspectFit
                
                var heightToSet:CGFloat
                if(size.height > 400) {
                    heightToSet = 400;
                } else {
                    heightToSet = size.height;
                }
                
                self.imageViewInScrollView?.frame = CGRect(x: 0, y: 0, width: 320, height: heightToSet);
                
                self.view.setNeedsLayout()
            });
        });
    }

    func imageLongPressed(sender: UILongPressGestureRecognizer) {
        let altText = comicInfo!["alt"] as String
        let alertController = UIAlertController(title: "", message: altText, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
