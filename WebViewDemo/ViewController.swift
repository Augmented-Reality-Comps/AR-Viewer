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

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
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
        
    }
    
    func refreshAction(sender:UIButton!) {
        initPage()
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
        self.view.bringSubviewToFront(angleLabel)
        captureSession.startRunning()
    }
    
    // Updates on CLLocationManager detect change
    // Checks if the device is currently receiving its position
    // Constructs a string corresponding to a javascript call to updateScene()
    // Executes the javascript call in the webview
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.getMotionData(manager.location)
        if refresh {
            initPage()
        }
        if devicePosition.hasPosition {
            var toRun = "updateScene("
            toRun += devicePosition.getStringValues().latitude
            toRun += ", " + devicePosition.getStringValues().longitude
            toRun += ", " + devicePosition.getStringValues().altitude
            toRun += ", " + devicePosition.getStringValues().pitch
            toRun += ", " + devicePosition.getStringValues().roll
            toRun += ", " + devicePosition.getStringValues().yaw
            toRun += ")"
//            toRun = "updateScene(4446248.0, -9315378.0, 290"
//            toRun += ", " + devicePosition.getStringValues().pitch
//            toRun += ", " + devicePosition.getStringValues().roll
//            toRun += ", " + devicePosition.getStringValues().yaw
//            toRun += ")"
            
            webView.stringByEvaluatingJavaScriptFromString(toRun)
        }
    }
    
    
    // Checks if the device has position information and
    // fetches the html, js, and dae from the server
    // Doesn't need attitude data
    func initPage() {
        if (devicePosition.hasPosition) {
            var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
            loc += "latitude=" + devicePosition.getStringValues().latitude
            loc += "&longitude=" + devicePosition.getStringValues().longitude
            loc += "&altitude=" + devicePosition.getStringValues().altitude
            loc += "&pitch=0&roll=0&yaw=0"
            println(loc)
            formatURL(loc)
            refresh = false
        }
    }
    
    // Updates the devicePosition object with current values of lat, long, alt, pitch, roll, and yaw
    func getMotionData(location: CLLocation){
        devicePosition.setPosition(Float(location.coordinate.latitude * 100000), longitude: Float(location.coordinate.longitude * 100000), altitude: Float(location.altitude))
        
        if let attitude = motionManager.deviceMotion?.attitude? {
            devicePosition.setAngle(Float(motionManager.deviceMotion.attitude.pitch), roll: Float(motionManager.deviceMotion.attitude.roll), yaw: Float(motionManager.deviceMotion.attitude.yaw))
            
            //Labels
            latitudeLabel.text = "Latitude: "+devicePosition.getStringValues().latitude
            longitudeLabel.text = "Longitude: "+devicePosition.getStringValues().longitude
            altitudeLabel.text = "Altitude: "+devicePosition.getStringValues().altitude
            angleLabel.text = "Pitch: "+devicePosition.getStringValues().pitch+"\nRoll: "+devicePosition.getStringValues().roll+"\nYaw: "+devicePosition.getStringValues().yaw
        }
    }
    
    func formatURL(loc: String){
        let url = NSURL(string: loc)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {         super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

