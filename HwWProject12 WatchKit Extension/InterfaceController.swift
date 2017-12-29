//
//  InterfaceController.swift
//  HwWProject12 WatchKit Extension
//
//  Created by Skyler Svendsen on 12/28/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var receivedData: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func sendDataTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let data = ["text": "Hello from the watch"]
            session.transferUserInfo(data)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let text = userInfo["text"] as? String {
                self.receivedData.setText(text)
            } else if let number = userInfo["number"] as? String {
                UserDefaults.standard.set(number, forKey: "complication_number")
                
                let server = CLKComplicationServer.sharedInstance()
                guard let complications = server.activeComplications else { return }
                
                for complication in complications {
                    server.reloadTimeline(for: complication)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.receivedData.setText(text)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.receivedData.setText(text)
                
                replyHandler(["response": "Be excellent to each other"])
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Application state received!")
        print(applicationContext)
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("File received!")
        
        let fm = FileManager.default
        let destURL = getDocumentsDirectory().appendingPathComponent("saved_file")
        
        do {
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem(at: destURL)
            }
            
            try fm.copyItem(at: file.fileURL, to: destURL)
            
            let contents = try String(contentsOf: destURL)
            print(contents)
        } catch {
            print("File copy failed.")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}




















