library stitch;

import 'package:barback/barback.dart';
import 'package:stitch/src/sprite_asset_provider.dart';
import 'package:stitch/src/transformers.dart';

class StitchTransformerGroup extends TransformerGroup {
  StitchTransformerGroup() : super([
    [
        new HtmlInspector(new StitchAssetProvider()),
        new ScssInspector(new StitchAssetProvider())
    ],
    [new StitchTransformer.allFormats()]
  ]);

  StitchTransformerGroup.asPlugin() : this();
}
