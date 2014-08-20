library stitch.output_test;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:guinness/guinness.dart';
import 'package:stitch/src/outputs.dart';
import 'package:stitch/src/stitch.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart' hide expect;

import 'barback_helpers.dart';
import 'dart:io';

void main() => describe("Output", () {
  describe("render()", () {
    Asset primaryInput;
    TransformMock transform;
    Stitch stitch;

    beforeEach(() {
      var assets = ["star.png", "info.png"];
      stitch = new Stitch(assets);
      primaryInput = new Asset.fromString(new AssetId("my_package", "stuff.ext.stitch"), "");
      transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(primaryInput)
          ..when(callsTo("readInput", new AssetId("my_package", assets.first))).thenReturn(
              new Stream.fromIterable([_testImage]))
          ..when(callsTo("readInput", new AssetId("my_package", assets.last))).thenReturn(
              new Stream.fromIterable([_testImage]));
    });

    void render(void expectations(List<Sprite> sprites, Asset primaryInput)) {
      var output = new OutputTestSubject();
      output.render(stitch, transform).then(expectAsync((_) {
        expectations(output.sprites, output.primaryInput);
      }));
    }

    it("calls renderSprites() with sprites sorted by name", () {
      render((List<Sprite> sprites, Asset primaryInput) {
        expect(sprites.map((sprite) => sprite.name), orderedEquals(["info", "star"]));
      });
    });

    it("calls renderSprites() with primary input", () {
      render((List<Sprite> sprites, Asset input) {
        expect(input).toBe(primaryInput);
      });
    });
  });
});

class OutputTestSubject extends Output {
  String get extension => ".ext";

  List<Sprite> sprites;
  Asset primaryInput;

  @override
  Asset renderSprites(List<Sprite> sprites, Asset primaryInput) {
    this.sprites = sprites;
    this.primaryInput = primaryInput;
    return new Asset.fromString(primaryInput.id.changeExtension(extension), "");
  }
}

final _testImage = new File("test/images/info.png").readAsBytesSync();