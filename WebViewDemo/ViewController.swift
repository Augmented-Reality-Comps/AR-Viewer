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
    
    var refresh = true //indicates whether or not page needs to be refreshed
    var timer = NSTimer()

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet var webView: UIWebView!
    
    var refreshButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var updateButton = UIButton.buttonWithType(UIButtonType.System) as UIButton

    var devicePosition: DevicePosition!

    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManagers()
        initWebview()
        initCamera()
        initButtons()
        
        devicePosition = DevicePosition()

        //sets intervals for pulling location data
        let updateSelector : Selector = "update"
        if (!devicePosition.test) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: updateSelector, userInfo: nil, repeats: true)
        }
    }
    
    func update() {
        // Update device position
        devicePosition.setAttitude(motionManager.deviceMotion?.attitude)
        devicePosition.setLocation(locationManager.location)
        
        // Update location labels
        latitudeLabel.text = "Latitude: \(devicePosition.latitude)"
        longitudeLabel.text = "Longitude: \(devicePosition.longitude)"
        altitudeLabel.text = "Altitude: \(devicePosition.altitude)"
        angleLabel.text = "Pitch: \(devicePosition.pitch)\nRoll: \(devicePosition.roll)\nYaw: \(devicePosition.yaw)"
        
        // Send javascript request
        var loc = "updateScene(\(devicePosition.latitude), \(devicePosition.longitude), 285, \(devicePosition.pitch), \(devicePosition.roll), \(devicePosition.yaw))"
        webView.stringByEvaluatingJavaScriptFromString(loc)
    }

    
    func initManagers() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXMagneticNorthZVertical)
    }
    
    // Updates on CLLocationManager detect change
    // Checks if the device is currently receiving its position
    // Constructs a string corresponding to a javascript call to updateScene()
    // Executes the javascript call in the webview
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        devicePosition.setLocation(locationManager.location)
        if refresh {
            initPage()
        }
    }
    
    func initWebview() {
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        webView.scrollView.bounces = false;
    }
    
    func initCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        configureDevice()
                        
                        var err : NSError? = nil
                        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
                        if err != nil {
                            println("error: \(err?.localizedDescription)")
                        }
                        
                        configureCameraView()
                    }
                }
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func configureCameraView() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Make camera view full screen
        var bounds:CGRect = view.layer.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        
        //Overlay webview onto camera view
        view.layer.addSublayer(previewLayer)
        view.bringSubviewToFront(webView)
        view.bringSubviewToFront(latitudeLabel)
        view.bringSubviewToFront(longitudeLabel)
        view.bringSubviewToFront(altitudeLabel)
        view.bringSubviewToFront(angleLabel)
        captureSession.startRunning()
    }
    
    func initButtons() {
        //Adds refresh button
        refreshButton.frame = CGRectMake(334, 800, 100, 50)
        refreshButton.backgroundColor = UIColor.whiteColor()
        refreshButton.setTitle("Refresh", forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(refreshButton)
        
        //Adds update button
        updateButton.frame = CGRectMake(334, 900, 100, 50)
        updateButton.backgroundColor = UIColor.whiteColor()
        updateButton.setTitle("Update", forState: UIControlState.Normal)
        updateButton.addTarget(self, action: "updateAction:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(updateButton)
    }

    
    // Checks if the device has position information and
    // fetches the html, js, and dae from the server
    func initPage() -> Bool {
        if (devicePosition.hasPosition) {
            //URL for location based demo
            var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?\(devicePosition.getStringValues().latitude)&longitude=\(devicePosition.getStringValues().longitude)&altitude=\(devicePosition.getStringValues().altitude)"

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
    
    func refreshAction(sender:UIButton!) {
        initPage()
    }
    
    func updateAction(sender:UIButton!) {
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

