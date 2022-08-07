import 'package:cloud_media/tabs/controllers/testController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestUi extends StatelessWidget {
  const TestUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Row(
          children: [
            GetBuilder<TestController>(
                init: TestController(),
                builder: (c) => MaterialButton(
                      onPressed: () {
                        c.changeTest(1);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        color: c.testvar == 0 ? Colors.green : Colors.grey,
                        width: 50,
                        height: 30,
                        child: Text(c.testvar.toString()),
                      ),
                    )),
          ],
        )
      ]),
    );
  }
}
