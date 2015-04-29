//
//  ViewController.swift
//

import UIKit
import CoreLocation
import CoreMotion
import AVFoundation
import Darwin

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var refresh = true
    var updateCounter = 0
    var pi = M_PI
        
    var timer = NSTimer()

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    
    var refreshButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var updateButton = UIButton.buttonWithType(UIButtonType.System) as UIButton

    var devicePosition: DevicePosition!
    
    
    //TEST CODE
    //Hardcoded attitude values in testAttitudes (pitch, roll, yaw)
    //Hardcoded location in testCoordinates
    var test = false
    var testAttitudes = [(0.0, 0, 0.0), (0.0, 0.1, 0.0), (0.0, 0.2, 0.0), (0.0, 0.3, 0.0), (0.0, 0.4, 0.0), (0.0, 0.5, 0.0), (0.0, 0.6, 0.0), (0.0, 0.7, 0.0), (0.0, 0.8, 0.0), (0.0, 0.9, 0.0), (0.0, 1.0, 0.0), (0.0, 0.9, 0.0), (0.0, 0.8, 0.0), (0.0, 0.7, 0.0), (0.0, 0.6, 0.0), (0.0, 0.5, 0.0), (0.0, 0.4, 0.0), (0.0, 0.3, 0.0), (0.0, 0.2, 0.0), (0.0, 0.1, 0.0), (0.0, 0.0, 0.0), (0.1, 0.0, 0.0), (0.2, 0.0, 0.0), (0.3, 0.0, 0.0), (0.4, 0.0, 0.0), (0.5, 0.0, 0.0), (0.6, 0.0, 0.0), (0.7, 0.0, 0.0), (0.8, 0.0, 0.0), (0.9, 0.0, 0.0), (1.0, 0.0, 0.0), (1.1, 0.0, 0.0), (1.2, 0.0, 0.0), (1.3, 0.0, 0.0), (1.4, 0.0, 0.0), (1.5, 0.0, 0.0)]
    var testCoordinates = (4446080.0, -9315645.0)
    
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
        
        //Adds refresh button
        refreshButton.frame = CGRectMake(334, 800, 100, 50)
        refreshButton.backgroundColor = UIColor.whiteColor()
        refreshButton.setTitle("Refresh", forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(refreshButton)
        
        //Adds update button
        updateButton.frame = CGRectMake(334, 900, 100, 50)
        updateButton.backgroundColor = UIColor.whiteColor()
        updateButton.setTitle("Update", forState: UIControlState.Normal)
        updateButton.addTarget(self, action: "updateAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(updateButton)
        
        //sets intervals for pulling location data
        let updateSelector : Selector = "update"
        if (!test) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: updateSelector, userInfo: nil, repeats: true)
        }
    }
    
    func printLog() {
        println("\(updateCounter), \(devicePosition.latitude), \(devicePosition.longitude)")
    }
    
    
    func update() {
        // Update device position
        if (test) {
            self.devicePosition.setLatitude(testCoordinates.0)
            self.devicePosition.setLongitude(testCoordinates.1)
            if (updateCounter == testAttitudes.count) {
                updateCounter = 0
            }
            self.devicePosition.setPitch(self.testAttitudes[updateCounter].0)
            self.devicePosition.setRoll(testAttitudes[updateCounter].1)
            self.devicePosition.setYaw(testAttitudes[updateCounter].2)
        }
        else {
            self.devicePosition.setAttitude(self.motionManager.deviceMotion?.attitude)
            self.devicePosition.setLocation(self.locationManager.location)
        }
        
        // Update location labels
        self.latitudeLabel.text = "Latitude: \(devicePosition.latitude)"
        self.longitudeLabel.text = "Longitude: \(devicePosition.longitude)"
        self.altitudeLabel.text = "Altitude: \(devicePosition.altitude)"
        self.angleLabel.text = "Pitch: \(devicePosition.pitch)\nRoll: \(devicePosition.roll)\nYaw: \(devicePosition.yaw)"
        var loc = ""
        
        //nothing hardcoded
        loc = "updateScene(\(self.devicePosition.latitude), \(self.devicePosition.longitude), 285, \(self.devicePosition.pitch), \(self.devicePosition.roll), \(self.devicePosition.yaw + 3.14159/2.0))"

        //println("Updated scene: \(devicePosition.pitch), \(devicePosition.roll), \(devicePosition.yaw)")
        self.updateCounter += 1
        webView.stringByEvaluatingJavaScriptFromString(loc)
    }
    
    func refreshAction(sender:UIButton!) {
        initPage()
    }
    func updateAction(sender:UIButton!) {
        update()
    }
    
    func initManagers() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.motionManager.deviceMotionUpdateInterval = 0.01
        //self.motionManager.startDeviceMotionUpdates()
        self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXMagneticNorthZVertical)
        
        self.locationManager.startUpdatingHeading()
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
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
        captureSession.startRunning()
    }
    
    // Updates on CLLocationManager detect change
    // Checks if the device is currently receiving its position
    // Constructs a string corresponding to a javascript call to updateScene()
    // Executes the javascript call in the webview
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.devicePosition.setLocation(self.locationManager.location)
        if refresh {
            initPage()
        }
    }
    
    // Checks if the device has position information and
    // fetches the html, js, and dae from the server
    func initPage() -> Bool {
        if (devicePosition.hasPosition) {
            var loc = ""
            
            if (devicePosition.getStaticLocation()) {
                //URL for lookaround demo
                loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/lookAround/lookAround.html"
            } else {
                //URL for location based demo
                loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
                loc += "latitude=" + devicePosition.getStringValues().latitude
                loc += "&longitude=" + devicePosition.getStringValues().longitude
                loc += "&altitude=" + devicePosition.getStringValues().altitude
            }
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

