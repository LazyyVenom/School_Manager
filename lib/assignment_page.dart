import "package:flutter/material.dart";

class AssignmentPage extends StatelessWidget {
  const AssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            "Assignment & HomeWork",
            style: Theme.of(context).textTheme.headlineMedium,
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
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1),
                        color: Colors.deepPurple[50],
                        child: ListTile(
                          leading: Icon(Icons.book, color: Colors.deepPurple[300],),
                          title: Text("Home Work for Grade $index "),
                          subtitle:
                              Text("Sent On: Regarding Office Work for $index"),
                          trailing: Icon(
                            Icons.arrow_circle_right,
                            color: Colors.deepPurple[300],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}  