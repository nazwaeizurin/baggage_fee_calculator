import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Only for the required GitHub link

void main() {
  runApp(const MyApp());
}

// Lab 5: keep the app colours in one place.
class AppColors {
  static const Color colorPrimary = Color(0xFF245AA5);
  static const Color colorOnPrimary = Colors.white;
}

// Lab 3: menu options, just like the enum MenuAction example.
enum MenuAction { home, about }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee',
      debugShowCheckedModeBanner: false,
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
  // Lab 4 and Lab 5: read values typed into TextFields.
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  // Lab 4: one variable shared by both radio buttons.
  String? selectedClass;

  // Lab 3 + Lab 2: a menu choice changes the visible screen using setState().
  MenuAction selectedPage = MenuAction.home;

  // Lab 4: the calculated output is displayed in a Text widget.
  String result = '';

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  // Lab 4: the same friendly SnackBar approach as showMessage().
  void showMessage(String message) {
    setState(() => result = '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void calculateFee() {
    // Validate the inputs first (Lab 4).
    if (weightController.text.trim().isEmpty) {
      showMessage('Please enter the baggage weight.');
      return;
    }

    final double? weight = double.tryParse(weightController.text.trim());
    if (weight == null || !weight.isFinite || weight < 0) {
      showMessage('Please enter a valid baggage weight (0 or more).');
      return;
    }

    if (selectedClass == null) {
      showMessage('Please select Economy or Business.');
      return;
    }

    if (rateController.text.trim().isEmpty) {
      showMessage('Please enter the excess baggage rate.');
      return;
    }

    final double? rate = double.tryParse(rateController.text.trim());
    if (rate == null || !rate.isFinite || rate < 0) {
      showMessage('Please enter a valid rate (0 or more).');
      return;
    }

    // Follow the assignment formula exactly.
    double allowedWeight = 20; // Economy
    if (selectedClass == 'Business') {
      allowedWeight = 40;
    }

    double excessWeight = weight - allowedWeight;
    if (excessWeight < 0) {
      excessWeight = 0;
    }

    final double excessCharge = excessWeight * rate;
    final double serviceTax = excessCharge * 0.08;
    final double totalAmount = excessCharge + serviceTax;

    // Lab 2: setState() refreshes the result on the screen.
    setState(() {
      result = 'Ticket Class: $selectedClass\n'
          'Baggage Allowance: ${allowedWeight.toStringAsFixed(0)} kg\n'
          'Excess Baggage Weight: ${excessWeight.toStringAsFixed(2)} kg\n'
          'Excess Baggage Charge: RM ${excessCharge.toStringAsFixed(2)}\n'
          'Service Tax (8%): RM ${serviceTax.toStringAsFixed(2)}\n'
          'Total Amount Payable: RM ${totalAmount.toStringAsFixed(2)}';
    });
  }

  // Lab 4, Exercise 3: clear all inputs and the output.
  void clearForm() {
    weightController.clear();
    rateController.clear();
    setState(() {
      selectedClass = null;
      result = '';
    });
  }

  // This is the only additional plugin functionality not taught in Labs 1-5.
  // Replace USERNAME and REPOSITORY with the real GitHub repository URL.
  Future<void> openGitHub() async {
    final Uri githubUrl =
    Uri.parse('https://github.com/nazwaeizurin/baggage_fee_calculator.git');

    try {
      if (!await launchUrl(githubUrl)) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excess Baggage Fee'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Lab 3: PopupMenuButton with onSelected and PopupMenuItem.
          PopupMenuButton<MenuAction>(
            onSelected: (MenuAction action) {
              setState(() {
                selectedPage = action;
              });
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: MenuAction.home,
                child: Text('Home'),
              ),
              PopupMenuItem(
                value: MenuAction.about,
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: selectedPage == MenuAction.home
          ? buildHomePage()
          : buildAboutPage(),
    );
  }

  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Excess Baggage Fee Calculator',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter your baggage weight, select a ticket class, and enter '
                'the rate per kg. Tap Calculate to view your fee.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Economy: 20 kg allowance | Business: 40 kg allowance\n'
                'Service tax: 8% of the excess baggage charge.',
          ),
          const SizedBox(height: 24),

          // Lab 4: TextField + controller + InputDecoration.
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Baggage Weight (kg)',
              hintText: 'Example: 25 or 42.5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Ticket Class',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // Lab 4: RadioGroup and RadioListTile.
          RadioGroup<String>(
            groupValue: selectedClass,
            onChanged: (value) => setState(() => selectedClass = value),
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Economy (20 kg)'),
                  value: 'Economy',
                ),
                RadioListTile<String>(
                  title: Text('Business (40 kg)'),
                  value: 'Business',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Excess Baggage Rate (RM per kg)',
              hintText: 'Example: 15 or 12',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Lab 3 + Lab 5: basic buttons and onPressed handlers.
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: calculateFee,
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: clearForm,
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Calculation Result',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Lab 4: show the output after pressing Submit/Calculate.
          Text(
            result.isEmpty ? 'No calculation yet.' : result,
            style: const TextStyle(fontSize: 16, height: 1.7),
          ),
        ],
      ),
    );
  }

  Widget buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          // Lab 2 + Lab 5: display the same image used for the app icon.
          Image.asset(
            'assets/icon/icon.png',
            width: 110,
            height: 110,
          ),
          const SizedBox(height: 16),
          const Text(
            'Excess Baggage Fee Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 26),
          const Text('Author Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Name: YOUR FULL NAME'),
          const Text('Matric No: YOUR MATRIC NUMBER'),
          const Text('Course: CS251'),
          const SizedBox(height: 24),
          const Text('Copyright © 2026. All rights reserved.'),
          const SizedBox(height: 18),
          const Text('GitHub Repository URL:'),
          // A clickable URL is required by the assignment.
          TextButton(
            onPressed: openGitHub,
            child: const Text(
              'https://github.com/USERNAME/REPOSITORY',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
