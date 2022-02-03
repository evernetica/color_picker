# Color Picker

## App Demo

<img src="https://github.com/Xapocc/color_picker/blob/master/color_picker.gif" height="360"/>

## General Information

Color picker allows you to know the code and the name of a color by pointing your phone's camera on
it.

It also can save to favourites a color from this[^1] table that is closest to picked one.
[^1]: https://raw.githubusercontent.com/jonathantneal/color-names/master/color-names.json

### - Project uses Clean Architecture approach
### - Project uses Cubit for navigation purposes

## Features:

- Supports both iOS and Android
  > On iPhone 6-8 app uses low camera resolution to avoid memory shortage (
  flutter [issue #44436](https://github.com/flutter/flutter/issues/44436))
- Identifies observed color's code in real-time
- Tapping the bottom panel saves color to favourites list
- Favourites list can be saved to device's memory
  > Saved file can be found at "\*app_documents_directory\*/favouriteColors.json"
- Crosshair is always visible due to using of inverted colors
- Toast-notifications use picked color as background color and it's inversion for text color

## Flutter Plugins Used[^2]:

[^2]: Plugins' versions can be found
at "https://github.com/Xapocc/color_picker/blob/master/pubspec.yaml"

- fluttertoast
- path_provider
- device_info_plus
- http
- camera
- equatable
- flutter_bloc