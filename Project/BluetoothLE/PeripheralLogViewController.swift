//
//  PeripheralLogViewController.swift
//  BluetoothLE
//
//  Created by Mickey Goga on 2/13/18.
//  Copyright © 2018 Juan Cruz Guidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralLogViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var peripheralLogTextView: UITextView!

    var myPeripheral : CBPeripheral!
    
    var manager : CBCentralManager!
    var myCharacteristicFF1 : CBCharacteristic!
    var myCharacteristicFF3 : CBCharacteristic!
    var myCharacteristicFF4 : CBCharacteristic!
    var isMyPeripheralConected = false
    var count : Int = 0
    var peripheralName : String = ""
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        
        switch central.state {
        case .poweredOff:
            msg = "Bluetooth is Off"
        case .poweredOn:
            msg = "Bluetooth is On"
            manager.scanForPeripherals(withServices: nil, options: nil)
        case .unsupported:
            msg = "Not Supported"
        default:
            msg = "😔"
        }
        
        print("STATE: " + msg)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
//        manager.connect(myPeripheral, options: nil)
//        
        print("Loading...")
        peripheralLogTextView.text = ("Loading...")
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//
//////        self.myPeripheral = peripheral     //save peripheral
////        self.myPeripheral.delegate = self
////        manager.connect(myPeripheral, options: nil)
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {



        //you are going to use the name here down here ⇩
        
        if peripheral.name == peripheralName {

            self.myPeripheral = peripheral     //save peripheral
            self.myPeripheral.delegate = self

            manager.stopScan()                          //stop scanning for peripherals
            manager.connect(myPeripheral, options: nil) //connect to my peripheral
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Conected to \(String(describing: myPeripheral.name))")
        peripheralLogTextView.text = ("\nConected to \(String(describing: myPeripheral.name))")
//        print("My Peripheral Conected")
//        peripheralLogTextView.insertText("My Peripheral Conected")
        isMyPeripheralConected = true //when connected change to true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("My Peripheral disconnected")
        peripheralLogTextView.insertText("\nMy Peripheral disconnected")
        isMyPeripheralConected = false //and to false when disconnected
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discover Services")
        print("Services:\(String(describing: peripheral.services)) and error\(String(describing: error))")
        peripheralLogTextView.insertText("\nDiscover Services")
        peripheralLogTextView.insertText("\nServices:\(String(describing: peripheral.services)) and error\(String(describing: error))")
        if let servicePeripheral = peripheral.services as [CBService]! { //get the services of the perifereal
            
            for service in servicePeripheral {
                print("service: \(service)")
                peripheralLogTextView.insertText("\nservice: \(service)")
                //Then look for the characteristics of the services
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]! {
            
            for cc in characterArray {
                print("cc.uuid.uuidString : \(cc.uuid.uuidString)")
                peripheralLogTextView.insertText("\ncc.uuid.uuidString : \(cc.uuid.uuidString)")
                if(cc.uuid.uuidString == "FFF4") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    
                    myCharacteristicFF4 = cc //saved it to send data in another function.
                    if count == 0 {
                        
                        writeValue4()
                    }
                    peripheral.readValue(for: cc) //to read the value of the characteristic
                    
                }
                else if(  cc.uuid.uuidString == "FFF3") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    
                    myCharacteristicFF3 = cc //saved it to send data in another function.
                    if(myCharacteristicFF4 != nil)
                    {
                        writeValue3()
                    }
                    peripheral.readValue(for: cc) //to read the value of the characteristic
                    
                }
                else if(cc.uuid.uuidString == "FFF1") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    
                    myCharacteristicFF1 = cc //saved it to send data in another function.
                    //writeValue()
                    
                    
                    peripheral.readValue(for: cc) //to read the value of the characteristic
                    
                }
                
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid.uuidString == "FFF1") {
            
            let readValue = characteristic.value
            
            let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
            
            print ("read value for UUID \(characteristic.uuid.uuidString)  \(value)")
            peripheralLogTextView.insertText("\nread value for UUID \(characteristic.uuid.uuidString)  \(value)")
            if(myCharacteristicFF3 != nil){
                writeValue3()
            }
            
        }
    }
    
    
    //if you want to send an string you can use this function.
    func writeValue4() {
        
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            
            // let dataToSend: Data = "00201200089950-1".data(using: .utf8)!
            var string : String
            if count == 2 {
                string = "END"
            } else {
                string = "INIT"
                peripheralLogTextView.insertText("\n\n")
            }
            let dataToSend = Data(string.utf8)
            
            myPeripheral.writeValue(dataToSend, for: myCharacteristicFF4, type: CBCharacteristicWriteType.withResponse)    //Writing the data to the peripheral
            print("send value 4---")
            peripheralLogTextView.insertText("\nsend to UUID \(myCharacteristicFF4.uuid.uuidString) --- value:\(string) ")
            if(count == 0){
                writeValue3()
            }
        } else {
            print("Not connected")
            peripheralLogTextView.insertText("\nNot connected")
        }
    }
    //if you want to send an string you can use this function.
    func writeValue3() {
        
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            var string:String = ""
            if( count == 0)
            {
                string = "Start"
                count += 1
            }
            else if (count == 1)
            {
                string="OPEN1"
                count += 1
            }
            // let dataToSend: Data = "00201200089950-1".data(using: .utf8)!
            
            let dataToSend = Data(string.utf8)
//            print ("read value for UUID \(myCharacteristicFF3.uuid.uuidString) ")
//            peripheralLogTextView.insertText("\nread value for UUID \(myCharacteristicFF3.uuid.uuidString) ")
            myPeripheral.writeValue(dataToSend, for: myCharacteristicFF3, type: CBCharacteristicWriteType.withResponse)    //Writing the data to the peripheral
            print ("send value   \(myCharacteristicFF3.uuid.uuidString)  ---\(string)")
            peripheralLogTextView.insertText("\nsend value to UUID \(myCharacteristicFF3.uuid.uuidString)  ---\(string)")
            if (count == 2)
            {
                writeValue4()
            }
            
        } else {
            print("Not connected")
            peripheralLogTextView.insertText("\nNot connected")
        }
    }
    
}
