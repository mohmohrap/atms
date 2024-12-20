import 'package:flutter/material.dart';
import 'package:atms/search.dart';
import 'package:atms/sql.dart';
import 'manageplotsandhousesscreen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
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
  //Set<int> _selectedMonths = {}; //initialize selected months as an empty set
  bool _isLoading = true;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Map<String, List<String>> plotHouseNames = {};
  void validateAndSaveHouse(String houseName, String plotName, int? id) {
    // If the plot name doesn't exist in the map, initialize it with an empty list
    if (!plotHouseNames.containsKey(plotName)) {
      plotHouseNames[plotName] = [];
    }

    // Check for a duplicate house name
    if (plotHouseNames[plotName]!.contains(houseName)) {
      showDuplicateHouseNameDialog();
    } else {
      // If no duplicate, save the house name and proceed
      setState(() {
        plotHouseNames[plotName]!
            .add(houseName); // Add the new house name to the plot
      });

      // If it's a new entry, proceed with saving it to the database
      if (id == null) {
        _addItem();
      } else {
        _updateItem(
            id); // If updating an existing entry, call the update method
      }

      // Clear text fields after saving
      _plotNameController.clear();
      _houseNameController.clear();
      _tenantNameController.clear();
      _phoneNumberController.clear();

      // Close the bottom sheet/modal after saving the item
      Navigator.of(context).pop();
    }
  }

  void showDuplicateHouseNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Duplicate house name"),
          content:
              const Text("Please use a name not already in the current plot"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

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
  final TextEditingController _phoneNumberController = TextEditingController();
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
      _phoneNumberController.text = existingJournal['phoneNumber'];
      /*_selectedMonths = Set<int>.from(existingJournal['selectedMonths'] ?? []);*/
    } /*else {
      _selectedMonths = {};
    }*/

    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
        backgroundColor: Colors.grey[100],
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.7,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                    // this will prevent the soft keyboard from covering the text fields
                    bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _journals
                              .map((e) => e['plotName'] as String)
                              .toSet()
                              .where((option) => option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _plotNameController.text = selection;
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          fieldController.text = _plotNameController.text;
                          fieldController.addListener(() {
                            _plotNameController.text = fieldController.text;
                          });
                          return TextField(
                            maxLength: 25,
                            controller: fieldController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Plot Name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _journals
                              .map((e) => e['houseName'] as String)
                              .toSet()
                              .where((option) => option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _houseNameController.text = selection;
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          fieldController.text = _houseNameController.text;
                          fieldController.addListener(() {
                            _houseNameController.text = fieldController.text;
                          });
                          return TextField(
                            maxLength: 25,
                            controller: fieldController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'House name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 30,
                        controller: _tenantNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tenant name',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 15,
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Tenant phone number',
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
                                WidgetStatePropertyAll(Colors.blueGrey)),
                        onPressed: () async {
                          if (_plotNameController.text.isEmpty ||
                              _houseNameController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  icon:
                                      const Icon(Icons.error_outline, size: 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  title: const Text('Not Saved'),
                                  content: const Text(
                                    'You must enter plot & house names',
                                    textAlign: TextAlign.center,
                                  ),
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

                          /*validateAndSaveHouse(_houseNameController.text,
                              _plotNameController.text, id);*/

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
                          _phoneNumberController.text = '';

                          // Close the bottom sheet
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          id == null ? 'Add New' : 'Update details',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).then((value) {
      _houseNameController.text = '';
      _tenantNameController.text = '';
      _plotNameController.text = '';
      _phoneNumberController.text = '';
    });
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _plotNameController.text,
      _houseNameController.text,
      _tenantNameController.text,
      // _selectedMonths.toList(),
      _phoneNumberController.text,
    );
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
      id,
      _plotNameController.text,
      _houseNameController.text,
      _tenantNameController.text,
      // _selectedMonths.toList(),
      _phoneNumberController.text,
    );
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
        resizeToAvoidBottomInset: true,
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
                    tileColor: const Color.fromRGBO(255, 255, 255, 0.102),
                    title: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_journals[index]['plotName'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            Text(_journals[index]['houseName'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            Text(_journals[index]['tenantName'],
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(_journals[index]['phoneNumber'],
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: 14)),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            color: Colors.green,
                            icon: const Icon(Icons.call),
                            onPressed: () {
                              String phoneNumber =
                                  _journals[index]['phoneNumber'];
                              _makePhoneCall(phoneNumber);
                            },
                          ),
                          IconButton(
                            color: Colors.grey[800],
                            icon: const Icon(Icons.mode_edit_sharp),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            color: Colors.red[150],
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ManagePlotsAndHousesScreen()));
                },
                label: const Text(
                  "Manage Payment",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
              FloatingActionButton(
                elevation: 0,
                mini: true,
                backgroundColor: Colors.blueGrey,
                child:
                    const Icon(Icons.add_circle, size: 50, color: Colors.white),
                onPressed: () => _showForm(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
