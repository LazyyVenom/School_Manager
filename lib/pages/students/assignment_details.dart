import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> assignmentData;

  const AssignmentDetailPage({super.key, required this.assignmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          assignmentData['assignment'] ?? 'Assignment Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignmentData['assignment'] ?? 'No Title',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      context,
                      label: 'Due Date:',
                      value:
                          DateFormat('yyyy-MM-dd').format(assignmentData['dueDate']!.toDate()),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      context,
                      label: 'Details:',
                      value: assignmentData['details'] ?? 'No details available',
                    ),
                    const SizedBox(height: 16),
                    // Add more fields if needed
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build each detail item
  Widget _buildDetailItem(BuildContext context,
      {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
