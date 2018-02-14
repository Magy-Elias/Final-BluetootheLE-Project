//
//  ViewController.swift
//  BluetoothLE
//  iOS 10
//
//  Created by Juan Cruz Guidi on 16/10/16.
//  Copyright © 2016 Juan Cruz Guidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {

    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristicFF1 : CBCharacteristic!
    var myCharacteristicFF3 : CBCharacteristic!
    var myCharacteristicFF4 : CBCharacteristic!
    var isMyPeripheralConected = false
    var count : Int = 0
//    var devices = [String: [String : String]] ()
    
    var devices : Dictionary<String, CBPeripheral> = [:]
    var deviceName: String?
    var devicesRSSI = [NSNumber]()
    
//    var peripherals = Array<CBPeripheral>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
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
    
    func centralManager(_ central: CBCentralManager?, didDiscover peripheral: CBPeripheral?, advertisementData: [String : Any], rssi RSSI: NSNumber) {

//        if let name = peripheral.name {
//            items[name] = ["name" : peripheral.name!]
//            print("Name: \(String(describing: name))") //print the names of all peripherals connected.
//            peripherals.append(peripheral)
//        }
//        self.tableView.reloadData()
        
        if let manager = central {
            if let peripheral = peripheral {
                // Get this device's UUID.
                if let name = peripheral.name{
                    if(devices[name] == nil){
                        devices[name] = peripheral
                        devicesRSSI.append(RSSI)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        //you are going to use the name here down here ⇩

//        if peripheral.name == "'OPENLOCK\'" { //if is it my peripheral, then connect

//            self.myBluetoothPeripheral = peripheral     //save peripheral
//            self.myBluetoothPeripheral.delegate = self

//            manager.stopScan()                          //stop scanning for peripherals
//            manager.connect(myBluetoothPeripheral, options: nil) //connect to my peripheral

//        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("My Peripheral Conected")
        isMyPeripheralConected = true //when connected change to true
        peripheral.delegate = self
//        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
     print("My Peripheral disconnected")
        isMyPeripheralConected = false //and to false when disconnected
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discover Services")
        print("Services:\(String(describing: peripheral.services)) and error\(String(describing: error))")
        if let servicePeripheral = peripheral.services as [CBService]! { //get the services of the perifereal
         
            for service in servicePeripheral {
                 print("service: \(service)")
                //Then look for the characteristics of the services
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]! {
            
            for cc in characterArray {
                  print("cc.uuid.uuidString : \(cc.uuid.uuidString)")
                if(cc.uuid.uuidString == "FFF4") { //properties: read, write
                                                   //if you have another BLE module, you should print or look for the characteristic you need.
                    
                    myCharacteristicFF4 = cc //saved it to send data in another function.
                    writeValue4()
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
            if(myCharacteristicFF3 != nil){
               writeValue3()
            }
          
        }
    }
    
    
    //if you want to send an string you can use this function.
    func writeValue4() {
        
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            
           // let dataToSend: Data = "00201200089950-1".data(using: .utf8)!
            let string = "0"
            let dataToSend = Data(string.utf8)
            
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristicFF4, type: CBCharacteristicWriteType.withResponse)    //Writing the data to the peripheral
             print ("send value 4---")
            if(count == 0){
            writeValue3()
            }
        } else {
            print("Not connected")
        }
    }
    //if you want to send an string you can use this function.
    func writeValue3() {
      
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            var string:String = ""
            if( count == 0)
            {
                string = "data"
                count += 1
            }
        else if (count == 1)
            {
                string="OPEN1"
            }
            // let dataToSend: Data = "00201200089950-1".data(using: .utf8)!
           
            let dataToSend = Data(string.utf8)
             print ("read value for UUID \(myCharacteristicFF3.uuid.uuidString) ")
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristicFF3, type: CBCharacteristicWriteType.withResponse)    //Writing the data to the peripheral
            print ("send value 3 ---\(string)")
            if (count == 1)
            {
                writeValue4()
            }
            
        } else {
            print("Not connected")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.devices.keys.count
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
//
//        // Configure the cell...
//        if let item = itemForIndexPath(indexPath){
//            cell.textLabel?.text = item["name"] as? String
//
//            if let rssi = item["rssi"] as? Int {
//                cell.detailTextLabel?.text = "\(rssi.description) dBm"
//            } else {
//                cell.detailTextLabel?.text = ""
//            }
//        }
//
//        return cell
        
        
        // Let's get a cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? UITableViewCell
        // Turn the device dictionary into an array.
        let discoveredPeripheralArray = Array(devices.keys)
        //print(discoveredPeripheralArray.count)
        
        // Set the main label of the cell to the name of the corresponding peripheral.
        if let cell = cell{
            if let name = discoveredPeripheralArray[indexPath.row] as? String {
                if let textLabelText = cell.textLabel{
                    textLabelText.text = name
                }
                if let detailTextLabel = cell.detailTextLabel{
                    detailTextLabel.text = devicesRSSI[indexPath.row].stringValue
                }
            }
        }
        return cell!
    }
    
//    func itemForIndexPath(_ indexPath: IndexPath) -> [String: Any]?{
//
//        if indexPath.row > devices.keys.count{
//            return nil
//        }
//
//
//        return Array(devices.values)[indexPath.row]
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        manager.stopScan()                          //stop scanning for peripherals
        
//       // if segue.identifier == "ShowPeripheralLog" {
            //create reference to the 2nd view controller
            //            let secondVC = segue.destination as! PeripheralLogViewController
            //            secondVC.myPeripheral = myBluetoothPeripheral
        
//        let index = indexPath.row
//        let peripheralChoosen = self.peripherals[index]
//        performSegue(withIdentifier: "PeripheralLogViewController", sender: peripheralChoosen)
//            let secondVC:PeripheralLogViewController = self.storyboard?.instantiateViewController(withIdentifier: "PeripheralLogViewController") as! PeripheralLogViewController
//            secondVC.myPeripheral = peripherals[indexPath.row]
//            self.navigationController?.pushViewController(secondVC, animated: true)
     //   }
        
        if (devices.count > 0){
            // Get an array of peripherals.
            let discoveredPeripheralArray = Array(devices.values)
            print(discoveredPeripheralArray)
            // Set the peripheralDevice to the corresponding row selected.
            myBluetoothPeripheral = discoveredPeripheralArray[indexPath.row] as? CBPeripheral
            print(myBluetoothPeripheral)
            
            // Attach the peripheral delegate.
            if let myBluetoothPeripheral = myBluetoothPeripheral {
//                myBluetoothPeripheral.delegate = self
                deviceName = myBluetoothPeripheral.name!
            }
            else {
                deviceName = " "
            }
            
            if let manager = manager {
                // Stop looking for more peripherals.
                manager.stopScan()
                // Connect to this peripheral.
//                manager.connect(myBluetoothPeripheral, options: nil)
                
                
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PeripheralLogViewController") as! PeripheralLogViewController
                secondViewController.peripheralName = deviceName!
//                secondViewController.myPeripheral = myBluetoothPeripheral
                navigationController?.pushViewController(secondViewController, animated: true)
                
                
            }
        }
    }
}

