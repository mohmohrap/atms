import 'package:flutter/material.dart';
import 'package:atms/search.dart';
import 'package:atms/sql.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        // Remove the debug banner

        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
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
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _plotNameController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _tenantNameController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _plotNameController.text = existingJournal['plotName'];
      _houseNameController.text = existingJournal['houseName'];
      _tenantNameController.text = existingJournal['tenantName'];
    }

    showModalBottomSheet(
        useSafeArea: true,
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        enableDrag: true,
        backgroundColor: Colors.grey[100],
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 1,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      maxLength: 25,
                      controller: _plotNameController,
                      decoration: const InputDecoration(
                        labelText: 'Plot name',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      maxLength: 10,
                      controller: _houseNameController,
                      decoration: const InputDecoration(
                        labelText: 'House name',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      maxLength: 30,
                      controller: _tenantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tenant name and details',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blueGrey)),
                      onPressed: () async {
                        if (_houseNameController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                icon: const Icon(Icons.error_outline, size: 60),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                title: const Text('Not Saved'),
                                content: const Text(
                                    'You must enter a house name, if none write empty'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Ok'))
                                ],
                              );
                            },
                          );
                          return; //stop execution if house name is empty
                        }

                        // Save new journal
                        if (id == null) {
                          await _addItem();
                        }

                        if (id != null) {
                          await _updateItem(id);
                        }

                        // Clear the text fields
                        _plotNameController.text = '';
                        _houseNameController.text = '';
                        _tenantNameController.text = '';

                        // Close the bottom sheet
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Add New' : 'Update details'),
                    )
                  ],
                ),
              ),
            )).then((value) {
      _houseNameController.text = '';
      _tenantNameController.text = '';
      _plotNameController.text = '';
    });
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_plotNameController.text,
        _houseNameController.text, _tenantNameController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _plotNameController.text,
        _houseNameController.text, _tenantNameController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('You deleted something'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: true,
      left: true,
      right: true,
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()));
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 24,
                  )),
            )
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey,
          elevation: 4,
          title: const Text('TENANT MANAGEMENT SYSTEM'),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
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
                        Text(_journals[index]['plotName'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                        Text(_journals[index]['houseName'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    subtitle: Text(_journals[index]['tenantName'],
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 14)),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.edit_document),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.delete),
                            onPressed: () => showDialog(
                              useSafeArea: true,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  title: const Text(
                                      "Details will be permanently deleted"),
                                  content: const Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("No",
                                          style:
                                              TextStyle(color: Colors.green)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        _deleteItem(_journals[index]['id']);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          mini: true,
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.add_circle, size: 50, color: Colors.white),
          onPressed: () => _showForm(null),
        ),
      ),
    );
  }
}
