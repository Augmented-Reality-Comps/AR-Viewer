//
//  ViewController.swift
//  WebViewDemo
//

import UIKit

class ViewController: UIViewController  {
    
    @IBOutlet var webView: UIWebView!
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "http://localhost/~comps/http/http_test2.py?lat=1&long=1&alt=1&dis=10")
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doRefresh(AnyObject) {
        webView.reload()
    }
    
    @IBAction func goBack(AnyObject) {
        webView.stringByEvaluatingJavaScriptFromString("backward(10)")
//        webView.goBack()
    }
    
    @IBAction func goForward(AnyObject) {
        webView.stringByEvaluatingJavaScriptFromString("forward(10)")
//        webView.goForward()
    }
    
    @IBAction func stop(AnyObject) {
        for i in 1...20 {
            webView.stringByEvaluatingJavaScriptFromString("forward(5)")
            usleep(1000)
        }
//        for i in 1...20 {
//            webView.stringByEvaluatingJavaScriptFromString("backward(5)")
//        }
        
//        webView.stopLoading()
    }

}

