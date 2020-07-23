<p align="center" >
<img src="https://raw.githubusercontent.com/Mumble-SRL/MBNetworkingSwift/master/Images/mumble-logo.gif" alt="MBurger Logo" title="Mumble Logo">
</p>

[![Test Status](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)](https://github.com/Mumble-SRL/MBNetworkingSwift/tree/master/docs)
[![License: MIT](https://img.shields.io/badge/pod-v1.0.7-blue.svg)](https://cocoapods.org)
[![](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBNetworking

Networking library written in Swift used in MBurger and other Mumble projects.

# Installation 

## Swift Package Manager
With Xcode 11 you can start using [Swift Package Manager](https://swift.org/package-manager/) to add **MBNetworkingSwift** to your project. Follow those simple steps:

* In Xcode go to File > Swift Packages > Add Package Dependency.
* Enter `https://github.com/Mumble-SRL/MBNetworkingSwift.git` in the "Choose Package Repository" dialog and press Next.
* Specify the version using rule "Up to Next Major" with "1.0.6" as its earliest version and press Next.
* Xcode will try to resolving the version, after this, you can choose the `MBNetworkingSwift` library and add it to your app target.

## CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate MBNetworkingSwift into your Xcode project using CocoaPods, specify it in your Podfile:

``` ruby
pod 'MBNetworkingSwift'
```

## Carthage 

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate MBNetworkingSwift into your Xcode project using Carthage, specify it in your Cartfile:

``` ruby
github "Mumble-SRL/MBNetworkingSwift"
```

## Manually

Copy and paste the content of the MBNetworking folder in your project

# Usage

Example usage:

``` swift
let urlString = "https://www.example.com/api/test"

let headers = [HTTPHeader(field: "Accept", value: "application/json")]
let parameters = ["key": "value"]

MBNetworking.request(withUrl: urlString,
                     method: .get,
                     headers: headers,
                     parameters: parameters,
                     encoding: URLParameterEncoder.default) { response in
                        switch response.result {
                        case .success(let json):
                            print(json)
                        case .error(let error):
                            print(error.localizedDescription)
                        }
}
```
