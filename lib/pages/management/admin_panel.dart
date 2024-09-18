import "package:flutter/material.dart";
import "package:school_manager/pages/management/class_register.dart";
import "package:school_manager/pages/management/section_register.dart";
import "package:school_manager/pages/management/teacher_id_create.dart";
import "package:school_manager/pages/teacher/student_id_create.dart";

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            CreatorWidget(
              title: "Create Teacher Account",
              registerPage: TeacherRegisterPage(),
              icon: Icons.person_add_alt_1_rounded,
            ),
            CreatorWidget(
              title: "Create Student Account",
              registerPage: StudentRegisterPage(),
              icon: Icons.add_reaction,
            ),
            CreatorWidget(
              title: "Create Class",
              registerPage: ClassRegisterPage(),
              icon: Icons.class_,
            ),
            CreatorWidget(
              title: "Create Section",
              registerPage: SectionRegisterPage(),
              icon: Icons.account_balance,
            ),
            CreatorWidget(
              title: "Create Nurse Account",
              registerPage: TeacherRegisterPage(),
              icon: Icons.person_4,
            ),
            CreatorWidget(
              title: "View Management Accounts",
              registerPage: TeacherRegisterPage(),
              icon: Icons.manage_accounts,
            ),
            CreatorWidget(
              title: "Create Management Account",
              registerPage: TeacherRegisterPage(),
              icon: Icons.manage_accounts,
            ),
          ],
        ),
      ),
    );
  }
}

class CreatorWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget registerPage;

  // Constructor with named parameters and required keyword
  const CreatorWidget({
    required this.title,
    required this.icon,
    required this.registerPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => registerPage),
              );
            },
            child: Card(
              color: Colors.deepPurple[50],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(icon),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
