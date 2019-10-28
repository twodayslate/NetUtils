# SKVersion

App Store Version Update Checker

## Requirements

iOS 11.0+

### CocoaPods

```
pod 'SKVersion', :git => 'https://github.com/twodayslate/SKVersion.git'
```

## Usage

``` swift
Bundle.main.storeVersion?.update {
    (canUpdate, version, error) in
    guard error == nil else {
        print("An error has occured! \(error!.localizedDescription)")
        return
    }
    
    if canUpdate {
        print("An update to \(String(describing: version)) is available")
    }
}
```
