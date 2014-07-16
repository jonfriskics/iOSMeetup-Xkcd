//
//  ComicViewController.swift
//  XkcdSwift
//
//  Created by Jon Friskics on 7/13/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController, UIScrollViewDelegate {

    var comicToLoad:NSDictionary
    
    var session:NSURLSession?
    var comicInfo:NSDictionary?
    var imageScrollView:UIScrollView?
    var imageViewInScrollView:UIImageView?
    var comicTitle:UILabel?

    init(passedInComic: NSDictionary) {
        comicToLoad = passedInComic
        
        super.init(nibName: nil, bundle: nil)

        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        view.backgroundColor = UIColor.whiteColor()
        
        let longPressOnImage = UILongPressGestureRecognizer(target: self, action:"imageLongPressed:")

        imageViewInScrollView = UIImageView()
        if let iv = imageViewInScrollView {
            iv.userInteractionEnabled = true
            
            iv.addGestureRecognizer(longPressOnImage)
        }

        imageScrollView = UIScrollView()
        if let sv = imageScrollView {
            sv.delegate = self
            sv.maximumZoomScale = 5.0
            sv.backgroundColor = UIColor.lightGrayColor()
            
            sv.addSubview(imageViewInScrollView)
        }

        view.addSubview(imageScrollView)

        comicTitle = UILabel()
        if let ct = comicTitle {
            ct.textAlignment = NSTextAlignment.Center
        }

        view.addSubview(comicTitle)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController.setNavigationBarHidden(false, animated: true)
        
        let comicNumber = comicToLoad["comicNumber"].stringValue
        let comicURLString = "http://xkcd.com/" + comicNumber + "/info.0.json"
        let comicURL = NSURL(string: comicURLString)
        let comicURLRequest = NSURLRequest(URL: comicURL)
        
        println(comicURLRequest)
        
        if let s = session {
            let task:NSURLSessionDataTask = s.dataTaskWithRequest(comicURLRequest, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) in
                
                var jsonParsingError:NSError?
                
                var jsonResponse:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &jsonParsingError) as NSDictionary
                
                if jsonResponse == nil {
                    if let error = jsonParsingError {
                        println("Error reading json " + error.localizedDescription)
                    }
                } else {
                    self.comicInfo = jsonResponse
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if let ci = self.comicInfo {
                            let month = ci["month"] as NSString
                            let day = ci["day"] as NSString
                            let year = ci["year"] as NSString
                            self.title = month + "-" + day + "-" + year
                        }
                    })
                    
                    self.displayComic()
                }
                })
            
            task.resume()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if(imageViewInScrollView!.frame.size.height > 400) {
            imageScrollView!.frame = CGRect(x: 0, y: topLayoutGuide.length, width: 320, height: 400)
        } else {
            imageScrollView!.frame = CGRect(x: 0, y: topLayoutGuide.length, width: 320, height: imageViewInScrollView!.frame.size.height)
        }
        imageScrollView!.contentSize = CGSize(width: imageViewInScrollView!.frame.size.width, height: imageViewInScrollView!.frame.size.height)
            
        comicTitle!.frame = CGRect(x: 0, y: CGRectGetMaxY(imageScrollView!.frame), width: 320, height: 30)
    }
    
    func displayComic() {
        dispatch_async(dispatch_get_main_queue(), {
            self.comicTitle!.text = self.comicInfo!["safe_title"] as String
            self.comicTitle!.sizeToFit()
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: self.comicInfo!["img"] as String)

            let data = NSData(contentsOfURL: url)
            
            let img = UIImage(data: data)
            
            let size = img.size
            
            dispatch_async(dispatch_get_main_queue(), {
                self.imageViewInScrollView!.image = img
                self.imageViewInScrollView!.contentMode = UIViewContentMode.ScaleAspectFit
                
                var heightToSet:CGFloat
                if(size.height > 400) {
                    heightToSet = 400;
                } else {
                    heightToSet = size.height;
                }
                
                self.imageViewInScrollView!.frame = CGRect(x: 0, y: 0, width: 320, height: heightToSet);
                
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
    
    // #pragma mark Scroll view delegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageViewInScrollView
    }
    
}
