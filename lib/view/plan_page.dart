import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  Map<String, List<TextEditingController>> _controllers = {};
  Map<String, List<bool>> _isComplete = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPlans();
  }

  void _initializeControllers() {
    for (var day in _days) {
      _controllers[day] = List.generate(5, (_) => TextEditingController());
      _isComplete[day] = List.generate(5, (_) => false);
    }
  }

  Future<void> _loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var day in _days) {
        for (int i = 0; i < 5; i++) {
          _controllers[day]?[i].text =
              prefs.getString('$day-task${i + 1}') ?? '';
          _isComplete[day]?[i] =
              prefs.getBool('$day-isComplete${i + 1}') ?? false;
        }
      }
    });
  }

  Future<void> _savePlans() async {
    final prefs = await SharedPreferences.getInstance();
    for (var day in _days) {
      for (int i = 0; i < 5; i++) {
        await prefs.setString(
            '$day-task${i + 1}', _controllers[day]?[i].text ?? '');
        await prefs.setBool(
            '$day-isComplete${i + 1}', _isComplete[day]?[i] ?? false);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rencana disimpan!')),
    );
  }

  @override
  void dispose() {
    for (var day in _days) {
      for (var controller in _controllers[day]!) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Mingguan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(_days.length, (index) {
                  String day = _days[index];
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...List.generate(5, (i) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controllers[day]?[i],
                                    decoration: InputDecoration(
                                      hintText: 'Rencana ${i + 1}',
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: _isComplete[day]?[i],
                                  onChanged: (value) {
                                    setState(() {
                                      _isComplete[day]?[i] = value!;
                                    });
                                  },
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            FloatingActionButton(
              onPressed: _savePlans,
              child: const Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
