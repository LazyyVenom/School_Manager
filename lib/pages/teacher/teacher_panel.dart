import "package:flutter/material.dart";
import "package:school_manager/pages/management/nurse_register.dart";
import "package:school_manager/pages/teacher/exam_register.dart";
import "package:school_manager/pages/teacher/student_selector.dart";
import "package:school_manager/pages/teacher/subject_register.dart";

class TeacherPanel extends StatefulWidget {
  const TeacherPanel({super.key});

  @override
  State<TeacherPanel> createState() => TeacherPanelState();
}

class TeacherPanelState extends State<TeacherPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Panel"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            CreatorWidget(
              title: "Create Subject",
              registerPage: SubjectRegisterPage(),
              icon: Icons.subject,
            ),
            CreatorWidget(
              title: "Create Exam",
              registerPage: ExamCreatePage(),
              icon: Icons.class_,
            ),
            CreatorWidget(
              title: "Add Student Progress",
              registerPage: AddStudentMarksPage(),
              icon: Icons.group_add_sharp,
            ),
            CreatorWidget(
              title: "Show Students Progress",
              registerPage: NurseRegisterPage(),
              icon: Icons.auto_graph,
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
