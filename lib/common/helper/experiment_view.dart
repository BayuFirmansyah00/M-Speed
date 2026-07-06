import 'package:flutter/material.dart';
import '../component/custom_date_picker.dart';

class ExperimentView extends StatefulWidget {
  const ExperimentView({Key? key}) : super(key: key);

  @override
  _ExperimentViewState createState() => _ExperimentViewState();
}

class _ExperimentViewState extends State<ExperimentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            dynamic f = await CustomDatePicker.pickTime(context);
          },
          child: Text("Click me!"),
        ),
      ),
    );
  }
}
