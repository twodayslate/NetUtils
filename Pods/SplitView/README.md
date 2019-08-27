# SplitView

Resizable Split View, inspired by [Apple's Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)

<p align="center">
<img src="./images/vertical.png" width="25%" alt="Vertical"/> <img src="./images/horizontal.png" width="25%" alt="Horizontal"/>
</p>

## Requirements

iOS 11.0+

### CocoaPods

```
pod 'SplitView', :git => 'https://github.com/twodayslate/SplitView.git'
```

## Usage

Using SplitView is easy! Simply create a `SplitView` and add your views to it!
```
let mySplitView = SplitView()
mySplitView.addView(myFirstView)
mySplitView.addView(mySecondView)
```

There are certain customizations available.

Be sure to checkout the [example App](./app).
