library spritely.sprite_sheet_test;

import 'dart:math';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' hide expect;
import 'package:stitch/src/sprite_sheet.dart';
import 'package:image/image.dart';

void main() => describe("SpriteSheet", () {
  SpriteSheet spriteSheet;

  describe(".sprites", () {
    it("are sorted by sprite name", () {
      var spriteSheet = new SpriteSheet("sheet", [new Sprite("zzz", null, null), new Sprite("aaa", null, null)]);
      expect(spriteSheet.sprites.map((sprite) => sprite.name), orderedEquals(["aaa", "zzz"]));
    });
  });

  describe("generateImage()", () {
    beforeEach(() {
      spriteSheet = new SpriteSheet("sheet", [
        new Sprite("aaa", new Image(100, 200), new Point(0, 0)),
        new Sprite("zzz", new Image(50, 50), new Point(100, 200))
      ]);
    });

    it("returns image with size of the union of its sprites", () {
      var image = spriteSheet.generateImage();
      expect(image.width).toBe(150);
      expect(image.height).toBe(250);
    });
  });
});
