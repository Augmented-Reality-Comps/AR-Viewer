//
//  DevicePosition.swift
//
//  Created by comps on 2/6/15.
//

import Foundation
import Darwin
import CoreMotion
import CoreLocation

class DevicePosition {
    //Multipliers based on distance at Northfield's coordinates
    //let latMultiplier: Double = 111000
    //let lonMultiplier: Double = 79000
    
    let latMultiplier: Double = 100000
    let lonMultiplier: Double = 100000

    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var altitude: Float = 0.0
    var pitch: Float = 0.0
    var roll: Float = 0.0
    var yaw: Float = 0.0
    var hasPosition = false
    
    //True - location of phone permanently (0,0,0)
    //False - use actual phone data
    var staticLocation = false
    
    var pi = M_PI
    

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
    
    func getStaticLocation() -> (Bool) {
        return staticLocation
    }
    
    func setLocation(location: CLLocation?) {
        if (location != nil) {
            if staticLocation {
                self.setLatitude(0)
                self.setLongitude(0)
                self.setAltitude(0)
            } else {
                self.setLatitude(Double(location!.coordinate.latitude * latMultiplier ))
                self.setLongitude(Double(location!.coordinate.longitude * lonMultiplier))
                self.setAltitude(Float(location!.altitude))
            }
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
