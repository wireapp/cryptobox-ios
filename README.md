# Wire

[![Wire logo](https://github.com/wireapp/wire/blob/master/assets/header-small.png?raw=true)](https://wire.com/jobs/)

This repository is part of the source code of Wire. You can find more information at [wire.com](https://wire.com) or by contacting opensource@wire.com.

You can find the published source code at [github.com/wireapp](https://github.com/wireapp). 

For licensing information, see the attached LICENSE file and the list of third-party licenses at [wire.com/legal/licenses/](https://wire.com/legal/licenses/).

# Cryptobox for iOS

This project provides cross-compiled binaries of [cryptobox-c](https://github.com/wireapp/cryptobox-c) for iOS, currently only in the form of static libraries.

## Building

A Rust cross-compiler (1.25.X or later) is needed that supports the following iOS architectures:

  * armv7-apple-ios
  * armv7s-apple-ios
  * i386-apple-ios
  * aarch64-apple-ios
  * x86_64-apple-ios

It is recommended to use [rustup](https://github.com/rust-lang-nursery/rustup.rs) to manage the necessary
compiler toolchains. Using rustup, the following commands will install the necessary binaries for
cross-compiling to above architectures:

    rustup target add armv7-apple-ios
    rustup target add armv7s-apple-ios
    rustup target add i386-apple-ios
    rustup target add aarch64-apple-ios
    rustup target add x86_64-apple-ios

Alternatively, for instructions on how to build a compiler from source that supports
all the necessary architectures, please refer to the [Rust Wiki](https://github.com/rust-lang/rust-wiki-backup/blob/master/Doc-building-for-ios.md).

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
