# PersianSubtitleFixer

## Description

This app converts text encoding of Persian (Farsi) or Arabic .srt subtitle files to UTF-8 so they can be used in almost every video player. The app is currently available on the Mac App Store: https://shaa.in/subfixerapp.

### Solution

The dropped subtitle file(s) in the app will be loaded in a hidden `webView` using `Windows-1256` encoding. After it completely loaded, the app saves the loaded document with `UTF-8` encoding to a new location.

### Area to Improve, Where to contribute?

There are several areas to improve the application. Your contribution is so welcome. You may check the issues tab to find current issues and features requests. If you are a user of this app, feel free to add your ideas and/or findings.
