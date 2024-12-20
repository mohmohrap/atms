import 'package:flutter/material.dart';
import 'homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InitialPage(),
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: true,
      left: true,
      right: true,
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Column(
            children: [
              const Expanded(
                flex: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ATMS',
                      style:
                          TextStyle(fontSize: 100, fontWeight: FontWeight.w900),
                    ),
                    Text('A TENANT MANAGEMENT SYSTEM'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black12)),
                  child: const Text(
                    'GO TO HOMESCREEN',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    bool isOpened = true;
                    if (isOpened) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    }

                    Navigator.pushNamed(context, '/home');
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
