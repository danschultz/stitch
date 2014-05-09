library spritely.html_inspector_test;

import 'dart:async';
import 'dart:math';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/src/transformers.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/sprite_sheet_engine.dart';
import 'package:mock/mock.dart';
import 'package:stitch/src/sprite_sheet.dart';
import 'package:image/image.dart';
import 'package:csslib/visitor.dart';
import 'package:csslib/parser.dart';

void main() => describe("HtmlInspector", () {
  HtmlInspector transformer;
  TransformMock transform;
  Mock primaryInput;
  SpriteAssetProviderMock provider;

  Asset createAsset(String path, [String content]) {
    return new Asset.fromString(new AssetId("my_package", path), content);
  }

  void buildTransformer(String html, {List<Asset> assets: const [], SpriteSheet spriteSheet}) {
    primaryInput.when(callsTo("readAsString")).alwaysReturn(new Future.value(html));
    var spriteSheetEngine = new TestSpriteSheetEngine()
        ..when(callsTo("generate")).alwaysReturn(new Future.value(spriteSheet));
    provider = new SpriteAssetProviderMock()
        ..when(callsTo("call")).thenReturn(new Future.value(assets));
    transformer = new HtmlInspector(spriteSheetEngine, provider);
  }

  describe("isPrimary()", () {
    beforeEach(() {
      transformer = new HtmlInspector(new TestSpriteSheetEngine(), new StitchAssetProvider());
    });

    it("completes with true for HTML assets", () {
      expect(
          transformer.isPrimary(createAsset("index.html")),
          completion(isTrue));
    });

    it("completes with true for HTM assets", () {
      expect(
          transformer.isPrimary(createAsset("index.htm")),
          completion(isTrue));
    });

    it("completes with false for non-HTML and non-HTM assets", () {
      expect(
          transformer.isPrimary(createAsset("index.dart")),
          completion(isFalse));
    });
  });

  describe("apply()", () {
    String htmlWithCss = '<html><head><link rel="stylesheet" href="images/icons.css"></head></html>';

    beforeEach(() {
      transformer = new HtmlInspector(new StitchSpriteSheetEngine(), new StitchAssetProvider());
      primaryInput = new Mock()
          ..when(callsTo("get id")).alwaysReturn(new AssetId("my_package", "web/index.html"));
      transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(primaryInput)
          ..when(callsTo("get logger")).alwaysReturn(new TransformLogger((id, level, message, span) {}));
    });

    describe("when primary input has linked stylesheets", () {
      beforeEach(() => buildTransformer(htmlWithCss));

      it("requests provider for assets", () {
        transformer.apply(transform).then(expectAsync((_) => provider
            .getLogs(callsTo("call", new AssetId("my_package", "web/images/icons.css")))
            .verify(happenedOnce)));
      });
    });

    describe("when provider returns empty list of assets", () {
      beforeEach(() => buildTransformer(htmlWithCss));

      it("doesn't add any outputs", () {
        transformer.apply(transform).then(expectAsync((_) {
          transform.getLogs(callsTo("addOutput")).verify(neverHappened);
        }));
      });
    });

    describe("when provider returns list of assets", () {
      beforeEach(() => buildTransformer(
          htmlWithCss,
          assets: [createAsset("web/images/icons/info.png"), createAsset("web/images/icons/star.png")],
          spriteSheet: new SpriteSheet("spritesheet", [
            new Sprite("info.png", new Image(100, 100), new Point(0, 0)),
            new Sprite("star.png", new Image(100, 100), new Point(0, 100))
          ])));

      it("adds an output for web/images/icons.css", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = _expectAsset(new AssetId("my_package", "web/images/icons.css"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });

      it("adds an output for web/images/icons.png", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = _expectAsset(new AssetId("my_package", "web/images/icons.png"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });
    });
  });

  describe("generateHelper()", () {
    Asset asset;
    SpriteSheet spriteSheet;

    beforeEach(() {
      spriteSheet = new SpriteSheet("spritesheet", [
        new Sprite("info.png", new Image(100, 100), new Point(0, 0)),
        new Sprite("star.png", new Image(100, 100), new Point(0, 100))
      ]);

      buildTransformer("",
          assets: [createAsset("web/images/icons/info.png"), createAsset("web/images/icons/star.png")],
          spriteSheet: spriteSheet);

      asset = transformer.generateHelper(new AssetId("my_package", "web/images/icons.png"), spriteSheet);
    });

    void _testSpritesForStyle(String style, expectation(Sprite sprite, String value)) {
      asset.readAsString().then(expectAsync((content) {
        var styles = _parseStylesheet(content);
        for (var sprite in spriteSheet.sprites) {
          var className = SpriteSheet.className(spriteSheet, sprite);
          expectation(sprite, styles[className][style]);
        }
      }));
    }

    it("has a .css extension", () {
      expect(asset.id.extension, equals(".css"));
    });

    it("defines a class for each image", () {
      asset.readAsString().then(expectAsync((content) {
        var styles = _parseStylesheet(content);
        expect(styles.keys, unorderedEquals([".spritesheet-info", ".spritesheet-star"]));
      }));
    });

    it("defines the background-image for each image", () {
      _testSpritesForStyle("background-image", (sprite, value) =>
          expect(value.contains("spritesheet.png"), isTrue));
    });

    it("defines the width for each image", () {
      _testSpritesForStyle("width", (sprite, value) =>
          expect(value, equals("${sprite.bounds.width}px")));
    });

    it("defines the height for each image", () {
      _testSpritesForStyle("height", (sprite, value) =>
          expect(value, equals("${sprite.bounds.height}px")));
    });

    it("defines the background-position for each image", () {
      _testSpritesForStyle("background-position", (sprite, value) =>
          expect(value, equals("${-sprite.bounds.left}px ${-sprite.bounds.top}px")));
    });
  });
});

Matcher _expectAsset(AssetId id) => predicate((Asset asset) {
  return id == asset.id;
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

class SpriteAssetProviderMock extends Mock implements SpriteAssetProvider {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TransformMock extends Mock implements Transform {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestSpriteSheetEngine extends Mock implements SpriteSheetEngine {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
