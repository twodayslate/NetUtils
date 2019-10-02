# NetUtils

The all-in-one Network Utility application!

NetUtils is a Network Utility application that can do a whole lot, including:
- Network connectivity status
- Network interface information
   - WiFi information
   - VPN information
- Host information
- WHOIS information from Whois XML API (subscription required)
- DNS information from Whois XML API (subscription required)
- Ping utility
- View page source

## Requirements

### CocoaPods
This project uses [CocoaPods](https://cocoapods.org/). The Podfile and Pods folder is included for your conviencance. 

* [Highlightr](https://github.com/raspu/Highlightr)
* [ReachabilitySwift](https://github.com/ashleymills/Reachability.swift)
* [PlainPing](https://github.com/naptics/PlainPing)
* [NetUtils](https://github.com/svdo/swift-netutils)

### API Keys

In order to use/build this project you will have to create an Api Key `enum`. An example is below:

```swift
struct ApiKey {
    let name: String
    let key: String

    static var WhoisXML: ApiKey {
        return ApiKey(name: "Whois XML API", key: "my_key_here")
    }

    static var inApp: ApiKey {
        return ApiKey(name: "In-App Purchases", key: "my_key_here")
    }
}
```

## Credits

Icons by [Nucleo](https://nucleoapp.com/)