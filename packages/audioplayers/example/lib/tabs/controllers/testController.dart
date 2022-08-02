import 'package:get/get.dart';

class TestController extends GetxController {
  int testvar = 0;
  changeTest(int a) {
    if (testvar == 0)
      testvar = 1;
    else
      testvar = 0;
    update();
  }
}
