import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // clickable GitHub link

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee',
      debugShowCheckedModeBanner: false,
      // Lab 5/6: warna tema aplikasi
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text field controllers
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String? weightError;
  String? rateError;

  // Selected ticket class
  String? selectedClass = 'Economy';

  // Screen names: welcome, calculator, result, about
  String currentScreen = 'welcome';

  // Calculation results
  double baggageWeight = 0;
  double allowedWeight = 0;
  double excessWeight = 0;
  double baggageRate = 0;
  double excessCharge = 0;
  double serviceTax = 0;
  double totalAmount = 0;

  // Get baggage allowance
  double getAllowedWeight() {
    if (selectedClass == 'Economy') {
      return 20;
    } else {
      return 40;
    }
  }

  // Show message using SnackBar
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Show ticket class information dialog
  void showTicketInformation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info, color: Colors.deepPurple, size: 40),
          title: const Text('About Ticket Class', textAlign: TextAlign.center),
          content: const Text(
            'Economy: Maximum baggage allowance is 20 kg.\n\n'
            'Business: Maximum baggage allowance is 40 kg.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Lab 4 + Lab 5: Check user input
  // The assignment allows decimal values such as 42.5 kg.

  String? checkInput(String value) {
    double? number = double.tryParse(value);

    if (value.trim().isEmpty) {
      return 'Please enter a number.';
    } else if (number == null || !number.isFinite || number < 0) {
      return 'Please enter a valid number.';
    } else if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Maximum 2 decimal places allowed.';
    }

    return null;
  }

  void calculateFee() {
    String weightText = weightController.text.trim();
    String rateText = rateController.text.trim();

    double? weight = double.tryParse(weightText);
    double? rate = double.tryParse(rateText);

    setState(() {
      weightError = checkInput(weightText);
      rateError = checkInput(rateText);
    });

    if (weightError != null || rateError != null) {
      return;
    }

    // Calculate baggage fee
    baggageWeight = weight!;
    baggageRate = rate!;
    allowedWeight = getAllowedWeight();

    if (baggageWeight > allowedWeight) {
      excessWeight = baggageWeight - allowedWeight;
    } else {
      excessWeight = 0;
    }

    excessCharge = excessWeight * baggageRate;
    serviceTax = excessCharge * 0.08;
    totalAmount = excessCharge + serviceTax;

    if (!totalAmount.isFinite) {
      setState(() {
        rateError = 'Amount is too large.';
      });
      return;
    }

    setState(() {
      currentScreen = 'result';
    });
  }

  // Reset calculator
  void resetCalculator() {
    weightController.clear();
    rateController.clear();

    setState(() {
      selectedClass = 'Economy';
      baggageWeight = 0;
      allowedWeight = 0;
      excessWeight = 0;
      baggageRate = 0;
      excessCharge = 0;
      serviceTax = 0;
      totalAmount = 0;
      currentScreen = 'calculator';
      weightError = null;
      rateError = null;
    });
  }

  // Return to welcome page
  void goToHome() {
    setState(() {
      currentScreen = 'welcome';
    });
  }

  // button must open the GitHub URL.
  // url_launcher is the one additional package beyond Labs 1-5.
  Future<void> openGitHub() async {
    final Uri githubUrl = Uri.parse(
      'https://github.com/nazwaeizurin/baggage_fee_calculator',
    );

    try {
      if (!await launchUrl(githubUrl, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          showMessage('Could not open the GitHub repository.');
        }
      }
    } catch (e) {
      if (mounted) {
        showMessage('Could not open the GitHub repository.');
      }
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = 'Excess Baggage Fee';
    if (currentScreen == 'about') {
      pageTitle = 'About';
    } else if (currentScreen == 'result') {
      pageTitle = 'Calculation Result';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // Navigation menu (Drawer): the hamburger icon appears in the AppBar.
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 70,
              color: Colors.deepPurple,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'Excess Baggage Fee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // An extra Calculator choice on the Welcome page.
            if (currentScreen != 'welcome')
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentScreen = 'welcome';
                  });
                },
              ),

            if (currentScreen == 'welcome' || currentScreen == 'about')
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Calculator'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentScreen = 'calculator';
                  });
                },
              ),

            if (currentScreen != 'about')
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentScreen = 'about';
                  });
                },
              ),
          ],
        ),
      ),

      // Lab 6: SafeArea keeps the body away from system UI areas.
      // The existing pages use SingleChildScrollView for long content.
      body: SafeArea(child: buildSelectedHomeScreen()),
    );
  }

  // Choose the screen to display.
  Widget buildSelectedHomeScreen() {
    if (currentScreen == 'welcome') {
      return buildWelcomePage();
    } else if (currentScreen == 'calculator') {
      return buildDetailsPage();
    } else if (currentScreen == 'result') {
      return buildResultPage();
    } else {
      return buildAboutPage();
    }
  }

  // purple button
  Widget purpleButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // 1. WELCOME PAGE
  Widget buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 15),

          // Welcome illustration
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flight, size: 90, color: Colors.deepPurple),
                Icon(Icons.luggage, size: 65, color: Colors.deepPurple),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Calculate your excess baggage fee in seconds!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Simple. Fast. Accurate.',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),

          const SizedBox(height: 25),

          // Baggage allowance information
          Card(
            elevation: 2, // Lab 7: subtle Material card shadow.
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Baggage Allowance Information',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Lab 7: Responsive baggage information
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double itemWidth = constraints.maxWidth;
                      if (constraints.maxWidth >= 300) {
                        itemWidth = (constraints.maxWidth - 12) / 2;
                      }
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.luggage,
                                  color: Colors.deepPurple,
                                  size: 30,
                                ),
                                Text('Economy'),
                                Text(
                                  '20 kg',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.work,
                                  color: Colors.deepPurple,
                                  size: 30,
                                ),
                                Text('Business'),
                                Text(
                                  '40 kg',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Divider(),

                  const Icon(Icons.percent, color: Colors.deepPurple, size: 30),

                  const Text('Service Tax: 8%'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          purpleButton('Start Calculating', Icons.calculate, () {
            setState(() {
              currentScreen = 'calculator';
            });
          }),
        ],
      ),
    );
  }

  // 2. ENTER DETAILS PAGE
  Widget buildDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, size: 60, color: Colors.deepPurple),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Fill in the information below:'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Baggage weight
          const Text(
            '1. Baggage Weight (kg)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: weightController,

            onChanged: (value) {
              setState(() {
                weightError = checkInput(value);
              });
            },

            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'e.g. 25.00',
              prefixIcon: const Icon(Icons.luggage),
              errorText: weightError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Ticket class
          Row(
            children: [
              const Expanded(
                child: Text(
                  '2. Ticket Class',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: showTicketInformation,
                icon: const Icon(Icons.info_outline, color: Colors.deepPurple),
                tooltip: 'Ticket class information',
              ),
            ],
          ),

          RadioGroup<String>(
            groupValue: selectedClass,
            onChanged: (value) {
              setState(() {
                selectedClass = value;
              });
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Economy (20 kg)'),
                  value: 'Economy',
                  activeColor: Colors.deepPurple,
                ),
                RadioListTile<String>(
                  title: const Text('Business (40 kg)'),
                  value: 'Business',
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Baggage rate
          const Text(
            '3. Excess Baggage Rate (RM/kg)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: rateController,

            onChanged: (value) {
              setState(() {
                rateError = checkInput(value);
              });
            },

            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'e.g. 15.00',
              prefixIcon: const Icon(Icons.sell),
              errorText: rateError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              helperText: 'Enter the rate provided by your airline.',
            ),
          ),

          const SizedBox(height: 25),

          purpleButton('Calculate', Icons.calculate, calculateFee),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // Result row
  Widget resultRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 3. CALCULATION RESULT PAGE
  Widget buildResultPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 85, color: Colors.green),

          const SizedBox(height: 10),

          const Text(
            'Calculation Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2, // Lab 7: subtle Material card shadow.
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  resultRow(
                    'Ticket Class',
                    selectedClass ?? 'Economy',
                    Icons.luggage,
                  ),

                  resultRow(
                    'Baggage Weight',
                    '${baggageWeight.toStringAsFixed(2)} kg',
                    Icons.scale,
                  ),

                  resultRow(
                    'Allowed Weight',
                    '${allowedWeight.toStringAsFixed(2)} kg',
                    Icons.check_circle,
                  ),

                  const Divider(),

                  resultRow(
                    'Excess Baggage Weight',
                    '${excessWeight.toStringAsFixed(2)} kg',
                    Icons.scale,
                  ),

                  resultRow(
                    'Excess Baggage Charge',
                    'RM ${excessCharge.toStringAsFixed(2)}',
                    Icons.payments,
                  ),

                  resultRow(
                    'Service Tax (8%)',
                    'RM ${serviceTax.toStringAsFixed(2)}',
                    Icons.percent,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Total amount
          Card(
            elevation: 2, // Lab 7.
            color: Colors.deepPurple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Total Amount Payable',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'RM ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Reset and Home buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: resetCalculator,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: goToHome,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. ABOUT PAGE
  Widget buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Lab 6: show application icon or a fallback icon.
          Image.asset(
            'assets/icon/icon.png',
            width: 110,
            height: 110,
            errorBuilder: (context, error, stack) =>
                const Icon(Icons.luggage, size: 110),
          ),

          const SizedBox(height: 20),

          const Text(
            'Excess Baggage Fee Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Travel Smart, Pay Right!',
            style: TextStyle(color: Colors.deepPurple),
          ),

          const SizedBox(height: 25),

          const Divider(),

          const Text(
            'Author Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 15),

          const ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('NAZWA EIZURIN BINTI ROZMAN'),
          ),

          const ListTile(
            leading: Icon(Icons.badge, color: Colors.deepPurple),
            title: Text(
              'Matric No',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('2025235182'),
          ),

          const ListTile(
            leading: Icon(Icons.school, color: Colors.deepPurple),
            title: Text(
              'Course',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'CS251 - Bachelor of Computer Science (Hons.) Netcentric Computing',
            ),
          ),

          const Divider(),

          const SizedBox(height: 15),

          const Text(
            '© 2026. All rights reserved.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 15),

          // GitHub button: opens the real repository using url_launcher.
          OutlinedButton.icon(
            onPressed: openGitHub,
            icon: Image.asset(
              'assets/icon/github.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.code, size: 24),
            ),
            label: const Text(
              'nazwaeizurin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple),
          ),

          // clickable repository URL too.
          TextButton(
            onPressed: openGitHub,
            child: const Text(
              'https://github.com/nazwaeizurin/baggage_fee_calculator',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
