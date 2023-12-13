import 'package:flutter/material.dart';
import 'dailyexpenses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController apiAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image:
                      "https://w7.pngwing.com/pngs/978/821/png-transparent-money-finance-wallet-payment-daily-expenses-saving-service-personal-finance.png")
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Hide the password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: apiAddressController,
                  decoration: const InputDecoration(
                    labelText: 'REST API address',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement login logic here
                  String username = usernameController.text;
                  String password = passwordController.text;
                  String apiAddress = apiAddressController.text;

                  // Validate username and password
                  if (username == 'zahir' && password == 'zahir') {
                    // Save API address to SharedPreferences
                    saveApiAddress(apiAddress);

                    // Navigate to the daily expense screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyExpensesApp(username: username),
                      ),
                    );
                  } else {
                    // Show an error message for invalid login
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Login Failed'),
                          content: const Text('Invalid username or password.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save API address to SharedPreferences
  Future<void> saveApiAddress(String apiAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiAddress', apiAddress);
  }
}
