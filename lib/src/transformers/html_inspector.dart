part of spritely.transformer;

class HtmlInspector extends InspectorTransformer {
  String get allowedExtensions => ".html .htm";

  RegExp get matcher => new RegExp(r'<link .*href="(.+\.css)">');

  HtmlInspector(SpriteSheetEngine spriteSheetEngine) : super(spriteSheetEngine);

  Asset generateHelper(AssetId id, SpriteSheet spriteSheet) {
    var css = new StringBuffer();

    // .name-asset,
    // .name-asset
    css.writeAll(spriteSheet.sprites
        .take(spriteSheet.sprites.length - 1)
        .map((sprite) => _imageClass(spriteSheet, sprite)), ",\n");

    // ,
    if (spriteSheet.sprites.length > 1) {
      css.writeln(",");
    }

    // .name-asset { ... }
    css.write(_cssBlock(spriteSheet, spriteSheet.sprites.last, [
      "background-image: url('${spriteSheet.name}.png');",
      "background-repeat: no-repeat;"
    ]));

    css.writeln();

    // .name-asset {
    //   width: ...;
    //   height: ...;
    //   background-position: ...;
    // }
    for (var sprite in spriteSheet.sprites) {
      css.writeln(_cssBlock(spriteSheet, sprite, [
        "width: ${sprite.bounds.width}px;",
        "height: ${sprite.bounds.height}px;",
        "background-position: ${-sprite.bounds.left}px ${-sprite.bounds.top}px;"
      ]));
    }

    return new Asset.fromString(id.changeExtension(".css"), css.toString());
  }

  String _imageClass(SpriteSheet spriteSheet, Sprite sprite) {
    return ".${spriteSheet.name}-${pathos.basenameWithoutExtension(sprite.name)}";
  }

  String _cssBlock(SpriteSheet spriteSheet, Sprite sprite, Iterable<String> lines) {
    var css = new StringBuffer()
        ..writeln("${_imageClass(spriteSheet, sprite)} {")
        ..writeAll(lines.map((line) => "  $line"), "\n")
        ..writeln()
        ..writeln("}");
    return css.toString();
  }
}
