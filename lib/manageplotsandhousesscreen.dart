import 'package:flutter/material.dart';
import 'sql.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        // Remove the debug banner

        home: ManagePlotsAndHousesScreen());
  }
}

class ManagePlotsAndHousesScreen extends StatefulWidget {
  const ManagePlotsAndHousesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManagePlotsAndHousesScreenState createState() =>
      _ManagePlotsAndHousesScreenState();
}

class _ManagePlotsAndHousesScreenState
    extends State<ManagePlotsAndHousesScreen> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    // Loading the diary when the app starts
  }

  // Show month selection dialog
  void _openMonthPicker(BuildContext context, int index) {
    /*final selectedMonths =
        Set<int>.from(_journals[index]['selectedMonths'] ?? []);*/

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Months"),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, monthIndex) {
                  // final isSelected = selectedMonths.contains(monthIndex);
                  return GestureDetector(
                    onTap: () async {
                      /*
                      setState(() {
                        if (isSelected) {
                          selectedMonths.remove(monthIndex);
                        } else {
                          selectedMonths.add(monthIndex);
                        }
                      });

                      await SQLHelper.updateItem(
                        _journals[index]['id'],
                        _journals[index]['plotName'],
                        _journals[index]['houseName'],
                        _journals[index]['tenantName'],
                      );
                    */
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // color: isSelected ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        [
                          "J",
                          "F",
                          "M",
                          "A",
                          "M",
                          "J",
                          "J",
                          "A",
                          "S",
                          "O",
                          "N",
                          "D"
                        ][monthIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          title: const Text('PAYMENT STATUS'),
        ),
        backgroundColor: Colors.blueGrey,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _journals.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.blueGrey,
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    tileColor: Colors.white10,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _journals[index]['plotName'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          _journals[index]['houseName'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          _journals[index]['tenantName'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _openMonthPicker(context, index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                      child: const Text(
                        "Monthly payment",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
