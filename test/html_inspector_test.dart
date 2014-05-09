library spritely.html_inspector_test;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/src/transformers.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:mock/mock.dart';
import 'barback_helpers.dart';
import 'package:stitch/src/stitch.dart';

void main() => describe("HtmlInspector", () {
  HtmlInspector transformer;
  TransformMock transform;
  Mock primaryInput;
  SpriteAssetProviderMock provider;

  Asset createAsset(String path, [String content = ""]) {
    return new Asset.fromString(new AssetId("my_package", path), content);
  }

  void buildTransformer(String html, {List<AssetId> assets: const []}) {
    primaryInput.when(callsTo("readAsString")).alwaysReturn(new Future.value(html));
    provider = new SpriteAssetProviderMock()
        ..when(callsTo("call")).thenReturn(new Future.value(assets));
    transformer = new HtmlInspector(provider);
  }

  describe("isPrimary()", () {
    beforeEach(() {
      transformer = new HtmlInspector(new StitchAssetProvider());
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
      transformer = new HtmlInspector(new StitchAssetProvider());
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
          assets: [new AssetId("my_package", "web/images/icons/info.png"),
                   new AssetId("my_package", "web/images/icons/star.png")]));

      it("adds an output for web/images/icons.stitch", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = _expectAsset(new AssetId("my_package", "web/images/icons.stitch"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });

      describe("output", () {
        it("contains paths for each asset", () {
          transformer.apply(transform)
              .then((List<Asset> assets) => assets.first.readAsString())
              .then(expectAsync((yaml) {
                var stitch = new Stitch.fromYaml(yaml);
                expect(stitch.assets, orderedEquals([new AssetId("my_package", "web/images/icons/info.png"),
                                                     new AssetId("my_package", "web/images/icons/star.png")]));
              }));
        });

        it("lists css format", () {
          transformer.apply(transform)
              .then((assets) => assets.first.readAsString())
              .then(expectAsync((yaml) {
                var stitch = new Stitch.fromYaml(yaml);
                expect(stitch.formats, contains(".css"));
              }));
        });
      });
    });
  });
});

Matcher _expectAsset(AssetId id) => predicate((Asset asset) {
  return id == asset.id;
});

class SpriteAssetProviderMock extends Mock implements SpriteAssetProvider {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
