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
    //TEST CODE
    //Hardcoded attitude values in testAttitudes (pitch, roll, yaw)
    //Hardcoded location in testCoordinates
    var test = false
    var testAttitudes = [(0.0, 0, 0.0), (0.0, 0.1, 0.0), (0.0, 0.2, 0.0), (0.0, 0.3, 0.0), (0.0, 0.4, 0.0), (0.0, 0.5, 0.0), (0.0, 0.6, 0.0), (0.0, 0.7, 0.0), (0.0, 0.8, 0.0), (0.0, 0.9, 0.0), (0.0, 1.0, 0.0), (0.0, 0.9, 0.0), (0.0, 0.8, 0.0), (0.0, 0.7, 0.0), (0.0, 0.6, 0.0), (0.0, 0.5, 0.0), (0.0, 0.4, 0.0), (0.0, 0.3, 0.0), (0.0, 0.2, 0.0), (0.0, 0.1, 0.0), (0.0, 0.0, 0.0), (0.1, 0.0, 0.0), (0.2, 0.0, 0.0), (0.3, 0.0, 0.0), (0.4, 0.0, 0.0), (0.5, 0.0, 0.0), (0.6, 0.0, 0.0), (0.7, 0.0, 0.0), (0.8, 0.0, 0.0), (0.9, 0.0, 0.0), (1.0, 0.0, 0.0), (1.1, 0.0, 0.0), (1.2, 0.0, 0.0), (1.3, 0.0, 0.0), (1.4, 0.0, 0.0), (1.5, 0.0, 0.0)]
    var testCoordinates = (4446080.0, -9315645.0)
    
    let latMultiplier: Double = 100000
    let lonMultiplier: Double = 100000

    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var altitude: Float = 0.0
    var pitch: Float = 0.0
    var roll: Float = 0.0
    var yaw: Float = 0.0
    var hasPosition = false
    var updateCounter = 0

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
        if (test) {
            setLatitude(testCoordinates.0)
            setLongitude(testCoordinates.1)
            setAltitude(285)
            hasPosition = true
        }else if (location != nil) {
                setLatitude(Double(location!.coordinate.latitude * latMultiplier ))
                setLongitude(Double(location!.coordinate.longitude * lonMultiplier))
                setAltitude(Float(location!.altitude))
            self.hasPosition = true
        }
    }
    
    func setAttitude(attitude: CMAttitude?) {
        if (test) {
            setPitch(testAttitudes[updateCounter].0)
            setRoll(testAttitudes[updateCounter].1)
            setYaw(testAttitudes[updateCounter].2)
            updateCounter += 1
            if (updateCounter == testAttitudes.count) {
                updateCounter = 0
            }
        }else if (attitude != nil) {
            setPitch(Float(attitude!.pitch))
            setRoll(Float(attitude!.roll))
            setYaw(Float(attitude!.yaw) + 3.14159/2.0)
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
    
    func setPitch (pitch: Double) {
        
        self.pitch = Float(pitch)
    }
    
    func setRoll (roll: Double) {
        self.roll = Float(roll)
    }
    
    func setYaw (yaw: Double) {
        self.yaw = Float(yaw)
    }
    
    func setHasPosition(hasPosition: Bool) {
        self.hasPosition = hasPosition
    }
}
