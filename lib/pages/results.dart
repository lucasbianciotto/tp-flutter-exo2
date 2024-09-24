import 'package:exo2/components.dart';
import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  final String operation;

  const ResultsPage({super.key, required this.operation});

  @override
  State<ResultsPage> createState() => _ResultsPageState();

}

class _ResultsPageState extends State<ResultsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
      ),
      body: Center(
        child: MyText(widget.operation),
      ),
    );
  }
}