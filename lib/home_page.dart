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
                color: const Color.fromARGB(255, 207, 203, 214),
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
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 219, 216, 224))
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
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 219, 216, 224))
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
                )
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
            Expanded(
              child: ListView.builder(
                itemCount: 60,
                itemBuilder:(context, index) {
                  return const ListTile(
                    title: Text("Hello Hii"),
                    subtitle: Text("Regarding Office Work"),
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
