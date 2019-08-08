# NetUtils

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
        return ApiKey(name: "WhoisXML", key: "myKey")
    }
}
```

## Features

* View network connectivity status
* View network interfaces
* ping
* View Source

## Future Work
- [ ] GET/POST requests -> view source
- [ ] VPN status
- [ ] whois information
- [ ] dig / nslookup
- [ ] SSID information
- [ ] Safari web extension

## Credits

Icons by [Icons8](https://icons8.com)