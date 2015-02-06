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
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
        if refresh {
            if let attitude = motionManager.deviceMotion?.attitude? {
                initPage()
            }
            refresh = false
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
        self.view.bringSubviewToFront(angleLabel)
        captureSession.startRunning()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.getMotionData(manager.location)
        initPage()
    }
    
    func initPage() {
        var loc = "http://cmc307-08.mathcs.carleton.edu/~comps/backend/walkAround/webApp.py?"
        //getMotionData(location)
        if devicePosition.initialized {
        loc += "latitude=" + devicePosition.getStringValues().latitude + "&longitude=" + devicePosition.getStringValues().longitude + "&altitude=" + devicePosition.getStringValues().altitude
        
        if let attitude = motionManager.deviceMotion?.attitude? {
            //Accurate Euler angles
            println("before attitude")
            loc += "&pitch=" + devicePosition.getStringValues().pitch
            loc += "&roll=" + devicePosition.getStringValues().roll
            loc += "&yaw=" + devicePosition.getStringValues().yaw
            println("after attitude")
            }
        formatURL(loc)
        println(loc)
        }
    }
    
    func getMotionData(location: CLLocation){
        devicePosition.setLatitude(Float(location.coordinate.latitude * 100000))
        devicePosition.setLongitude(Float(location.coordinate.longitude * 100000))
        devicePosition.setAltitude(Float(location.altitude))
        
        if let attitude = motionManager.deviceMotion?.attitude? {
            devicePosition.setPitch(Float(motionManager.deviceMotion.attitude.pitch))
            devicePosition.setRoll(Float(motionManager.deviceMotion.attitude.roll))
            devicePosition.setYaw(Float(motionManager.deviceMotion.attitude.yaw))
            

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

