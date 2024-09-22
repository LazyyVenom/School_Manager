import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DisplayStudentProgress extends StatefulWidget {
  final String studentEmail;
  final String className;
  final String sectionName;

  const DisplayStudentProgress({
    required this.studentEmail,
    required this.className,
    required this.sectionName,
    Key? key,
  }) : super(key: key);

  @override
  _DisplayStudentProgressState createState() => _DisplayStudentProgressState();
}

class _DisplayStudentProgressState extends State<DisplayStudentProgress> {
  String? _selectedExam;
  List<String> _exams = [];
  Map<String, double> _marksData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('exams')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        List<String> examList = List<String>.from(
            snapshot.data()?['exams']?.map((e) => e['examName']) ?? []);
        setState(() {
          _exams = examList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching exams: $e"),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMarks() async {
  if (_selectedExam == null) return;

  setState(() {
    _isLoading = true;
    _marksData.clear();
  });

  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('studentMarks')
            .where(FieldPath.documentId, isEqualTo: widget.studentEmail)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      var examDetails =
          querySnapshot.docs.first.data()['exams'] as List<dynamic>? ?? [];
      var selectedExam = examDetails.firstWhere(
          (exam) => exam['examName'] == _selectedExam,
          orElse: () => null);

      if (selectedExam != null) {
        // Convert marks safely using as
        var marks = selectedExam['marks'] as Map<String, dynamic>;

        _marksData = marks.map<String, double>((key, value) {
          return MapEntry(key, (value is num) ? value.toDouble() : 0.0);
        });
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error fetching marks: $e"),
        backgroundColor: Colors.red[200],
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress of ${widget.studentEmail}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExam,
              decoration: const InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(),
              ),
              items: _exams.map((exam) {
                return DropdownMenuItem<String>(
                  value: exam,
                  child: Text(exam),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExam = value;
                  _fetchMarks();
                });
              },
            ),
            const SizedBox(height: 16.0),
            _selectedExam != null
                ? ElevatedButton(
                    onPressed: _fetchMarks,
                    child: const Text("Fetch Marks"),
                  )
                : Container(),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : _marksData.isEmpty
                    ? const Text("No marks available for the selected exam.")
                    : Expanded(child: _buildBarChart()),
          ],
        ),
      ),
    );
  }

  // Function to build the Bar Chart
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: _marksData.entries.map((entry) {
          return BarChartGroupData(
            x: _marksData.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                y: entry.value,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              return _marksData.keys.toList()[value.toInt()];
            },
          ),
        ),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
