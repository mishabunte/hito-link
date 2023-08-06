//
//  Hito
//
//  Created by Anton on 02.01.23.
//

import Foundation

enum SigningCurve: String {
    case secp256k1
    case secp256k1r
    case ed25519
}

enum KeyHashing: String {
    case sha256
    case ripemd160
    case none
    case sha3_160
}

enum KeyEncoding: String {
    case hex
    case base58
    case bech32
}

struct ExpertModeDefaults {
    static let curveKey    = "expertmode.curve"
    static let hashingKey  = "expertmode.hashing"
    static let encodingKey = "expertmode.encoding"
    static let bip44Key    = "expertmode.bip44"
    
    static func getCurve() -> SigningCurve {
        if let curve = SigningCurve(rawValue: UserDefaults.standard.string(forKey: curveKey) ?? SigningCurve.secp256k1.rawValue) {
            return curve
        } else {
            return SigningCurve.secp256k1
        }
    }
    static func getKeyHashing() -> KeyHashing {
        if let hashing = KeyHashing(rawValue: UserDefaults.standard.string(forKey: hashingKey) ?? KeyHashing.ripemd160.rawValue) {
            return hashing
        } else {
            return KeyHashing.ripemd160
        }
    }
    static func getKeyEncoding() -> KeyEncoding {
        if let encoding = KeyEncoding(rawValue: UserDefaults.standard.string(forKey: encodingKey) ?? KeyEncoding.bech32.rawValue) {
            return encoding
        } else {
            return KeyEncoding.bech32
        }
    }
    static func getBip44() -> String {
        return UserDefaults.standard.string(forKey: bip44Key) ?? "m/44'/1'/0'/0/0"
    }
    
    static func set(_ curve: SigningCurve) {
        UserDefaults.standard.set(curve.rawValue, forKey: curveKey)
    }
    static func set(_ keyHashing: KeyHashing) {
        UserDefaults.standard.set(keyHashing.rawValue, forKey: hashingKey)
    }
    static func set(_ keyEncoding: KeyEncoding) {
        UserDefaults.standard.set(keyEncoding.rawValue, forKey: encodingKey)
    }
    static func set(bip44: String) {
        UserDefaults.standard.set(bip44, forKey: bip44Key)
    }
}

class ExpertModeParameters: ObservableObject {
    @Published var from: String = ""
    @Published var tx: String = ""
    
    @Published var strError: String = ""
    @Published var bip44Error: String = ""
    @Published var signatureError: String = ""
    
    @Published var prefix: String = ""
    @Published var curve: SigningCurve = ExpertModeDefaults.getCurve() {
        didSet {
            ExpertModeDefaults.set(curve)
        }
    }
    @Published var keyHashing: KeyHashing   = ExpertModeDefaults.getKeyHashing() {
        didSet {
            ExpertModeDefaults.set(keyHashing)
        }
    }
    @Published var keyEncoding: KeyEncoding = ExpertModeDefaults.getKeyEncoding() {
        didSet {
            ExpertModeDefaults.set(keyEncoding)
        }
    }
    
    @Published var callbackUrl   : String = ""
    @Published var signatureHash : String = ""
    @Published var bip44         : String = ExpertModeDefaults.getBip44() {
        didSet {
            ExpertModeDefaults.set(bip44: bip44)
        }
    }
    
    @Published var showError   : Bool = false
    
    @Published var isShown          : Bool = false
    
    @Published var qr : QrScannerParameters = QrScannerParameters()
    
    func serialize() -> String {
        let data =
          (signatureHash == "" ? "hito.pubkey:" : "hito.sign") +
            curve.rawValue + ":" +
            (keyHashing == .none ? "" : keyHashing.rawValue) + ":" +
            keyEncoding.rawValue + ":" +
            bip44                + ":" +
            signatureHash        + ":" +
            callbackUrl
        return data
    }
    
    func verifyParameters() -> Bool {
        
        bip44Error = ""
        signatureError = ""
        
        // verify bip44 path
        if !bip44.matches("^m/44'/[0-9]{1,10}'?/[0-9]{1,10}'/[0-1]/[0-9]{1,10}$") {
            strError   = "Expected a valid BIP44 path but got \(bip44)"
            bip44Error = strError
            return false
        }
        
        print(signatureHash.count)
        // Verify signature hash is valid
        if signatureHash.count > 0 && !signatureHash.matches("^(0x)?[0-9a-fA-F]{64}$") {
            strError = "Invalid signature hash: Expected a 256-bit signature in hex format but got \(signatureHash)"
            signatureError = strError
            return false
        }
        
        /*
        if (callbackUrl != "") {
            // Verify the callbackURL is a valid URL
            if URL(string: callbackUrl) == nil {
                strError = "Invalid callbackURL: Expected a valid URL but got \(callbackUrl)"
                return false
            }
        }
         */
        
        return true
    }
    
    func resetData() {
        
        prefix = ""
        curve   = SigningCurve.secp256k1
        keyHashing    = KeyHashing.sha256
        keyEncoding   = KeyEncoding.hex
        callbackUrl   = ""
        bip44         = ""
        signatureHash = ""
        
        strError = ""
    }
    
    func parseString(_ str: String?) -> Bool {
        
        if (str == nil) {
            return false
        }
        
        resetData()
        
        let dataComponents = str!.split(separator: ":", maxSplits: 6, omittingEmptySubsequences: false)
        
        // Ensure there are exactly 7 components
        guard dataComponents.count == 7 else {
            strError = "Invalid data: Expected 7 components but got \(dataComponents.count)"
            return false
        }
        
        if (dataComponents[0] != "hito.sign" && dataComponents[0] != "hito.pubkey") {
            strError = "Invalid prefix, hito.{sign,pubkey} expected"
            return false
        }
        
        prefix = String(dataComponents[0])
        
        // printing for debug purposes
        print(dataComponents)
        print(dataComponents.count)
        
        // Assign the components to named variables
        guard let signingAlgorithm = SigningCurve(rawValue: String(dataComponents[1])) else {
            strError = "Invalid signing algorithm: \(String(dataComponents[1]))"
            return false
        }
        guard let keyHashing = KeyHashing(rawValue: String(dataComponents[2] == "" ? "none" : dataComponents[2])) else {
            strError = "Invalid key hashing: \(String(dataComponents[2]))"
            return false
        }
        guard let keyEncoding = KeyEncoding(rawValue: String(dataComponents[3])) else {
            strError = "Invalid key encoding: \(String(dataComponents[3]))"
            return false
        }
        
        self.curve   = signingAlgorithm
        self.keyHashing    = keyHashing
        self.keyEncoding   = keyEncoding
        self.bip44         = String(dataComponents[4])
        self.signatureHash = String(dataComponents[5])
        
        if dataComponents.count == 7 {
            callbackUrl   = String(dataComponents[6])
        } else {
            callbackUrl   = ""
        }
        
        return verifyParameters()
        
    }
}
