import 'package:flutter/material.dart';

class PredictedGradePage extends StatefulWidget {
  final double predictedGrade;

  const PredictedGradePage({
    super.key,
    required this.predictedGrade,
  });

  @override
  State<PredictedGradePage> createState() => _PredictedGradePageState();
}

class _PredictedGradePageState extends State<PredictedGradePage> {
 String _getPerformanceMessage(double grade) {
    if (grade >= 4.5) {
      return 'Exceptional! You\'re achieving at the highest level!';
    } else if (grade >= 4.0) {
      return 'Excellent! Outstanding academic performance!';
    } else if (grade >= 3.5) {
      return 'Very good! Keep up your strong performance!';
    } else if (grade >= 3.0) {
      return 'Good work! Your effort is showing results.';
    } else if (grade >= 2.5) {
      return 'Fair. Keep working to improve your grade.';
    } else if (grade >= 2.0) {
      return 'Passing, but needs improvement.';
    } else {
      return 'Seek support to improve your grade.';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grade Prediction'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'GPA Prediction Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/Images/grade.jpg',
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'Your GPA: ${widget.predictedGrade.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 69, 122),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPerformanceMessage(widget.predictedGrade),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 69, 122),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Make Another Prediction',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}