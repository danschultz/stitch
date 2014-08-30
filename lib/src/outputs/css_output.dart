part of stitch.outputs;

class CssOutput extends Output {
  String get extension => ".css";

  @override
  Asset buildAsset(Asset stitchAsset, Iterable<Sprite> sprites) {
    var name = pathos.basenameWithoutExtension(stitchAsset.id.path).split(".").first;
    var css = new StringBuffer();

    // .name-asset,
    // .name-asset
    css.writeAll(sprites
        .take(sprites.length - 1)
        .map((sprite) => _className(name, sprite)), ",\n");

    // ,
    if (sprites.length > 1) {
      css.writeln(",");
    }

    // .name-asset { ... }
    css.write(_cssBlock(_className(name, sprites.last), [
      "background-image: url('$name.css.png');",
      "background-repeat: no-repeat;"
    ]));

    css.writeln();

    // .name-asset {
    //   width: ...;
    //   height: ...;
    //   background-position: ...;
    // }
    for (var sprite in sprites) {
      css.writeln(_cssBlock(_className(name, sprite), [
        "width: ${sprite.bounds.width}px;",
        "height: ${sprite.bounds.height}px;",
        "background-position: ${-sprite.bounds.left}px ${-sprite.bounds.top}px;"
      ]));
    }

    return new Asset.fromString(stitchAsset.id, css.toString());
  }

  String _cssBlock(String className, Iterable<String> lines) {
    var css = new StringBuffer()
        ..writeln("$className {")
        ..writeAll(lines.map((line) => "  $line"), "\n")
        ..writeln()
        ..writeln("}");
    return css.toString();
  }

  String _className(String assetName, Sprite sprite) =>
      ".$assetName-${pathos.basenameWithoutExtension(sprite.name)}";
}