# Cryptobox for iOS [![Build Status](https://travis-ci.org/romanb/cryptobox-ios.svg?branch=master)](https://travis-ci.org/romanb/cryptobox-ios)

This project provides for cross-compilation of [cryptobox](https://github.com/romanb/cryptobox) for iOS, currently only in the form of static libraries. It may also provide higher-level Objective-C bindings to the C interface in the future, as well as dynamic libraries.

## Building libcryptobox

A rust cross-compiler is needed that supports the following iOS architectures:

  * armv7-apple-ios
  * armv7s-apple-ios
  * i386-apple-ios
  * aarch64-apple-ios
  * x86_64-apple-ios

For instructions on how to build such a cross-compiler, refer to the [Rust Wiki](https://github.com/rust-lang/rust-wiki-backup/blob/master/Doc-building-for-ios.md).

**Note**: Link against the following native artifacts when linking against the `libcryptobox.a` static library. The order and any duplication can be significant on some platforms, and so may need to be preserved:

  * library: sodium (`libsodium.a` is distributed as part of this project)
  * library: c
  * library: m
  * library: System
  * library: objc
  * framework: Foundation
  * framework: Security
  * library: pthread
  * library: c
  * library: m

## Integrating Objective-C Wrapper
You can integrate Objective-C Wrapper (Cryptobox.framework) using Carthage with `github "romanb/cryptobox-ios"`.
When Carthage will build it first time it will also build `libcryptobox.a` and `libsodium.a` in `Carthage/Checkouts/cryptobox-ios/build` with `libs` and `include` subfolders. So you can just add these paths to Libraries Search Paths and Headers Search Paths of your project.

