# Stitch
Stitch is a Dart package that uses transformers to generate CSS sprite sheets.

## Configuration
Add Stitch as a dependency and transformer to your `pubspec.yaml`.

```
name: my_app
description: A web application
dependencies:
  browser: any
  stitch: any
transformers:
- stitch
```

## Usage
To generate a CSS sprite sheet, have your HTML reference a CSS file with the same name as a directory that has your sprite images.

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

To tell Stitch to generate a sprite sheet for all PNGs in `web/images/icons`, just reference `web/images/icons.css` from an HTML file.

The generated CSS file contains classes that reference the images within the sheet sheet. For each image, a class with the naming convention `{folder-name}-{image-name}` will be generated. Each class sets the element's `background-image`, `background-position`, `width` and `height`.

Using the *star.png* and *info.png* sprites in `index.html`:

```
<html>
  <head>
    <title>My App</title>
    <link rel="stylesheet" href="images/icons.css">
  </head>
  <body>
  	<div class="icons-star"></div>
  	<div class="icons-info"></div>
  </body>
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