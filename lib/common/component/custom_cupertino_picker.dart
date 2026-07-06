import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoPicker extends StatefulWidget {
  const CustomCupertinoPicker({super.key});

  @override
  State<CustomCupertinoPicker> createState() => _CustomCupertinoPickerState();
}

class _CustomCupertinoPickerState extends State<CustomCupertinoPicker> {
  late DateTime _selectedDate;
  String _selectedTime = '00';
  List<String> timeList = [];
  late DateTime today;
  late DateTime _date;
  String _time = '00';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 24; i++) {
      timeList.add(i.toString().padLeft(2, '0'));
    }
    var now = DateTime.now();
    today = new DateTime(now.year, now.month, now.day);
    _date = today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a date'),
      ),
      body: Center(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(80.0),
                  child: Text('Picked date and time: ' +
                      _date.year.toString() +
                      ' ' +
                      _date.month.toString() +
                      ' ' +
                      _date.day.toString() +
                      ' ' +
                      _time),
                ),
                CupertinoButton(
                  onPressed: showPicker,
                  child: Text('Pick'),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        setState(() {
                          _date = _selectedDate;
                          _time = _selectedTime;
                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Container(
                    height: 200.0,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Flexible(
                          flex: 8,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: _date,
                            onDateTimeChanged: (DateTime dateTime) {
                              _selectedDate = dateTime;
                            },
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: CupertinoPicker(
                              itemExtent: 38,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedTime = timeList[index];
                                });
                              },
                              children: timeList
                                  .map(
                                    (item) => Center(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList()),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }
}
