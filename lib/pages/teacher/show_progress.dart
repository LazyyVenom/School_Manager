import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DisplayStudentProgress extends StatefulWidget {
  final String studentName;
  final String className;
  final String sectionName;

  const DisplayStudentProgress({
    required this.studentName,
    required this.className,
    required this.sectionName,
    Key? key,
  }) : super(key: key);

  @override
  _DisplayStudentProgressState createState() => _DisplayStudentProgressState();
}

class _DisplayStudentProgressState extends State<DisplayStudentProgress> {
  String? _selectedSubject;
  List<String> _subjects = [];
  List<Map<String, dynamic>> _marksData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch subjects for the class from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('classes')
          .doc('${widget.className}_${widget.sectionName}')
          .get();

      if (snapshot.exists) {
        List<String> subjectList = List<String>.from(snapshot.data()?['subjects'] ?? []);
        setState(() {
          _subjects = subjectList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching subjects: $e"),
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
    if (_selectedSubject == null) return;

    setState(() {
      _isLoading = true;
      _marksData.clear();
    });

    try {
      // Fetch marks for the selected student and subject
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('marks')
          .where('studentName', isEqualTo: widget.studentName)
          .where('subject', isEqualTo: _selectedSubject)
          .get();

      List<Map<String, dynamic>> marksList = querySnapshot.docs.map((doc) {
        return {
          'examName': doc.data()['exam'],
          'marks': doc.data()['marks'],
          'date': (doc.data()['date'] as Timestamp).toDate(),
        };
      }).toList();

      // Sort marks by date
      marksList.sort((a, b) => a['date'].compareTo(b['date']));

      setState(() {
        _marksData = marksList;
      });
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
        title: Text("Progress of ${widget.studentName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: "Select Subject",
                border: OutlineInputBorder(),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                  _fetchMarks(); // Fetch marks for the selected subject
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Show a loading spinner when data is being fetched
            _isLoading
                ? const CircularProgressIndicator()
                : _marksData.isEmpty
                    ? const Text("No marks available for the selected subject.")
                    : Expanded(child: _buildLineChart()),
          ],
        ),
      ),
    );
  }

  // Function to build the Line Chart
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              final int index = value.toInt();
              if (index >= 0 && index < _marksData.length) {
                final examDate = _marksData[index]['date'] as DateTime;
                return "${examDate.day}/${examDate.month}";
              }
              return '';
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              return value.toString();
            },
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (_marksData.length - 1).toDouble(),
        minY: 0,
        maxY: 100, // Assuming max marks is 100
        lineBarsData: [
          LineChartBarData(
            spots: _marksData
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value['marks'].toDouble()))
                .toList(),
            isCurved: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
      ),
    );
  }
}
