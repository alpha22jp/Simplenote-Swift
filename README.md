# Simplenote-Swift

## What's this?

[Simplenote](https://simple-note.appspot.com/) client as a sample application for learning Swift which includes the following elements.

* Basic master-detail view navigation
* Alamofire and SwiftyJSON implementation to access to Simplenote server
* CoreData manipulation for caching note data
* Setting screen using table view with static cells
* Search bar implementation by UISearchController (newly-introduced in iOS 8)

## Environment

* XCode 6.1.1
* iOS 8.0 later

## How to build

```Shell
git clone https://github.com/alpha22jp/Simplenote-Swift.git
cd Simplenote-Swift
git submodule init
git submodule update
cd Alamofire-SwiftyJSON
git submodule init
git submodule update
```

Open `Simplenote.xcodeproj` by XCode and build it!
