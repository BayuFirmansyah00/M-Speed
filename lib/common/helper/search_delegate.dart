// import 'package:mspeed/helper/constant.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:flutter/material.dart';

class XSearchDelegate<T> extends SearchDelegate {
  final Widget Function(T result, String query) onResult;
  final Future<T> Function(String query) onSubmit;

  XSearchDelegate({required this.onResult, required this.onSubmit});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            close(context, null);
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Icon(
      Icons.search,
      color: Constant.primaryColor,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: onSubmit(query),
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        if (isLoading) {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator.adaptive(),
          );
        } else if (snapshot.hasError) {
          return Container(
            alignment: Alignment.center,
            child: Text(snapshot.error?.toString() ?? 'Error tidak diketahui.'),
          );
        } else if (snapshot.hasData) {
          return onResult(snapshot.data!, query);
        } else {
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
