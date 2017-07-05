#!/usr/bin/env bash

export PREFIX="$(pwd)/libsodium-macos"
export MACOS64_PREFIX="$PREFIX/tmp/macos64"

mkdir -p $PREFIX $MACOS64_PREFIX
rm -fr "$PREFIX/include" "$PREFIX/libsodium.a" 2> /dev/null

export CFLAGS="-O2 -arch x86_64"
export LDFLAGS="-arch x86_64"

make distclean > /dev/null

./configure --host=x86_64-apple-darwin16.6.0 \
            --disable-shared \
            --prefix="$MACOS64_PREFIX" || exit 1

make -j3 install || exit 1

# Create universal binary and include folder
rm -fr -- "$PREFIX/include" "$PREFIX/libsodium.a" 2> /dev/null
mkdir -p -- "$PREFIX"
lipo -create \
  "$MACOS64_PREFIX/lib/libsodium.a" \
  -output "$PREFIX/libsodium.a"
mv -f -- "$MACOS64_PREFIX/include" "$PREFIX/"

echo
echo "libsodium has been installed into $PREFIX"
echo
