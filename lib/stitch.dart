library stitch;

import 'package:barback/barback.dart';
import 'package:stitch/src/sprite_sheet_engine.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/transformers.dart';

class StitchTransformer extends TransformerGroup {
  StitchTransformer() : super([
    [new HtmlInspector(new StitchSpriteSheetEngine(), new StitchAssetProvider())]
  ]);
  StitchTransformer.asPlugin() : this();
}
