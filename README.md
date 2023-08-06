# Hito Link - hardware wallet interface 

This document describes of how to communicate with Hito wallet from an app

1. [Linking app with Hito wallet](#link)
1. [Signing ethereum transaction](#ethereum)
1. [Signing secp256k1 and ed25519](#expertsign)
1. [Get pubkey/address for a BIP44 path](#bip44) 
1. [Sample code](#sample)
1. [Libraries](#libs)


## <a name="link"/>1. Linking app with Hito wallet

To link an app with Hito wallet the app need to obtain a public address 
from a Hito wallet via QR-code and save it on our side 

### Display the public address on Hito wallet 
1. Unlock Hito wallet with entering the passcode
2. Tap "Menu" on top left corner
3. Choose "Pair with the App" - device will display address as a qrcode 

### Scan the Qr-code with the App

Hito provides a public address as a Qr-Code with a prefix:
```
ethereum:0x56DCE5b7A8656b1aE45a0FbfCe504CE59196C7b8
```

![Device with the ethereum address displayed](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/hito_eth_address.jpeg)

### Ethereum API public endpoints

TODO: add api endpoints here

## <a name="ethereum"/>2. Signing ethereum transaction 

Signing is done via NFC. The app should transfer the unsigned signature  
as NDEF message to the device. Payload format is below.

![](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/send.jpeg)

1. Prepare device - Unlock and Tap "SEND"
2. Send NDEF message from app to device (NFC antenna is under the screen)
3. Device will parse the transaction and displays the confirmation
4. After signing Hito device will display the signed transaction in 
the hex format as a qr-code

##### NDEF Payload format
```
eth.send:<address>:<unsigned_transaction>
<address> - ethereum address in hex format with 0x prefix
<tx>      - unsigned transaction in hex format with 0x prefix
```



### Eth transfer on Sepolia 

#### NDEF Payload

`eth.send:0x56DCE5b7A8656b1aE45a0FbfCe504CE59196C7b8:0xee818d840b766ae082520894feed146aa5f20bc991a994a1ac2fe0bb75df2bb087038d7ea4c680008083aa36a78080`

![Confirmation](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/eth_confirm.jpeg)


#### Completed transaction
https://sepolia.etherscan.io/tx/0xdbdb3ed9f6f65706568bbcb5cfa75ea4998f94f7dec68fb58bcc656c8e58ba27

![Signed transaction on device](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/signed_transaction.jpeg)


### Erc20 token transfer on Sepolia 

#### NDEF Payload
`eth.send:0x56DCE5b7A8656b1aE45a0FbfCe504CE59196C7b8:0xf86c818e840c674b5982b40e94b2d6bf8aed4db22e29e29a57724395ad05669a3380b844a9059cbb000000000000000000000000feed146aa5f20bc991a994a1ac2fe0bb75df2bb00000000000000000000000000000000000000000000000000000000005f5e10083aa36a78080`

![Confirmation](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/erc20_confirm.jpeg)


#### Completed transaction
https://sepolia.etherscan.io/tx/0xb0732708bd1cc483e48bdc379be101b537267eab2d606cd9c51fa28800f31165

![Signed transaction on device](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/signed_erc20.jpeg)



## <a name="expertsign"/>3. Signing Secp256k1 and Ed25519 

![Hito Device with expert mode enabled](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/expertmode.jpeg)

1. Prepare device - Unlock and Tap "SEND"
2. Send NDEF message from app to device (NFC antenna is under the screen)
3. Device will parse the transaction and displays the confirmation
4. After signing Hito device will display the signed transaction in 
the hex format as a qr-code

#### NDEF Payload - signing bitcoin output hash using bitcoin testnet address  
`

`

## <a name="bip44"/>4. Get pubkey/address for a BIP44  

![Hito Device with expert mode enabled](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/expertmode.jpeg)

1. Prepare device - Unlock and Tap "SEND"
2. Send NDEF message from app to device (NFC antenna is under the screen)
3. Device will parse the transaction and displays the confirmation
4. After signing Hito device will display the signed transaction in 
the hex format as a qr-code

#### NDEF Payload example - display bitcoin testnet address as a qr-code
```
hito.pubkey:secp256k1:ripemd160:bech32:m/44'/1'/0'/0/0::
````

![Bitcoin address confirmation](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/bitcoin_confirm.jpeg)


#### Bitcoin address after confirmation screen
```
bitcoin:tb1q4k345qwkhss6x0cz0fwcsurw2qngmvwl9tf3sk?bip32=m/44'/1'/0'/0/0
```

![Bitcoin address](https://raw.githubusercontent.com/mishabunte/hito-link/main/img/bitcoin_qr.jpeg)


## <a name="sample"/>5. Sample code

### WebNFC Javascript

```javascript

```

[webnfc-hito.js](./src/webnfc-hito.js)


### CoreNFC Swift 

```
```

[./src/NFCController.swift](./src/NFCController.swif)

## <a name="libs"/>6. Libraries

TODO: add links

### Qr code
### NFC 



