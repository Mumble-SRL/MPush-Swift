<p align="center" >
<img src="https://raw.githubusercontent.com/Mumble-SRL/MBNetworkingSwift/master/Images/mumble-logo.gif" alt="MBurger Logo" title="Mumble Logo">
</p>

![Test Status](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/pod-v1.0-blue.svg)
[![CocoaPods](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBNetworking

Networking library written in Swift used in MBurger and other Mumble projects.

# Installation 

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your Podfile:

``` ruby
pod 'MBNetworking'
```

## Manually

Copy and paste the content of the MBNetworking folder in your project

TODO: Carthage and SPM

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
