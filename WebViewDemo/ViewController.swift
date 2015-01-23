//
//  ViewController.swift
//  WebViewDemo
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var yawLabel: UILabel!
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
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.getMotionData(manager.location)
    }
    
    func getMotionData(location: CLLocation){
        var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
        
        //Latitude and longitude specifically for at the desk
        var latitude = String(format: "%f", location.coordinate.latitude-44.462582)
        var longitude = String(format: "%f", location.coordinate.longitude+93.153518)
        var altitude = String(format: "%f", location.altitude - 286.05 + 1)
        
        /* //Actual latitude, longitude, and altitude values
        loc = loc + "lattitude=" + String(format: "%f", self.locationManager.location.coordinate.latitude)
        loc = loc + "&longitude=" + String(format: "%f", self.locationManager.location.coordinate.longitude)
        loc = loc + "&altitude=" + String(format: "%f", self.locationManager.location.altitude)
        loc += "latitude=" + latitude + "&longitude=" + longitude + "&altitude=" + altitude
        */
        
        //Testing latitude, longitude, altitude URL
        loc += "latitude=0&longitude=0&altitude=10"

        
        if let attitude = motionManager.deviceMotion?.attitude? {
            
            //Attitude DIVIDED BY 10 FOR VAGUE SCALING 
            //NEEDS BETTER SCALING MECHANISM
            var pitch = String(format: "%f", Float(motionManager.deviceMotion.attitude.pitch)/10)
            var roll = String(format: "%f", Float(motionManager.deviceMotion.attitude.roll)/10)
            var yaw = String(format: "%f", Float(motionManager.deviceMotion.attitude.yaw)/10)
            
            //Testing Euler URl
            //loc += "&pitch=0&roll=0&yaw=0"
            
         //Accurate Euler angles
            loc += "&pitch=" + pitch
            loc += "&roll=" + roll
            loc += "&yaw=" + yaw
            
           /* //Labels for testing
            
            pitchLabel.text = "Pitch: " + pitch
            rollLabel.text = "Roll: " + roll
            yawLabel.text = "Yaw: " + yaw
            */
            formatURL(loc)
        }
        
        println(loc)
    }
    
    func formatURL(loc: String){
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
    

}

