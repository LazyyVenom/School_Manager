import 'package:flutter/material.dart';

class AssignmentPageTh extends StatefulWidget {
  const AssignmentPageTh({super.key});

  @override
  State<AssignmentPageTh> createState() => _AssignmentPageThState();
}

class _AssignmentPageThState extends State<AssignmentPageTh> {
  final List<String> categories = ['All', 'Assignments', 'Homework'];
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            "Assignments",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    child: Chip(
                      label: Text(categories[index]),
                      backgroundColor: selectedCategory == categories[index]
                          ? Colors.deepPurple[200]
                          : Colors.deepPurple[50],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: 9,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    color: Colors.deepPurple[50],
                    child: ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        color: Colors.deepPurple[300],
                      ),
                      title: Text("Homework for Grade $index"),
                      subtitle: Text("Sent On: Regarding Office Work for $index"),
                      trailing: Icon(
                        Icons.arrow_circle_right,
                        color: Colors.deepPurple[300],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
