import 'dart:core';
import 'package:flutter/material.dart';
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

        home: SearchScreen());
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _journals = []; // List to store search results
  bool _isLoading = false; // Flag to indicate if data is being loaded

  List<Map<String, dynamic>> _searchResults =
      []; // List to store filtered search results

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Call _refreshJournals to fetch data from the database
  }

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100))),
            backgroundColor: Colors.blueGrey,
            title: const Text('TENANT MANAGEMENT SYSTEM')),
        backgroundColor: Colors.blueGrey,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchResults = _journals
                        .where((journal) =>
                            journal['plotName']
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            journal['tenantName']
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  hintText: 'Enter text to search',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white, size: 30),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            tileColor: Colors.blueGrey,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_searchResults[index]['plotName'],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                Text(_searchResults[index]['houseName'],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ],
                            ),
                            trailing: Text(_searchResults[index]['tenantName'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
