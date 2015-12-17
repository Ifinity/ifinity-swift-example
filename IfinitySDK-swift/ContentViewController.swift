//
//  ContentViewController.swift
//  IfinitySDK-swift
//
//  Created by Ifinity on 14.12.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

import UIKit
import ifinitySDK
import SVProgressHUD

class ContentViewController: UIViewController, UIWebViewDelegate {

    var url: NSURL?;
    var content: String?;
    @IBOutlet var webView: UIWebView!;
    
    override func viewDidLoad() {
        if self.url != nil {
            self.loadUrl(self.url!)
        }
        else if self.content != nil {
            self.loadHTMLString(self.content!)
        }
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Internal Methods
    
    func loadUrl(url: NSURL) {
        SVProgressHUD.showWithMaskType(.Black)
        self.webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func loadHTMLString(content: String) {
        self.webView.loadHTMLString(content, baseURL: nil)
    }
    

    //MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - UIActions
    
    @IBAction func backToHome(sender: AnyObject) {
        SVProgressHUD.dismiss()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
