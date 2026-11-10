import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Required: clickable GitHub link

void main() {
  runApp(const MyApp());
}

// Lab 5: keep the theme colours together.
class AppColors {
  static const Color colorPrimary = Colors.deepPurple;
  static const Color colorOnPrimary = Colors.white;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee',
      debugShowCheckedModeBanner: false,
      // Lab 5: ThemeData + ColorScheme.fromSeed() + copyWith().
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
        ).copyWith(
          primary: AppColors.colorPrimary,
          onPrimary: AppColors.colorOnPrimary,
        ),
      ),
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
  final TextEditingController weightController =
  TextEditingController();

  final TextEditingController rateController =
  TextEditingController();

  // Selected ticket class
  String? selectedClass = 'Economy';

  // Selected bottom navigation page
  int selectedPage = 0;

  // Home screen selection
  // 0 = Welcome, 1 = Enter Details,
  // 2 = Result, 3 = Invalid Details
  int currentScreen = 0;

  // Calculation results
  double baggageWeight = 0;
  double allowedWeight = 0;
  double excessWeight = 0;
  double baggageRate = 0;
  double excessCharge = 0;
  double serviceTax = 0;
  double totalAmount = 0;

  // Error message
  String errorMessage = '';

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
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Show ticket class information dialog
  void showTicketInformation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.info,
            color: Colors.deepPurple,
            size: 40,
          ),
          title: const Text(
            'About Ticket Class',
            textAlign: TextAlign.center,
          ),
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

  // Lab 4: an if statement gives friendly error messages for invalid input.
  // The original 'Oops!' page is kept, so the UI remains the same.
  void showInputError(String message) {
    setState(() {
      errorMessage = message;
      currentScreen = 3;
    });
  }

  // Lab 4 + Lab 5: TextEditingController and double.tryParse().
  // The assignment allows decimal values such as 42.5 kg.
  void calculateFee() {
    if (weightController.text.trim().isEmpty) {
      showInputError('Please enter your baggage weight.');
      return;
    }

    final double? enteredWeight =
    double.tryParse(weightController.text.trim());

    if (enteredWeight == null ||
        !enteredWeight.isFinite ||
        enteredWeight < 0) {
      showInputError('Enter a valid weight (0 kg or more).');
      return;
    }

    if (rateController.text.trim().isEmpty) {
      showInputError('Please enter the excess baggage rate.');
      return;
    }

    final double? enteredRate =
    double.tryParse(rateController.text.trim());

    if (enteredRate == null ||
        !enteredRate.isFinite ||
        enteredRate < 0) {
      showInputError('Enter a valid rate (RM 0 or more).');
      return;
    }

    // The formulas are exactly those in the assignment handout.
    baggageWeight = enteredWeight;
    baggageRate = enteredRate;
    allowedWeight = getAllowedWeight();

    // Excess baggage cannot be negative.
    if (baggageWeight > allowedWeight) {
      excessWeight = baggageWeight - allowedWeight;
    } else {
      excessWeight = 0;
    }

    excessCharge = excessWeight * baggageRate;
    serviceTax = excessCharge * 0.08;
    totalAmount = excessCharge + serviceTax;

    if (!totalAmount.isFinite) {
      showInputError('The amount is too large. Please check your numbers.');
      return;
    }

    // Lab 2: refresh the screen after calculating.
    setState(() {
      currentScreen = 2;
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
      errorMessage = '';
      currentScreen = 1;
    });
  }

  // Return to welcome page
  void goToHome() {
    setState(() {
      selectedPage = 0;
      currentScreen = 0;
    });
  }

  // Assignment requirement: the About button must open the GitHub URL.
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedPage == 1
              ? 'About'
              : currentScreen == 2
              ? 'Calculation Result'
              : 'Excess Baggage Fee',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),

      // Display selected page
      body: selectedPage == 1
          ? buildAboutPage()
          : buildSelectedHomeScreen(),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }

  // Select home screen
  Widget buildSelectedHomeScreen() {
    if (currentScreen == 0) {
      return buildWelcomePage();
    } else if (currentScreen == 1) {
      return buildDetailsPage();
    } else if (currentScreen == 2) {
      return buildResultPage();
    } else {
      return buildErrorPage();
    }
  }

  // Common purple button
  Widget purpleButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
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
                Icon(
                  Icons.flight,
                  size: 90,
                  color: Colors.deepPurple,
                ),
                Icon(
                  Icons.luggage,
                  size: 65,
                  color: Colors.deepPurple,
                ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 25),

          // Baggage allowance information
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Baggage Allowance Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.luggage,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                          Text('Economy'),
                          Text(
                            '20 kg',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                          Text('Business'),
                          Text(
                            '40 kg',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  const Icon(
                    Icons.percent,
                    color: Colors.deepPurple,
                    size: 30,
                  ),

                  const Text('Service Tax: 8%'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          purpleButton(
            text: 'Start Calculating',
            icon: Icons.calculate,
            onPressed: () {
              setState(() {
                currentScreen = 1;
              });
            },
          ),
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
              Icon(
                Icons.calculate,
                size: 35,
                color: Colors.deepPurple,
              ),
              SizedBox(width: 12),
              Text(
                'Enter Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text('Fill in the information below:'),

          const SizedBox(height: 25),

          // Baggage weight
          const Text(
            '1. Baggage Weight (kg)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: weightController,
            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 25',
              prefixIcon: const Icon(Icons.luggage),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: showTicketInformation,
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.deepPurple,
                ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: rateController,
            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 15',
              prefixIcon: const Icon(Icons.sell),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              helperText:
              'Enter the rate provided by your airline.',
            ),
          ),

          const SizedBox(height: 25),

          purpleButton(
            text: 'Calculate',
            icon: Icons.calculate,
            onPressed: calculateFee,
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: goToHome,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(
                  color: Colors.deepPurple,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),



          const SizedBox(height: 15),

          // Tip information
          Card(
            color: Colors.deepPurple.shade50,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.orange,
                    size: 35,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          'Enter the rate provided by your airline.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Result row
  Widget resultRow(
      String title,
      String value, {
        IconData? icon,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.deepPurple,
              size: 22,
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Text(title),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
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
          const Icon(
            Icons.check_circle,
            size: 85,
            color: Colors.green,
          ),

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
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  resultRow(
                    'Ticket Class',
                    selectedClass ?? 'Economy',
                    icon: Icons.luggage,
                  ),

                  resultRow(
                    'Baggage Weight',
                    '${baggageWeight.toStringAsFixed(2)} kg',
                    icon: Icons.scale,
                  ),

                  resultRow(
                    'Allowed Weight',
                    '${allowedWeight.toStringAsFixed(2)} kg',
                    icon: Icons.check_circle,
                  ),

                  const Divider(),

                  resultRow(
                    'Excess Baggage Weight',
                    '${excessWeight.toStringAsFixed(2)} kg',
                    icon: Icons.scale,
                  ),

                  resultRow(
                    'Excess Baggage Charge',
                    'RM ${excessCharge.toStringAsFixed(2)}',
                    icon: Icons.payments,
                  ),

                  resultRow(
                    'Service Tax (8%)',
                    'RM ${serviceTax.toStringAsFixed(2)}',
                    icon: Icons.percent,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Total amount
          Card(
            color: Colors.deepPurple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.deepPurple,
                      ),
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

  // 4. INVALID DETAILS PAGE
  Widget buildErrorPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 35),

          const Icon(
            Icons.luggage,
            size: 120,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 15),

          const Icon(
            Icons.error,
            size: 45,
            color: Colors.redAccent,
          ),

          const SizedBox(height: 10),

          const Text(
            'Oops!',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Please enter valid details.',
            style: TextStyle(fontSize: 17),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(errorMessage),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          purpleButton(
            text: 'Try Again',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                currentScreen = 1;
              });
            },
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

          // Lab 2 + Lab 5: show the real app icon on the About page.
          Image.asset(
            'assets/icon/passport.jpeg',
            width: 110,
            height: 110,
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
            style: TextStyle(
              color: Colors.deepPurple,
            ),
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
            leading: Icon(
              Icons.person,
              color: Colors.deepPurple,
            ),
            title: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('NAZWA EIZURIN BINTI ROZMAN'),
          ),

          const ListTile(
            leading: Icon(
              Icons.badge,
              color: Colors.deepPurple,
            ),
            title: Text(
                'Matric No',
                style : TextStyle(
                    fontWeight: FontWeight.bold,
                ),
            ),
            subtitle: Text('2025235182'),
          ),

          const ListTile(
            leading: Icon(
              Icons.school,
              color: Colors.deepPurple,
            ),
            title: Text(
              'Course',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('CS251 - Bachelor of Computer Science (Hons.) Netcentric Computing '),
          ),

          const Divider(),

          const SizedBox(height: 15),

          const Text(
            '© 2026. All rights reserved.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          // Real link, not a SnackBar placeholder.

          OutlinedButton.icon(
            onPressed: openGitHub,
            icon: Image.asset(
              'assets/icon/github.png',
              width: 24,
              height: 24,
            ),
            label: const Text(
              'nazwaeizurin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}