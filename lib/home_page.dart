import "package:flutter/material.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 95,
              width: double.infinity,
              child: Card(
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Welcome Anubhav",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        "Class X Std A, Roll No. 14",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.deepPurple[50])
                  ),
                  onPressed: () {
                  return;
                }, 
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Change Password"
                    ),
                )
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.deepPurple[50])
                  ),
                  onPressed: () {
                  return;
                }, 
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Request Profile Edit"
                    ),
                )
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red[50]),
                    foregroundColor: MaterialStatePropertyAll(Colors.red[400]),
                    overlayColor: MaterialStatePropertyAll(Colors.red[100])
                  ),
                  onPressed: () {
                  return;
                }, 
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Log Out"
                    ),
                )
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Text(
              "Recent Activities",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder:(context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1),
                          color: Colors.deepPurple[50],
                          child: ListTile(
                            leading: index % 3 == 0 ? Icon(Icons.book, color: Colors.deepPurple[300],) : Icon(Icons.add_alert, color: Colors.deepPurple[300],),
                            title: Text("Home Work for Grade $index "),
                            subtitle: Text("Sent On: Regarding Office Work for $index"),
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
      ),
    );
  }
}
