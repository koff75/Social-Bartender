//
//  BluetoothManager.swift
//  Social Bartender
//
//  Created by nico on 06/01/2016.
//  Copyright © 2016 Nicolas Barthere. All rights reserved.
//  -- Bluetooth de type nRF8001

import Foundation
import CoreBluetooth


public enum ConnectionMode {
    case None
    case PinIO
    case UART
}

public enum ConnectionStatus {
    case Disconnected
    case Scanning
    case Connected
}



/*!
*  @class NRFManager
*
*  @discussion Manager des connexions du nRF8001.
*
*/

// Mark: Initialisation NRFManager
public class NRFManager:NSObject, CBCentralManagerDelegate, UARTPeripheralDelegate {
    
    
    //Private Properties
    private var bluetoothManager:CBCentralManager!
    private var currentPeripheral: UARTPeripheral? {
        didSet {
            if let p = currentPeripheral {
                p.verbose = self.verbose
            }
        }
    }
    
    //Public Properties
    public var verbose = false
    public var autoConnect = true
    public var delegate:NRFManagerDelegate?
    
    //callbacks
    public var connectionCallback:(()->())?
    public var disconnectionCallback:(()->())?
    public var dataCallback:((data:NSData?, string:String?)->())?
    
    public private(set) var connectionMode = ConnectionMode.None
    public private(set) var connectionStatus:ConnectionStatus = ConnectionStatus.Disconnected {
        didSet {
            if connectionStatus != oldValue {
                switch connectionStatus {
                case .Connected:
                    
                    connectionCallback?()
                    delegate?.nrfDidConnect?(self)
                    
                default:
                    
                    disconnectionCallback?()
                    delegate?.nrfDidDisconnect?(self)
                }
            }
        }
    }
    
    
    
    
    
    
    public class var sharedInstance : NRFManager {
        struct Static {
            static let instance : NRFManager = NRFManager()
        }
        return Static.instance
    }
    
    public init(delegate:NRFManagerDelegate? = nil, onConnect connectionCallback:(()->())? = nil, onDisconnect disconnectionCallback:(()->())? = nil, onData dataCallback:((data:NSData?, string:String?)->())? = nil, autoConnect:Bool = true)
    {
        super.init()
        self.delegate = delegate
        self.autoConnect = autoConnect
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        self.connectionCallback = connectionCallback
        self.disconnectionCallback = disconnectionCallback
        self.dataCallback = dataCallback
    }
    
}

// MARK: - Private Methods
extension NRFManager {
    
    private func scanForPeripheral()
    {
        let connectedPeripherals = bluetoothManager.retrieveConnectedPeripheralsWithServices([UARTPeripheral.uartServiceUUID()])
        
        if connectedPeripherals.count > 0 {
            log("Déjà connecté ...")
            connectPeripheral(connectedPeripherals[0] as CBPeripheral)
        } else {
            log("Scan des périphériques")
            bluetoothManager.scanForPeripheralsWithServices([UARTPeripheral.uartServiceUUID()], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        }
    }
    
    private func connectPeripheral(peripheral:CBPeripheral) {
        log("Connexion au périphérique: \(peripheral)")
        
        bluetoothManager.cancelPeripheralConnection(peripheral)
        
        currentPeripheral = UARTPeripheral(peripheral: peripheral, delegate: self)
        
        bluetoothManager.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:false])
    }
    
    private func alertBluetoothPowerOff() {
        log("Bluetooth éteint");
        disconnect()
    }
    
    private func alertFailedConnection() {
        log("Impossible de se connecter");
    }
    
    private func log(logMessage: String) {
        if (verbose) {
            print("NRFManager: \(logMessage)")
        }
    }
}

// MARK: - Public Methods
extension NRFManager {
    
    public func connect() {
        if currentPeripheral != nil && connectionStatus == .Connected {
            log("Demande de connexion, mais déjà connecté!")
            return
        }
        
        scanForPeripheral()
    }
    
    public func disconnect()
    {
        if currentPeripheral == nil {
            log("Demande de déconnexion, mais pas de connexion active!")
            return
        }
        
        log("Déconnexion ...")
        bluetoothManager.cancelPeripheralConnection((currentPeripheral?.peripheral)!)
    }
    
    public func writeString(string:String) -> Bool
    {
        if let currentPeripheral = self.currentPeripheral {
            if connectionStatus == .Connected {
                currentPeripheral.writeString(string)
                return true
            }
        }
        log("Ne peut envoyer la chaine. Pas de connexion!")
        return false
    }
    
    public func writeData(data:NSData) -> Bool
    {
        if let currentPeripheral = self.currentPeripheral {
            if connectionStatus == .Connected {
                currentPeripheral.writeRawData(data)
                return true
            }
        }
        log("Ne peut envoyer la donnée. Pas de connexion!")
        return false
    }
    
}

// MARK: - CBCentralManagerDelegate Methods
extension NRFManager {
    
    public func centralManagerDidUpdateState(central: CBCentralManager)
    {
        log("-- Manageur Bluetooth --")
        if central.state == .PoweredOn {
            //respond to powered on
            log("Allumé!")
            if (autoConnect) {
                connect()
            }
            
        } else if central.state == .PoweredOff {
            log("Eteint!")
            connectionStatus = ConnectionStatus.Disconnected
            connectionMode = ConnectionMode.None
        }
    }
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        log("Découverte de périphérique: \(peripheral.name)")
        bluetoothManager.stopScan()
        connectPeripheral(peripheral)
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        log("Connexion:")
        if currentPeripheral?.peripheral == peripheral {
            if (peripheral.services) != nil {
                log("Vers un périphérique existant: \(peripheral.name)")
                currentPeripheral?.peripheral(peripheral, didDiscoverServices: nil)
            } else {
                log("Vers une connexion périphérique: \(peripheral.name)")
                currentPeripheral?.didConnect()
            }
        }
    }
    
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        log("Périphérique déconnecté: \(peripheral.name)")
        
        if currentPeripheral?.peripheral == peripheral {
            connectionStatus = ConnectionStatus.Disconnected
            connectionMode = ConnectionMode.None
            currentPeripheral = nil
        }
        
        if autoConnect {
            connect()
        }
    }
    
    //optional func centralManager(central: CBCentralManager!, willRestoreState dict: [NSObject : AnyObject]!)
    //optional func centralManager(central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!)
    //optional func centralManager(central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!)
    //optional func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!)
}

// MARK: - UARTPeripheralDelegate Methods
extension NRFManager {
    
    public func didReceiveData(newData:NSData)
    {
        if connectionStatus == .Connected || connectionStatus == .Scanning {
            log("Donnée: \(newData)");
            
            let string = NSString(data: newData, encoding:NSUTF8StringEncoding)
            log("Chaîne: \(string)")
            
            dataCallback?(data: newData, string: string! as String)
            delegate?.nrfReceivedData?(self, data:newData, string: string! as String)
            
        }
    }
    
    public func didReadHardwareRevisionString(string:String)
    {
        log("HW Revision: \(string)")
        connectionStatus = .Connected
    }
    
    public func uartDidEncounterError(error:String)
    {
        log("Erreur: Erreur")
    }
    
}


// MARK: NRFManagerDelegate Definition
@objc public protocol NRFManagerDelegate {
    optional func nrfDidConnect(nrfManager:NRFManager)
    optional func nrfDidDisconnect(nrfManager:NRFManager)
    optional func nrfReceivedData(nrfManager:NRFManager, data:NSData?, string:String?)
}


/*!
*  @class UARTPeripheral
*
*  @discussion The peripheral object used by NRFManager.
*
*/

// MARK: UARTPeripheral Initialization
public class UARTPeripheral:NSObject, CBPeripheralDelegate {
    
    private var peripheral:CBPeripheral
    private var uartService:CBService?
    private var rxCharacteristic:CBCharacteristic?
    private var txCharacteristic:CBCharacteristic?
    
    private var delegate:UARTPeripheralDelegate
    private var verbose = false
    
    private init(peripheral:CBPeripheral, delegate:UARTPeripheralDelegate)
    {
        
        self.peripheral = peripheral
        self.delegate = delegate
        
        super.init()
        
        self.peripheral.delegate = self
    }
}

// MARK: Private Methods
extension UARTPeripheral {
    
    private func compareID(firstID:CBUUID, toID secondID:CBUUID)->Bool {
        return firstID.UUIDString == secondID.UUIDString
        
    }
    
    private func setupPeripheralForUse(peripheral:CBPeripheral)
    {
        log("Configuration du périphérique:");
        if let services = peripheral.services {
            for service:CBService in services {
                if let characteristics = service.characteristics {
                    for characteristic:CBCharacteristic in characteristics {
                        if compareID(characteristic.UUID, toID: UARTPeripheral.rxCharacteristicsUUID()) {
                            log("RX caractéristiques trouvées")
                            rxCharacteristic = characteristic
                            peripheral.setNotifyValue(true, forCharacteristic: rxCharacteristic!)
                        } else if compareID(characteristic.UUID, toID: UARTPeripheral.txCharacteristicsUUID()) {
                            log("TX caractéristiques trouvées")
                            txCharacteristic = characteristic
                        } else if compareID(characteristic.UUID, toID: UARTPeripheral.hardwareRevisionStringUUID()) {
                            log("Caractéristiques matériels trouvées")
                            peripheral.readValueForCharacteristic(characteristic)
                        }
                    }
                }
            }
        }
    }
    
    private func log(logMessage: String) {
        if (verbose) {
            // Port Série pour transmettre les données
            print("UARTPeriphérique: \(logMessage)")
        }
    }
    
    private func didConnect()
    {
        log("Connexion:")
        if peripheral.services != nil {
            log("Pas de découverte du périphérique: \(peripheral.name)")
            peripheral(peripheral, didDiscoverServices: nil)
            return
        }
        
        log("Début de la découverte du périphérique: \(peripheral.name)")
        peripheral.discoverServices([UARTPeripheral.uartServiceUUID(), UARTPeripheral.deviceInformationServiceUUID()])
    }
    
    private func writeString(string:String)
    {
        log("Ecriture chaine: \(string)")
        let data = NSData(bytes: string, length: string.characters.count)
        writeRawData(data)
    }
    
    private func writeRawData(data:NSData)
    {
        log("Ecriture donnée: \(data)")
        
        if let txCharacteristic = self.txCharacteristic {
            
            if txCharacteristic.properties.intersect(.WriteWithoutResponse) != [] {
                peripheral.writeValue(data, forCharacteristic: txCharacteristic, type: .WithoutResponse)
            } else if txCharacteristic.properties.intersect(.Write) != [] {
                peripheral.writeValue(data, forCharacteristic: txCharacteristic, type: .WithResponse)
            } else {
                log("Pas de d'écriture sur TX: \(txCharacteristic.properties)")
            }
            
        }
    }
}

// MARK: CBPeripheral Delegate methods
extension UARTPeripheral {
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error:NSError?) {
        
        if error == nil {
            if let services = peripheral.services {
                for service:CBService in services {
                    if service.characteristics != nil {
                        //var e = NSError()
                        //peripheral(peripheral, didDiscoverCharacteristicsForService: s, error: e)
                    } else if compareID(service.UUID, toID: UARTPeripheral.uartServiceUUID()) {
                        log("Service valide trouvé")
                        uartService = service
                        peripheral.discoverCharacteristics([UARTPeripheral.txCharacteristicsUUID(),UARTPeripheral.rxCharacteristicsUUID()], forService: uartService!)
                    } else if compareID(service.UUID, toID: UARTPeripheral.deviceInformationServiceUUID()) {
                        peripheral.discoverCharacteristics([UARTPeripheral.hardwareRevisionStringUUID()], forService: service)
                    }
                }
            }
        } else {
            log("Erreur découverte caractéristiques: \(error)")
            delegate.uartDidEncounterError("Erreur découverte services")
            return
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        if error  == nil {
            log("Découverte caractéristiques pour le service: \(service.description)")
            if let services = peripheral.services {
                let s = services[services.count - 1]
                if compareID(service.UUID, toID: s.UUID) {
                    setupPeripheralForUse(peripheral)
                }
            }
        } else {
            log("Erreur découverte caractéristiques: \(error)")
            delegate.uartDidEncounterError("Erreur découverte caractéristiques")
            return
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        log("Mise à jours des caractéristiques")
        if error == nil {
            if characteristic == rxCharacteristic {
                if let value = characteristic.value {
                    log("Recu: \(value)")
                    delegate.didReceiveData(value)
                }
            } else if compareID(characteristic.UUID, toID: UARTPeripheral.hardwareRevisionStringUUID()){
                log("Lecture matériel chaine")
                // FIX ME: This is not how the original thing worked.
                delegate.didReadHardwareRevisionString(NSString(CString:characteristic.description, encoding: NSUTF8StringEncoding)! as String)
                
            }
        } else {
            log("Erreur de réception de notification pour la caractéristique: \(error)")
            delegate.uartDidEncounterError("Erreur de réception de notification")
            return
        }
    }
}

// MARK: Class Methods
extension UARTPeripheral {
    class func uartServiceUUID() -> CBUUID {
        return CBUUID(string:"6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    }
    
    class func txCharacteristicsUUID() -> CBUUID {
        return CBUUID(string:"6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    }
    
    class func rxCharacteristicsUUID() -> CBUUID {
        return CBUUID(string:"6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    }
    
    class func deviceInformationServiceUUID() -> CBUUID{
        return CBUUID(string:"180A")
    }
    
    class func hardwareRevisionStringUUID() -> CBUUID{
        return CBUUID(string:"2A27")
    }
}

// MARK: UARTPeripheralDelegate Definition
private protocol UARTPeripheralDelegate {
    func didReceiveData(newData:NSData)
    func didReadHardwareRevisionString(string:String)
    func uartDidEncounterError(error:String)
}




