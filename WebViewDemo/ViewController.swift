//
//  ViewController.swift
//  WebViewDemo
//

import UIKit
import CoreLocation
import CoreMotion
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet var webView: UIWebView!
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManagers()
        
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        webView.scrollView.bounces = false;
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }

    }
    
    func initManagers() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.motionManager.deviceMotionUpdateInterval = 0.001
        self.motionManager.startDeviceMotionUpdates()
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Make camera view full screen
        var bounds:CGRect = self.view.layer.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        
        //Overlay webview onto camera view
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(webView)
        self.view.bringSubviewToFront(latitudeLabel)
        self.view.bringSubviewToFront(longitudeLabel)
        self.view.bringSubviewToFront(altitudeLabel)
        captureSession.startRunning()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.getMotionData(manager.location)
    }
    
    func getMotionData(location: CLLocation){
        var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
        
        var latitude = String(format: "%f", location.coordinate.latitude * 100000)
        var longitude = String(format: "%f", location.coordinate.longitude * 100000)
        var altitude = String(format: "%f", location.altitude + 20)
        
        /*
         //Actual latitude, longitude, and altitude values
        loc = loc + "latitude=" + String(format: "%f", self.locationManager.location.coordinate.latitude)
        loc = loc + "&longitude=" + String(format: "%f", self.locationManager.location.coordinate.longitude)
        loc = loc + "&altitude=0"
        */
        
        loc += "latitude=" + latitude + "&longitude=" + longitude  //"&altitude=" + altitude
        loc += "&altitude=" + String(20)

        if let attitude = motionManager.deviceMotion?.attitude? {
            
            //Attitude DIVIDED BY 10 FOR VAGUE SCALING 
            //NEEDS BETTER SCALING MECHANISM
            var pitch = String(format: "%f", Float(motionManager.deviceMotion.attitude.pitch))
            var roll = String(format: "%f", Float(motionManager.deviceMotion.attitude.roll))
            var yaw = String(format: "%f", Float(motionManager.deviceMotion.attitude.yaw))
            
        //Testing Euler URl
            //loc += "&pitch=0&roll=0&yaw=0"
            
         //Accurate Euler angles
            loc += "&pitch=" + pitch
            loc += "&roll=" + roll
            loc += "&yaw=" + yaw

            //Labels for testing
            latitudeLabel.text = "Latitude:" + latitude
            longitudeLabel.text = "Longitude: " + longitude
            altitudeLabel.text = "Altitude: " + altitude
            
            formatURL(loc)
        }
        
        print(longitude)
        print(" ")
        print(latitude)
        print(" ")
        println(altitude)
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

