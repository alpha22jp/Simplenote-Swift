# Simplenote-Swift

## What's this?

[Simplenote](https://simple-note.appspot.com/) client for iOS as a sample application for learning Swift which includes the following elements.

* Basic master-detail view navigation
* [Alamofire](https://github.com/Alamofire) to access to Simplenote server
* [SwiftyJSON](https://github.com/SwiftyJSON) to handle JSON data
* [Markingbird](https://github.com/kristopherjohnson/Markingbird) to render Markdown formatted note
* CoreData manipulation for caching note data
* NSFetchedResultsController to sync table view with CoreData
* Setting screen using table view with static cells
* Search bar implementation by UISearchController (newly-introduced in iOS 8)

## Environment

* XCode 6.1.1
* iOS 8.0 later

## How to build

1. Before building the project, install CocoaPods 0.36.0 beta.1.
```Shell
sudo gem install cocoapods --pre
```
2. Get source code from GitHub and setup libraries provided from CocoaPods.
```Shell
git clone --recuesive https://github.com/alpha22jp/Simplenote-Swift.git
cd Simplenote-Swift
pod install
```
3. Open `Simplenote-Swift/Simplenote.xcworkspace` by XCode and build it!

## Todo

* Support editting note
* Support Simplenote tags
* Store password securely by KeyChain
* Support multi languages

## Tanks

* Thanks to [designshock](http://www.easyicon.net/language.en/iconsearch/author:designshock/) for application icon
