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

* XCode 7.2
* iOS 8.0 or higher

## How to build

Before building the project, install and setup CocoaPods.
```Shell
sudo gem install cocoapods
pod setup
```
Get source code from GitHub and install libraries provided from CocoaPods.
```Shell
git clone --recursive https://github.com/alpha22jp/Simplenote-Swift.git
cd Simplenote-Swift
pod install
```
Open `Simplenote-Swift/Simplenote.xcworkspace` by XCode and build it!

## Todo

* Support editting note (Now working on this)
* Support Simplenote tags
* Store password securely by KeyChain
* Support multi languages

## History

* 2016/1 Update to support Swift 2.0 (with xcode7.2)
* 2015/1 Initial Release

## Tanks

* Thanks to [designshock](http://www.easyicon.net/language.en/iconsearch/author:designshock/) for application icon
