library stitch.scss_output_test;

import 'dart:math';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:stitch/src/outputs.dart';
import 'package:stitch/src/sprite.dart';
import 'package:image/image.dart';
import 'package:csslib/visitor.dart';
import 'package:csslib/parser.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:path/path.dart' as pathos;

void main() => describe("ScssOutput", () {
  describe("renderSprites()", () {
    List<Sprite> sprites;
    Asset primaryInput;
    String sheetName;

    beforeEach(() {
      sprites = [new Sprite("info", new Image(100, 50), new Point(0, 0)),
                 new Sprite("star", new Image(25, 25), new Point(100, 50))];
      primaryInput = new Asset.fromString(new AssetId("my_package", "path/to/some.scss.stitch"), "");
      sheetName = pathos.basenameWithoutExtension(primaryInput.id.path);
    });

    void _testSpritesForStyle(Asset asset, String style, expectation(Sprite sprite, String value)) {
      asset.readAsString().then(expectAsync((content) {
        var styles = _parseStylesheet(content);
        for (var sprite in sprites) {
          var className = ".$sheetName-${sprite.name}";
          expectation(sprite, styles[className][style]);
        }
      }));
    }

    Asset _renderOutput() => new ScssOutput().generate(primaryInput, sprites).first;

    it("returns an asset with a .scss extension", () {
      var asset = _renderOutput();
      expect(asset.id.extension, equals(".scss"));
    });

    it("returns an asset prefixed with an underscore", () {
      var asset = _renderOutput();
      var name = pathos.basenameWithoutExtension(asset.id.path);
      expect(name, startsWith("_"));
    });

    it("defines a class for each image", () {
      var asset = _renderOutput();
      asset.readAsString().then(expectAsync((content) {
        var styles = _parseStylesheet(content);
      }));
    });
  });
});

Map<String, Map<String, String>> _parseStylesheet(String input) {
  var visitor = new _CssVisitor();
  parse(input).visit(visitor);
  return visitor.styles;
}

class _CssVisitor extends Visitor {
  Map<String, Map<String, String>> styles = {};

  Iterable<Map<String, String>> _currentStyleGroup;

  void visitSelectorGroup(SelectorGroup node) {
    var group = [];
    for (var selector in node.selectors) {
      if (!styles.containsKey(selector.span.text)) {
        styles[selector.span.text] = {};
      }
      group.add(styles[selector.span.text]);
    }
    _currentStyleGroup = group;
    super.visitSelectorGroup(node);
  }

  void visitDeclaration(Declaration node) {
    _currentStyleGroup.forEach((style) {
      style[node.property] = node.span.text.split(":").last.trim();
    });
  }
}