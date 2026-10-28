# homebrew-ffmpeg-webp-jxl

[![tests](https://github.com/suiboli314/homebrew-ffmpeg-webp-jxl/actions/workflows/tests.yml/badge.svg)](https://github.com/suiboli314/homebrew-ffmpeg-webp-jxl/actions/workflows/tests.yml)

Homebrew's default `ffmpeg`, plus **libwebp** and **libjxl** (JPEG XL). Nothing else added.

Homebrew's `ffmpeg` formula leaves those two out, and `ffmpeg-full` pulls in dozens of libraries most people don't need. This tap sits in between: the same build as core `ffmpeg`, with WebP and JPEG XL encoding and decoding enabled.

## Install

```sh
brew uninstall ffmpeg   # this formula conflicts with core ffmpeg
brew install suiboli314/ffmpeg-webp-jxl/ffmpeg-webp-jxl
```

Or tap it first (see [Trusting this tap](#trusting-this-tap)):

```sh
brew tap suiboli314/ffmpeg-webp-jxl
brew trust --formula suiboli314/ffmpeg-webp-jxl/ffmpeg-webp-jxl
brew install ffmpeg-webp-jxl
```

## Uninstall 

```sh
brew trust                                        # list what you trust
brew untrust --formula suiboli314/ffmpeg-webp-jxl/ffmpeg-webp-jxl
brew uninstall suiboli314/ffmpeg-webp-jxl/ffmpeg-webp-jxl
brew untap suiboli314/ffmpeg-webp-jxl             # if tapped before
```

## Check it worked

```sh
ffmpeg -hide_banner -encoders | grep -E 'libwebp|libjxl'
```

Both encoders should be listed.

## Examples

```sh
# WebP: lossy, then lossless
ffmpeg -i input.png -c:v libwebp -quality 80 output.webp
ffmpeg -i input.png -c:v libwebp -lossless 1 output.webp

# JPEG XL: visually lossless, then mathematically lossless
ffmpeg -i input.png -c:v libjxl -distance 1 output.jxl
ffmpeg -i input.png -c:v libjxl -distance 0 output.jxl
```

## Updates

A daily workflow checks ffmpeg.org for a new release and opens a pull request that bumps the formula's `url` and `sha256`. CI builds and tests it before it is merged, and bottles are published from the PR.

## Notes

- Installing this formula conflicts with core `ffmpeg`. Formulae that depend on `ffmpeg` will want to install it, so use `brew install --ignore-dependencies` for those if you need to.
- Bottles are only built for the platforms GitHub's runners support. Anything else builds from source.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
