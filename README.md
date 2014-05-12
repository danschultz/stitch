# Stitch
Stitch is a Dart package that uses transformers to generate CSS sprite sheets.

## Installation
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
By default, Stitch will look for linked sprite sheets in your HTML files. Linked sprite sheets must have the same name as the directory containing your sprites.

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

The generated CSS file contains classes that reference the images within the sprite sheet. For each image, a class with the naming convention `{folder-name}-{image-name}` will be generated. Each class sets the element's `background-image`, `background-position`, `width` and `height`.

Using the *star.png* and *info.png* sprites in `web/index.html`:

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

### Custom Sprite Sheets
Use `.stitch` files to output specialized sprite sheets. A `.stitch` file is just a YAML file that references a set of assets, how the assets should be laid out, and the formats the sprite sheet should support (CSS, SASS, LESS). Assets can even be referenced from other packages.

**Example:** A `.stitch` file.

```
asset_paths:
  - images/icons/info.png
  - images/icons/star.png
  - packages/social/icons/facebook.png
formats:
  - css
  - sass
```

When transformed, assets will be outputted with the same name as the Stitch file. For instance, if the example `.stitch` file was located at `web/icons.stitch`, the transformer would output `web/icons.png`, `web/icons.css` and `web/icons.sass`.

Stitch files support the following fields:

* `asset_paths`: A list of paths to PNGs that will be included in the sprite sheet. Paths follow the same formatting rules as [Barback](https://www.dartlang.org/tools/pub/assets-and-transformers.html#how-to-refer-to-assets).
* `formats`: A list of formats to output. Note, a PNG is always outputted.

**Note:** Stitch will also recognize files ending with `.stitch.yaml`.

## Todo
* Add support for SASS
* Add support for LESS
* Customization options: padding, sprite layout, etc.
