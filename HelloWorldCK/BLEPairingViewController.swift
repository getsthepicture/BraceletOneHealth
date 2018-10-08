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
    var glucoseMeterPeripheral: CBPeripheral!
    let glucoseMeasurementCharacteristicCBUUID = CBUUID.init(string: "2A18")
    //estimote
    let credentials = CloudCredentials(appID: "bracelet-one-02e", appToken: "caaed6d4bd7cad0e03b405cfbd42247b")
    var proximityObserver: ProximityObserver!
    var proximityZone: ProximityZone!
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
            bluetoothStatusLabel.text = "Bluetooth is unknown"
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
            //centralManager.scanForPeripherals(withServices: nil)
            proximityObserver = ProximityObserver(credentials: credentials, onError: { error in
                print("ProximityObserver error: \(error)")
            })
            
            // Define zones
            proximityZone = ProximityZone(tag: "Emory-hospital", range: ProximityRange.near)
            proximityZone.onEnter = { zoneContext in
                print("Entered near range of Emory Hospital Check-In.")
            }
            proximityZone.onExit = { zoneContext in
                print("Exited near range of Emory Hospital Check-In.")
            }
            
            proximityZone.onContextChange = { contexts in
                print("Now in range of \(contexts.count) contexts")
            }
            
            // ... etc. You can define as many zones as you need.
            
            // Start proximity observation
            proximityObserver.startObserving([proximityZone])
            
            centralManager.scanForPeripherals(withServices: [glucoseMeterCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        glucoseMeterPeripheral = peripheral
        glucoseMeterPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(glucoseMeterPeripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to glucose meter!")
        glucoseMeterPeripheral.discoverServices([glucoseMeterCBUUID])
    }
    
}

extension BLEPairingViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
        }
    }
}
