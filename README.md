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

```Shell
git clone --recuesive https://github.com/alpha22jp/Simplenote-Swift.git
```

Open `Simplenote.xcodeproj` by XCode and build it!

## Todo

* Support editting note
* Support Simplenote tags
* Store password securely by KeyChain
* Support multi languages

## Tanks

* Thanks to [designshock](http://www.easyicon.net/language.en/iconsearch/author:designshock/) for application icon
