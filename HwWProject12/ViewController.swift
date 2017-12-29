//
//  ViewController.swift
//  HwWProject12
//
//  Created by Skyler Svendsen on 12/28/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    @IBOutlet var receivedData: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let complication = UIBarButtonItem(title: "Complication", style: .plain, target: self, action: #selector(sendComplicationTapped))
        let message = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(sendMessageTapped))
        let appInfo = UIBarButtonItem(title: "Context", style: .plain, target: self, action: #selector(sendAppContextTapped))
        let file = UIBarButtonItem(title: "File", style: .plain, target: self, action: #selector(sendFileTapped))
        
        navigationItem.leftBarButtonItems = [complication, message, appInfo, file]
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendMessageTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let data = ["text": "User info from the phone"]
            session.transferUserInfo(data)
        }
        
        if session.isReachable {
            let data = ["text": "A message from the phone"]
            session.sendMessage(data, replyHandler: { response in
                self.receivedData.text = "Received response: \(response)"
            })
        }
    }
    
    @objc func sendAppContextTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let data = ["text": "Hello from the phone"]
            
            do {
                try session.updateApplicationContext(data)
            } catch {
                print("Alert! Updating app context failed")
            }
        }
    }
    
    @objc func sendComplicationTapped() {
        
    }
    
    @objc func sendFileTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let fm = FileManager.default
            let sourceURL = getDocumentsDirectory().appendingPathComponent("saved_file")
            
            if !fm.fileExists(atPath: sourceURL.path) {
                try? "Hello, from a phone file!".write(to: sourceURL, atomically: true, encoding: String.Encoding.utf8)
            }
            
            session.transferFile(sourceURL, metadata: nil)
        }
    }
    
    //wcsession methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedData.text = "Watch app is installed!"
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        let session = WCSession.default
        
        if session.activationState == .activated && session.isComplicationEnabled {
            let randomNumber = String(arc4random_uniform(10))
            let message = ["number": randomNumber]
            
            session.transferCurrentComplicationUserInfo(message)
            
            print("Attempted to send complication data. Remaining transfers: \(session.remainingComplicationUserInfoTransfers)")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //if supporting multiple apple watches per user
        //WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let text = userInfo["text"] as? String {
                self.receivedData.text = text
            }
        }
    }

}

