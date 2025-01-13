import 'package:flutter/material.dart';

class ChartOptionsPage extends StatefulWidget {
  final String currentOption;
  final ValueChanged<String> onOptionSelected;

  const ChartOptionsPage({
    Key? key,
    required this.currentOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  _ChartOptionsPageState createState() => _ChartOptionsPageState();
}

class _ChartOptionsPageState extends State<ChartOptionsPage> {
  late String selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentOption;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Options'),
        backgroundColor: isDarkMode ? const Color(0xFF122E31) : const Color(0xFF317B85),
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('Weekly'),
            value: 'Weekly',
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Monthly'),
            value: 'Monthly',
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Yearly'),
            value: 'Yearly',
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value!;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onOptionSelected(selectedOption);
                Navigator.pop(context);
              },
              child: const Text('Save Selection'),
            ),
          ),
        ],
      ),
    );
  }
}
