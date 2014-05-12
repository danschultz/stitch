library spritely.tests;

import 'html_inspector_test.dart' as htmlInspectorTest;
import 'output_test.dart' as outputTest;
import 'css_output_test.dart' as cssOutputTest;
import 'stitcher_test.dart' as stitcherTest;

void main() {
  htmlInspectorTest.main();
  outputTest.main();
  cssOutputTest.main();
  stitcherTest.main();
}