# SplitView

Resizable Split View, inspired by [Apple's Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)

<p align="center">
<img src="https://github.com/twodayslate/SplitView/raw/master/images/vertical.png" width="25%" alt="Vertical"/> <img src="https://github.com/twodayslate/SplitView/raw/master/images/horizontal.png" width="25%" alt="Horizontal"/>
</p>

## Requirements

### Swift Package Manager (SPM)

```
.Package(url: "https://github.com/twodayslate/SplitView.git", majorVersion: 1)
```

For the latest updates use:
```
.Package(url: "https://github.com/twodayslate/SplitView.git", branch: "master")
```

### CocoaPods

```
pod 'SplitView'
```

For the latest updates use:
```
pod 'SplitView', :git => 'https://github.com/twodayslate/SplitView.git'
```

## Usage

Using `SplitView` is easy! Simply create a `SplitView` and add your views to it - just like a `UIStackView`.

```
import SplitView
//
let mySplitView = SplitView()
mySplitView.addSplitSubview(myFirstView)
mySplitView.addSplitSubview(mySecondView)
```

There are certain customizations available including minimum sizing and snapping. Custom handles are also supported.

Be sure to checkout the [example App](https://github.com/twodayslate/SplitView/tree/master/app).
