//
//  ViewController.swift
//  WebViewDemo
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet var webView: UIWebView!
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.motionManager.deviceMotionUpdateInterval = 0.001
        self.motionManager.startDeviceMotionUpdates()

        var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
        
        loc = loc + "lat=" + String(format: "%f", self.locationManager.location.coordinate.latitude)
        loc = loc + "&long=" + String(format: "%f", self.locationManager.location.coordinate.longitude)
        loc = loc + "&alt=" + String(format: "%f", self.locationManager.location.altitude)
        
        if let attitude = motionManager.deviceMotion?.attitude? {
            loc += String(format: "%i", Int(motionManager.deviceMotion.attitude.pitch))
            loc += String(format: "%i", Int(motionManager.deviceMotion.attitude.roll))
            loc += String(format: "%i", Int(motionManager.deviceMotion.attitude.yaw))
        }

        println(loc)
        let url = NSURL(string: loc)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)

    }
    
    override func didReceiveMemoryWarning() {         super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goLeft() {
        println("LEFT")
        webView.stringByEvaluatingJavaScriptFromString("goLeft(.1)")
    }
    
    @IBAction func goRight() {
        println("RIGHT")
        webView.stringByEvaluatingJavaScriptFromString("goRight(.1)")
    }
    
    @IBAction func goForward() {
        println("FORWARD")
        webView.stringByEvaluatingJavaScriptFromString("changeY(.1)")
    }
    
    @IBAction func goBackward() {
        println("BACKWARD")
        webView.stringByEvaluatingJavaScriptFromString("changeY(.-1)")
    }
    
//    @IBAction func angleRight(AnyObject) {
//        webView.stringByEvaluatingJavaScriptFromString("angleRight(10)")
//    }
//    
//    @IBAction func angleLeft(AnyObject) {
//        webView.stringByEvaluatingJavaScriptFromString("angleLeft(10)")
//    }
    
    //490 078

}

