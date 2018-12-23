// swift-tools-version:4.0
//
//  Package.swift
//  TIme
//
//  Created by Petar Lemajic on 12/23/18.
//  Copyright © 2018 Petar Lemajic. All rights reserved.
//
import PackageDescription

let package = Package(
    name: "TIme",

    dependencies: [
        /* Add your package dependencies in here
        .package(url: "https://github.com/AlwaysRightInstitute/cows.git",
                 from: "1.0.0"),
        */
        .package(url: "https://github.com/apple/swift-nio.git", 
                 from: "1.9.4"),
    ],

    targets: [
        .target(name: "TIme", 
                dependencies: [
                  /* Add your target dependencies in here, e.g.: */
                  // "cows",
                  "NIO",
                ])
    ]
)
