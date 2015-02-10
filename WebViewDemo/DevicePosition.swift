//
//  DevicePosition.swift
//  stuff
//
//  Created by comps on 2/6/15.
//

import Foundation
import CoreMotion
import CoreLocation

class DevicePosition {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var altitude: Float = 0.0
    var pitch: Float = 0.0
    var roll: Float = 0.0
    var yaw: Float = 0.0
    var hasPosition = false

    func getValues() -> (latitude: Double, longitude: Double, altitude: Float, pitch: Float, roll: Float, yaw: Float) {
        return (latitude, longitude, altitude, pitch, roll, yaw)
    }
     
    func getStringValues() -> (latitude: NSString, longitude: NSString, altitude: NSString, pitch: NSString, roll: NSString, yaw: NSString) {
        return
            (String(format: "%f",latitude),
            String(format: "%f",longitude),
            String(format: "%f",altitude),
            String(format: "%f",pitch),
            String(format: "%f",roll),
            String(format: "%f",yaw))
    }
    
    func setLocation(location: CLLocation?) {
        if (location != nil) {
            self.setLatitude(Double(location!.coordinate.latitude * 1000))
            self.setLongitude(Double(location!.coordinate.longitude * 1000))
            self.setAltitude( Float(location!.altitude))
            self.hasPosition = true
        }
    }
    
    func setPosition(latitude: Double, longitude: Double, altitude: Float)  {
        setLatitude(latitude)
        setLongitude(longitude)
        setAltitude(altitude)
        if !hasPosition {
            setHasPosition(true)
        }
    }
    
    func setAngle(pitch: Float, roll: Float, yaw: Float)  {
        setPitch(pitch)
        setRoll(roll)
        setYaw(yaw)
    }
    
    func setAttitude(attitude: CMAttitude?) {
        if (attitude != nil) {
            self.setPitch(Float(attitude!.pitch))
            self.setRoll(Float(attitude!.roll))
            self.setYaw(Float(attitude!.yaw))
        }
    }
    
    func setLatitude (latitude: Double) {
        self.latitude = latitude
    }
    
    func setLongitude (longitude: Double) {
        self.longitude = longitude
    }
    
    func setAltitude (altitude: Float) {
        self.altitude = altitude
    }
    
    func setPitch (pitch: Float) {
        self.pitch = pitch
    }
    
    func setRoll (roll: Float) {
        self.roll = roll
    }
    
    func setYaw (yaw: Float) {
        self.yaw = yaw
    }
    
    func setHasPosition(hasPosition: Bool) {
        self.hasPosition = hasPosition
    }
    
}
