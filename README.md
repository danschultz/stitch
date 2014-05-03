# Spritely
Spritely is a Dart package that uses transformers to generate CSS sprite sheets.

## Configuration
Add Spritely to your `pubspec.yaml`.

```
name: my_app
description: A web application
dependencies:
  browser: any
  spritely: any
transformers:
- spritely
```

## Usage
Spritely looks for links to a sprite sheet's CSS file. If one is found, it'll generate a CSS file and sprite sheet with all the PNGs that are contained within the directory of the same name as the sprite sheet.

For example, lets say you have a Dart application with the following folder structure:

```
my_app/
  lib/
  web/
    images/
      icons/
        star.png
        info.png
    index.html
```

To tell Spritely to generate a sprite sheet for all PNGs in `web/images/icons`, an HTML file must reference `web/images/icons.css`.

To use the icon sprites in `index.html`:

```
<html>
  <head>
    <title>My App</title>
    <link rel="stylesheet" href="images/icons.css">
  </head>
</html>
```

Running `pub build` will compile your application and any referenced sprite sheets. Using the previous example, `pub build` would generate the following directory structure:

```
my_app/
  build/
    web/
      images/
        icons/
          star.png
          plus.png
        icons.css
        icons.png
      index.html
  ...
```

## Todo
* Add support for SASS
* Add support for LESS
* Customization options: padding, sprite layout, etc.