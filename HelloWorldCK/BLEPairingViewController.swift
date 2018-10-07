//
//  BLEPairingViewController.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/7/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import EstimoteProximitySDK

struct Content {
    let title: String
    let subtitle: String
}

class BLEPairingViewController: UIViewController {
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var bodySensorLocationLabel: UILabel!
    @IBOutlet var bluetoothStatusLabel: UILabel!
    var centralManager: CBCentralManager!
    //glucose meter
    let glucoseMeterCBUUID = CBUUID(string: "0x1808")
    //estimote
    let credentials = CloudCredentials(appID: "bracelet-one-02e", appToken: "caaed6d4bd7cad0e03b405cfbd42247b")
    var proximityObserver: ProximityObserver!
    var nearbyContent = [Content]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        
        // Make the digits monospaces to avoid shifting when the numbers change
        //heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
        heartRateLabel.text = String(heartRate)
        print("BPM: \(heartRate)")
    }
}


extension BLEPairingViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            bluetoothStatusLabel.text = "Bluetooth is nknown"
            print("the central state is .unkown")
        case .resetting:
            bluetoothStatusLabel.text = "Bluetooth Resetting"
            print("the central state is .resetting")
        case .unsupported:
            bluetoothStatusLabel.text = "Bluetooh Unsupported"
            print("the central state is .unsupported")
        case .unauthorized:
            bluetoothStatusLabel.text = "Bluetooth Unauthorized"
            print("the central state is .unauthorized")
        case .poweredOff:
            bluetoothStatusLabel.text = "Bluetooth Powered Off"
            print("the central state is .poweredOff")
        case .poweredOn:
            bluetoothStatusLabel.text = "Bluetooth Powered On"
            print("the central state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
            //centralManager.scanForPeripherals(withServices: [glucoseMeterCBUUID])
            
            let proximityObserver = ProximityObserver(credentials: credentials, onError: { error in
                print("ProximityObserver error: \(error)")
            })
            
            // Define zones
            let hospitalZone = ProximityZone(tag: "Emory-hospital", range: ProximityRange.near)
            hospitalZone.onEnter = { zoneContext in
                print("Entered near range of Emory Hospital Check-In.")
            }
            hospitalZone.onExit = { zoneContext in
                print("Exited near range of Emory Hospital Check-In.")
            }
            
            hospitalZone.onContextChange = { contexts in
                print("Now in range of \(contexts.count) contexts")
            }
            
            // ... etc. You can define as many zones as you need.
            
            // Start proximity observation
            proximityObserver.startObserving([hospitalZone])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
    }
    
}
