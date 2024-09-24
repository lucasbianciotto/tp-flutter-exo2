import 'package:exo2/consts.dart';
import 'package:exo2/models/history_entry.dart';
import 'package:exo2/pages/results.dart';
import 'package:exo2/repositories/history_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'components.dart';
import 'database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryDatabase().open();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculatrice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Calculatrice'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final repo = HistoryEntryRepository();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double firstNumber = 0;
  double secondNumber = 0;
  late Future<List<HistoryEntry>> _history;
  late final DateFormat _dateTimeFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((value) =>
    _dateTimeFormat = DateFormat.yMd('fr').add_jm());
    _history = widget.repo.getAll();
  }

  _displayResult(String operation) {
    if (!formKey.currentState!.validate()) return;

    formKey.currentState!.save();
    widget.repo.insert(HistoryEntry(_calculate(operation)));

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultsPage(operation: _calculate(operation),))).then((value) {
      formKey.currentState!.reset();
      setState(() {
        formKey.currentState?.reset();
        _history = HistoryEntryRepository().getAll();
      });
    });
  }

  _calculate(String operation) {
    switch (operation) {
      case "+":
        return "${firstNumber.toString()} + ${secondNumber.toString()} = ${firstNumber + secondNumber}";
      case "-":
        return "${firstNumber.toString()} - ${secondNumber.toString()} = ${firstNumber - secondNumber}";
      case "*":
        return "${firstNumber.toString()} * ${secondNumber.toString()} = ${firstNumber * secondNumber}";
      case "/":
        return "${firstNumber.toString()} / ${secondNumber.toString()} = ${firstNumber / secondNumber}";
      default:
        return 0;
    }
  }

  _operandValidator(value) {
    if (value == null || value.isEmpty || double.tryParse(value) == null) {
      return "Veuillez saisir un nombre";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) => _operandValidator(value),
                    onSaved: (value) => firstNumber = double.parse(value!),
                    decoration: const InputDecoration(
                      labelStyle: defaultTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) => _operandValidator(value),
                    onSaved: (value) => secondNumber = double.parse(value!),
                    decoration: const InputDecoration(
                      labelStyle: defaultTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () => _displayResult("+"),
                    child: const MyText("+"),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () => _displayResult("-"),
                    child: const MyText("-"),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () => _displayResult("*"),
                    child: const MyText("*"),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () => _displayResult("/"),
                    child: const MyText("/"),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const MyPadding(
                  child: MyText("Historique", key: ValueKey("history")),
                ),
                FutureBuilder<List<HistoryEntry>>(
                  future: _history,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const MyText("Erreur lors de la récupération de l'historique");
                    }
                    if (snapshot.data!.isEmpty) {
                      return const MyText("Aucune opération effectuée");
                    }
                    return Column(
                      children: snapshot.data!.map((entry) {
                        return ListTile(
                          title: MyText(entry.operation),
                          subtitle: MyText(_dateTimeFormat.format(entry.date)),
                          subtitleTextStyle: const TextStyle(color: Colors.grey, fontSize: 5),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
