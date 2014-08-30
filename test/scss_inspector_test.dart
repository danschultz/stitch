library spritely.scss_inspector_test;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/src/transformers.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/stitch.dart';
import 'barback_helpers.dart';

void main() => describe("ScssInspector", () {
  ScssInspector transformer;

  AssetId createAsset(String path) => new AssetId("my_package", path);

  describe("isPrimary()", () {
    beforeEach(() {
      transformer = new ScssInspector(new StitchAssetProvider());
    });

    it("completes with true for SCSS assets", () {
      expect(
          transformer.isPrimary(createAsset("sprites.scss")),
          completion(isTrue));
    });

    it("completes with false for non-SCSS", () {
      expect(
          transformer.isPrimary(createAsset("sprites.sass")),
          completion(isFalse));
    });
  });

  describe("apply()", () {
    String inputContents = '@import "../images/icons";';
    TransformMock transform;
    Mock primaryInput;
    SpriteAssetProviderMock provider;

    void buildTransformer(String html, {List<AssetId> assets: const []}) {
      primaryInput.when(callsTo("readAsString")).alwaysReturn(new Future.value(html));
      provider = new SpriteAssetProviderMock()
          ..when(callsTo("call")).alwaysReturn(new Future.value(assets));
      transformer = new ScssInspector(provider);
    }

    Matcher expectAsset(AssetId id) => predicate((Asset asset) {
      return id == asset.id;
    });

    beforeEach(() {
      transformer = new ScssInspector(new StitchAssetProvider());
      primaryInput = new Mock()
          ..when(callsTo("get id")).alwaysReturn(new AssetId("my_package", "web/sass/styles.scss"));
      transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(primaryInput)
          ..when(callsTo("get logger")).alwaysReturn(new TransformLogger((id, level, message, span) {}));
    });

    describe("when primary input references usage file", () {
      beforeEach(() => buildTransformer(inputContents));

      it("requests provider for assets", () {
        return transformer.apply(transform).then((_) => provider
            .getLogs(callsTo("call", new AssetId("my_package", "web/images/icons")))
            .verify(happenedAtLeastOnce));
      });
    });

    describe("when provider returns empty list of assets", () {
      beforeEach(() => buildTransformer(inputContents));

      it("doesn't add any outputs", () {
        return transformer.apply(transform).then((_) {
          transform.getLogs(callsTo("addOutput")).verify(neverHappened);
        });
      });
    });

    describe("when provider returns list of assets", () {
      beforeEach(() => buildTransformer(
          inputContents,
          assets: [new AssetId("my_package", "web/images/icons/info.png"),
          new AssetId("my_package", "web/images/icons/star.png")]));

      it("adds an output for web/images/icons.scss.stitch.yaml", () {
        return transformer.apply(transform).then((_) {
          var expectation = expectAsset(new AssetId("my_package", "web/images/icons.scss.stitch.yaml"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        });
      });

      it("adds a \$sprite-dir variable for each import that contains sprites", () {
        return transformer.apply(transform).then((_) {
          // We can't inspect the contents of the asset through mocks. For now, just make sure
          // that the primary asset was replaced.
          var expectation = expectAsset(new AssetId("my_package", "web/sass/styles.scss"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        });
      });

      describe("output", () {
        it("contains paths for each asset", () {
          return transformer.apply(transform)
              .then((List<Asset> assets) => assets.first.readAsString())
              .then((yaml) {
                var stitch = new Stitch.fromYaml(yaml);
                expect(stitch.assetPaths, orderedEquals(["icons/info.png", "icons/star.png"]));
              });
        });

        it("format is scss", () {
          transformer.apply(transform)
              .then((List<Asset> assets) => assets.first.readAsString())
              .then(expectAsync((yaml) {
                var stitch = new Stitch.fromYaml(yaml);
                expect(stitch.format, equals("scss"));
              }));
        });
      });
    });
  });
});

class SpriteAssetProviderMock extends Mock implements SpriteAssetProvider {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}