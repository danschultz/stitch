library spritely.tests;

import 'html_inspector_test.dart' as htmlInspectorTest;
import 'scss_inspector_test.dart' as scssInspectorTest;
import 'css_output_test.dart' as cssOutputTest;
import 'scss_output_test.dart' as scssOutputTest;
import 'stitch_transformer_test.dart' as stitcherTest;

void main() {
  htmlInspectorTest.main();
  cssOutputTest.main();
  scssOutputTest.main();
  stitcherTest.main();

  // TODO(Dan): Need to investigate why scss tests are failing
  // scssInspectorTest.main();
}
