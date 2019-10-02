# SplitView

Resizable Split View, inspired by [Apple's Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)

<p align="center">
<img src="https://github.com/twodayslate/SplitView/raw/master/images/vertical.png" width="25%" alt="Vertical"/> <img src="https://github.com/twodayslate/SplitView/raw/master/images/horizontal.png" width="25%" alt="Horizontal"/>
</p>

## Requirements

iOS 11.0+

### CocoaPods

```
pod 'SplitView'
```

For the latest updates use:
```
pod 'SplitView', :git => 'https://github.com/twodayslate/SplitView.git'
```

## Usage

Using SplitView is easy! Simply create a `SplitView` and add your views to it!
```
import SplitView
...
let mySplitView = SplitView()
mySplitView.addView(myFirstView)
mySplitView.addView(mySecondView)
```

There are certain customizations available including minimum sizing and snapping.

Be sure to checkout the [example App](https://github.com/twodayslate/SplitView/tree/master/app).
