import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'grade_pred_page.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  final TextEditingController _absencesController = TextEditingController();
  final TextEditingController _parentalSupportController = TextEditingController();
  final TextEditingController _studyTimeController = TextEditingController();
  final TextEditingController _tutoringController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _absencesController.dispose();
    _parentalSupportController.dispose();
    _studyTimeController.dispose();
    _tutoringController.dispose();
    super.dispose();
  }

  bool _areFieldsValid() {
    try {
      if (_absencesController.text.isEmpty ||
          _parentalSupportController.text.isEmpty ||
          _studyTimeController.text.isEmpty ||
          _tutoringController.text.isEmpty) {
        return false;
      }
      
      // Try parsing the values to check if they're valid numbers
      int.parse(_absencesController.text);
      int.parse(_parentalSupportController.text);
      double.parse(_studyTimeController.text);
      int.parse(_tutoringController.text);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
        content: const Text('Please enter valid numbers for all fields. Make sure all fields are filled and contain only numbers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _predictGrade() async {
    if (!_areFieldsValid()) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://linear-regression-s6de.onrender.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Absences': int.parse(_absencesController.text),
          'ParentalSupport': int.parse(_parentalSupportController.text),
          'StudyTimeWeekly': double.parse(_studyTimeController.text),
          'Tutoring': int.parse(_tutoringController.text),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Convert the predicted_grade to double explicitly
        final predictedGrade = double.parse(data['GPA'].toString());
        
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictedGradePage(predictedGrade: predictedGrade),
          ),
        );
      } else {
        throw Exception('Failed to predict grade');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to predict grade: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Grades'),
        backgroundColor: const Color.fromARGB(255, 32, 48, 105),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Grade Prediction',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Discover your potential grades this semester and stay ahead in your academic journey!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _absencesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                  decoration: InputDecoration(
                    labelText: 'Absences',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _parentalSupportController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                  decoration: InputDecoration(
                    labelText: 'Parental Support',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _studyTimeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                  decoration: InputDecoration(
                    labelText: 'Study Time Weekly',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _tutoringController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                  decoration: InputDecoration(
                    labelText: 'Tutoring',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _predictGrade,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: const Color.fromARGB(255, 4, 69, 122),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: const Size(double.infinity, 50.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Predict Grade',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}