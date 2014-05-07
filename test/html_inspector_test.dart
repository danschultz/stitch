library spritely.html_inspector_test;

import 'dart:async';
import 'dart:math';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/transformer.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/sprite_sheet_engine.dart';
import 'package:mock/mock.dart';
import 'package:stitch/src/sprite_sheet.dart';
import 'package:image/image.dart';

void main() => describe("HtmlInspector", () {
  Transformer transformer;

  Asset createAsset(String path, [String content]) {
    return new Asset.fromString(new AssetId("my_package", path), content);
  }

  describe("isPrimary()", () {
    beforeEach(() {
      transformer = new HtmlInspector(new TestSpriteSheetEngine(), new StitchAssetProvider());
    });

    it("returns true for HTML assets", () {
      expect(
          transformer.isPrimary(createAsset("index.html")),
          completion(isTrue));
    });

    it("returns true for HTM assets", () {
      expect(
          transformer.isPrimary(createAsset("index.htm")),
          completion(isTrue));
    });

    it("returns false for non-HTML and non-HTM assets", () {
      expect(
          transformer.isPrimary(createAsset("index.dart")),
          completion(isFalse));
    });
  });

  describe("apply()", () {
    String htmlWithCss = '<html><head><link rel="stylesheet" href="images/icons.css"></head></html>';

    TransformMock transform;
    Mock primaryInput;
    SpriteAssetProviderMock provider;

    void buildTransformer(String html, List<Asset> assets, [SpriteSheet spriteSheet]) {
      primaryInput.when(callsTo("readAsString")).alwaysReturn(new Future.value(html));
      var spriteSheetEngine = new TestSpriteSheetEngine()
          ..when(callsTo("generate")).alwaysReturn(new Future.value(spriteSheet));
      provider = new SpriteAssetProviderMock()
          ..when(callsTo("call")).thenReturn(new Future.value(assets));
      transformer = new HtmlInspector(spriteSheetEngine, provider);
    }

    beforeEach(() {
      transformer = new HtmlInspector(new StitchSpriteSheetEngine(), new StitchAssetProvider());
      primaryInput = new Mock()
          ..when(callsTo("get id")).alwaysReturn(new AssetId("my_package", "index.html"));
      transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(primaryInput)
          ..when(callsTo("get logger")).alwaysReturn(new TransformLogger((id, level, message, span) {}));
    });

    describe("when primary input has linked stylesheets", () {
      beforeEach(() => buildTransformer(htmlWithCss, []));

      it("requests provider for assets", () {
        transformer.apply(transform).then(expectAsync((_) => provider
            .getLogs(callsTo("call", new AssetId("my_package", "images/icons.css")))
            .verify(happenedOnce)));
      });
    });

    describe("when provider returns empty list of assets", () {
      beforeEach(() => buildTransformer(htmlWithCss, []));

      it("no outputs are added to transform", () {
        transformer.apply(transform).then(expectAsync((_) {
          transform.getLogs(callsTo("addOutput")).verify(neverHappened);
        }));
      });
    });

    describe("when provider returns list of assets", () {
      beforeEach(() => buildTransformer(htmlWithCss,
          [createAsset("images/icons/info.png"), createAsset("images/icons/star.png")],
          new SpriteSheet("spritesheet", [
            new Sprite("info.png", new Image(100, 100), new Point(0, 0)),
            new Sprite("star.png", new Image(100, 100), new Point(0, 100))
          ])));

      it("adds an output for images/icons.css", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = _expectAsset(new AssetId("my_package", "images/icons.css"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });

      it("adds an output for images/icons.png", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = _expectAsset(new AssetId("my_package", "images/icons.png"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });
    });
  });
});

Matcher _expectAsset(AssetId id) => predicate((Asset asset) {
  return id == asset.id;
});

class SpriteAssetProviderMock extends Mock implements SpriteAssetProvider {

}

class TransformMock extends Mock implements Transform {

}

class TestSpriteSheetEngine extends Mock implements SpriteSheetEngine {

}
