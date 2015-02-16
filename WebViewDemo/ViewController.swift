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
    var refresh = true
    var updateCounter = 0
    
    var timer = NSTimer()

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    var Timestamp: String {
        get {
            return "\(NSDate().timeIntervalSince1970 * 1000)"
        }
    }
    
    var refreshButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var devicePosition: DevicePosition!
    
    @IBOutlet var webView: UIWebView!
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManagers()
        
        devicePosition = DevicePosition()
        
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
                        beginSession()
                    }
                }
            }
        }
        
        refreshButton.frame = CGRectMake(334, 800, 100, 50)
        refreshButton.backgroundColor = UIColor.whiteColor()
        refreshButton.setTitle("Refresh", forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(refreshButton)
        
        let updateSelector : Selector = "update"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: updateSelector, userInfo: nil, repeats: true)
        
    }
    
    func printLog() {
        /*
        println("Timestamp: \(Timestamp)")
        println("Latitude: \(devicePosition.latitude)")
        println("Longitude: \(devicePosition.longitude)")
        println("_______")*/
        println("\(updateCounter), \(devicePosition.latitude), \(devicePosition.longitude)")
    }
    
    
    func update() {
        /*
        println("---UPDATING---")
        if (self.updateCounter % 15000 == 0) {
            println("---Refreshing---")
            initPage()
        }
        
        if (self.updateCounter % 6000 == 0) {
            var queried = self.devicePosition.getQueriedValues()
            println("---Refreshing---")
            initPage()
        } */
        
        self.updateCounter += 1
        
        // Update device position
        self.devicePosition.setLocation(self.locationManager.location)
        //println(self.locationManager.location)
        self.devicePosition.setAttitude(self.motionManager.deviceMotion?.attitude)
        
        // Update location labels
        self.latitudeLabel.text = "Latitude: \(devicePosition.latitude)"
        self.longitudeLabel.text = "Longitude: \(devicePosition.longitude)"
        self.altitudeLabel.text = "Altitude: \(devicePosition.altitude)"
        self.angleLabel.text = "Pitch: \(devicePosition.pitch)\nRoll: \(devicePosition.roll)\nYaw: \(devicePosition.yaw)"
        self.counterLabel.text = "Counter: \(self.updateCounter)"
        
        var loc = "updateScene(\(self.devicePosition.latitude), \(self.devicePosition.longitude), \(self.devicePosition.altitude), \(self.devicePosition.pitch), \(self.devicePosition.roll), \(self.devicePosition.yaw))"
        webView.stringByEvaluatingJavaScriptFromString(loc)
        printLog()
    }
    
    func refreshAction(sender:UIButton!) {
        initPage()
    }
    
    func initManagers() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.motionManager.deviceMotionUpdateInterval = 0.01
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
        self.view.bringSubviewToFront(angleLabel)
        self.view.bringSubviewToFront(counterLabel)
        captureSession.startRunning()
    }
    
    // Updates on CLLocationManager detect change
    // Checks if the device is currently receiving its position
    // Constructs a string corresponding to a javascript call to updateScene()
    // Executes the javascript call in the webview
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //self.getMotionData(manager.location)
        self.devicePosition.setLocation(self.locationManager.location)
        if refresh {
            initPage()
        }
    }
    
    // Checks if the device has position information and
    // fetches the html, js, and dae from the server
    // Doesn't need attitude data
    func initPage() -> Bool {
        if (devicePosition.hasPosition) {
            self.devicePosition.setQueriedLocation(self.locationManager.location)
            var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
            loc += "latitude=" + devicePosition.getStringValues().latitude
            loc += "&longitude=" + devicePosition.getStringValues().longitude
            loc += "&altitude=" + devicePosition.getStringValues().altitude
            loc += "&pitch=0&roll=0&yaw=0"
            formatURL(loc)
            refresh = false
            return true
        }
        return false
    }
    
    func formatURL(loc: String){
        let url = NSURL(string: loc)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

