# Cryptobox for iOS

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

## Building iOS project
### Prerequisites
`libcryptobox.a`, `libcryptobox.a` plus all the required headers should be located under the `${PROJECT_DIR}/build/` directory. To archieve this you either can build the `libcryptobox` on your own (See [Building libcryptobox](/sdasdasda)) or download and unpack the released binary via the `fetch-lib-from-github.py` script located under `Scripts` folder. 


