# Wire

This repository is part of the source code of Wire. You can find more information at [wire.com](https://wire.com) or by contacting opensource@wire.com.

You can find the published source code at [github.com/wireapp](https://github.com/wireapp). 

For licensing information, see the attached LICENSE file and the list of third-party licenses at [wire.com/legal/licenses/](https://wire.com/legal/licenses/).

# Cryptobox for iOS

This project provides cross-compiled binaries of [cryptobox-c](https://github.com/wireapp/cryptobox-c) for iOS, currently only in the form of static libraries.

## Building

A rust cross-compiler is needed that supports the following iOS architectures:

  * armv7-apple-ios
  * armv7s-apple-ios
  * i386-apple-ios
  * aarch64-apple-ios
  * x86_64-apple-ios

For instructions on how to build such a cross-compiler, refer to the [Rust Wiki](https://github.com/rust-lang/rust-wiki-backup/blob/master/Doc-building-for-ios.md).

To perform the build:

    make dist

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
