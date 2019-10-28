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
- Google Web Risk Information
- Ping utility
- View page source

## Requirements

### CocoaPods
This project uses [CocoaPods](https://cocoapods.org/). The Podfile and Pods folder is included for your conviencance. This project will slowly transition to Swift Package Manager.

### API Keys

In order to use/build this project you will have to create an Api Key `enum`. An example is below:

```swift
struct ApiKey {
    let name: String
    let key: String

    static var inApp: ApiKey {
        return ApiKey(name: "In-App Purchases", key: "my_key_here")
    }
}
```

This is necessary to support for In-App purchases properly. Service related keys are stored on the [Cloudflare Workers®](https://www.cloudflare.com/products/cloudflare-workers/) server.

## Credits

Icons by [Nucleo](https://nucleoapp.com/)