# CombineUI
This is a framework I'm developing (currently for use in a personal project) to bridge Combine with UIKit and other Cocoa Touch frameworks like Core Data. At the moment, its development is guided by the features that I need for the personal project, but I'm more than open to PRs from people who want to contribute. Once I have a feel for what works and what doesn't, I plan on releasing this as a CocoaPod, Swift Package, etc. I plan on testing things as thoroughly and extensively as possible, but sometimes I don't write tests for features until after using the features for a bit to find bugs and other issues.

Classes are named to match their original counterparts, with a `C` prefix. For example, the features supporting `UITableView` are named `CUITableView*`.

Here's what CombineUI contains:
* `CNSManagedObjectFetchedResultsController`: A Core Data utility to perform a fetch request on a managed object context, and then notify a publisher when items matching the request change, get added, removed, etc.
* `CUIControlPublisher` and `CUIControlSubscription`: Utilities that let you observe target-action events on controls using Combine publishers.
* `CUIViewController`: A `UIViewController` subclass that makes it easier to configure and manage bindings.
* `CUITableViewSection` and `CUITableViewDescriptor`: Utilities that make it easier to configure table views using Combine publishers to provide items and sections. See [this blog post](https://pranj.co/blog/uitableview-in-2020) for an introduction.
* `UIAlertController+CombineUI`: A `UIAlertController` extension that makes it possible to show an alert with a text field, along with a publisher that provides updates when the text field gets submitted.
