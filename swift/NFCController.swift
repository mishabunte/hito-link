//
//  NFCViewController.swift
//

import CoreNFC
import SwiftUI


class NFCController: NSObject, NFCNDEFReaderSessionDelegate {
    
    static var shared = NFCController()
    
    struct HitoNfcRequest {
        
        enum HitoNfcRequestType {
            case signEvmTransaction
            case signExpertMode
            case requestUtxoAddress
        }
        
        let type              : HitoNfcRequestType
        let payload           : String
        var isDataTransmitted : Bool               = false
    }
    
    var completion : ((String?) -> Void)?
    
    var txraw: String? // ?
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        //
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.completion?(self.hitoNfcRequest.isDataTransmitted ? self.txraw : nil)
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        //
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        
        let payload = NFCNDEFPayload(format: NFCTypeNameFormat.nfcWellKnown,
                                     type: Data(_: [0x54]), identifier: Data(),
                                     payload: hitoNfcRequest.payload.data(using: .utf8)!)

        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Hito Device protocol is invalid.")
            return
        }
        let currentTag = tags.first!

        session.connect(to: currentTag) { error in

            guard error == nil else {
                session.invalidate(errorMessage: "Could not connect to Hito Wallet.")
                return
            }

            currentTag.queryNDEFStatus { status, capacity, error in
                guard error == nil else {
                    session.invalidate(errorMessage: "Could not query status of Hito Wallet.")
                    return
                }

                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "Protocol is not supported.")
                case .readOnly:
                    session.invalidate(errorMessage: "Protocol is only readable.")
                case .readWrite:
                    let message = NFCNDEFMessage.init(records: [payload])
                    currentTag.writeNDEF(message) { error in
                        if error != nil {
                            session.invalidate(errorMessage: "Failed to write message.")
                        } else {
                            session.alertMessage = "Scan to Transmit"

                            self.hitoNfcRequest.isDataTransmitted = true
                            session.invalidate()
                        }
                    }
                @unknown default:
                    session.invalidate(errorMessage: "Unknown status of device.")
                }
            }
        }
    }
    
    var hitoNfcRequest: HitoNfcRequest = HitoNfcRequest(type: .signEvmTransaction, payload: "")

    func signEvmRequest(address: String, unsignedTransaction: String, completion: @escaping (String?) -> Void) {
        
        self.completion = completion
        
        let payload = "eth.send:" + address + ":" + unsignedTransaction
        
        hitoNfcRequest = HitoNfcRequest(type: .signEvmTransaction, payload: payload)
        
        self.txraw = unsignedTransaction
        
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Tap to Confirm"
        session.begin()

    }
    
    func signExpertModeRequest(params: ExpertModeParameters, completion: @escaping (String?) -> Void) {
        
        self.completion = completion
        
        let expertModeData = params.serialize()
        
        // construct request
        hitoNfcRequest = HitoNfcRequest(type: .signExpertMode, payload: expertModeData)
        
        // start nfc session
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Tap Hito on Expert Mode"
        session.begin()
    }
    
    func utxoAddressRequest(bip44path: String, completion: @escaping (String?) -> Void) {
        
        self.completion = completion
        
        let params = ExpertModeParameters()
        
        params.resetData()
        params.curve       = .secp256k1
        params.keyHashing  = .ripemd160
        params.keyEncoding = .bech32
        params.bip44       = bip44path
        
        let payload = params.serialize()
        
        hitoNfcRequest = HitoNfcRequest(type: .requestUtxoAddress, payload: payload)
         
    }
    
    
}
