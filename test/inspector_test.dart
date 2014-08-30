library stitch.inspector_test;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/transformers.dart';
import 'package:stitch/src/stitch.dart';
import 'barback_helpers.dart';

void testApply(String inputContent, InspectorTransformer transformerProvider(SpriteAssetProvider assets)) {
  InspectorTransformer transformer;
  TransformMock transform;
  Mock primaryInput;
  SpriteAssetProviderMock provider;

  Matcher expectAsset(AssetId id) => predicate((Asset asset) {
    return id == asset.id;
  });

  void buildTransformer({List<AssetId> assets: const []}) {
    primaryInput.when(callsTo("readAsString")).alwaysReturn(new Future.value(inputContent));
    provider = new SpriteAssetProviderMock()
        ..when(callsTo("call")).thenReturn(new Future.value(assets));
    transformer = transformerProvider(provider);
  }

  describe("apply()", () {
    beforeEach(() {
      transformer = transformerProvider(new StitchAssetProvider());
      primaryInput = new Mock()
          ..when(callsTo("get id")).alwaysReturn(new AssetId("my_package", "web/index.html"));
        transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(primaryInput)
          ..when(callsTo("get logger")).alwaysReturn(new TransformLogger((id, level, message, span) {}));
    });

    describe("when primary input references usage file", () {
      beforeEach(() => buildTransformer());

      it("requests provider for assets", () {
        transformer.apply(transform).then(expectAsync((_) => provider
            .getLogs(callsTo("call", new AssetId("my_package", "web/images/icons.css")))
            .verify(happenedOnce)));
      });
    });

    describe("when provider returns empty list of assets", () {
      beforeEach(() => buildTransformer());

      it("doesn't add any outputs", () {
        transformer.apply(transform).then(expectAsync((_) {
          transform.getLogs(callsTo("addOutput")).verify(neverHappened);
        }));
      });
    });

    describe("when provider returns list of assets", () {
      beforeEach(() => buildTransformer(assets: [
        new AssetId("my_package", "web/images/icons/info.png"),
        new AssetId("my_package", "web/images/icons/star.png")
      ]));

      it("adds an output for web/images/icons.css.stitch", () {
        transformer.apply(transform).then(expectAsync((_) {
          var expectation = expectAsset(new AssetId("my_package", "web/images/icons.css.stitch"));
          transform.getLogs(callsTo("addOutput", expectation)).verify(happenedOnce);
        }));
      });

      describe("output", () {
        it("contains paths for each asset", () {
          transformer.apply(transform)
              .then((List<Asset> assets) => assets.first.readAsString())
              .then(expectAsync((yaml) {
                var stitch = new Stitch.fromYaml(yaml);
                expect(stitch.assetPaths, orderedEquals(["icons/info.png", "icons/star.png"]));
              }));
        });
      });
    });
  });
}

class SpriteAssetProviderMock extends Mock implements SpriteAssetProvider {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}