import 'package:flutter/material.dart';
import 'package:school_manager/pages/management/manage_account_page.dart';

class RoleSelectionWidget extends StatelessWidget {
  const RoleSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildRoleCard(context, 'Management', Colors.deepPurple[400]!),
            _buildRoleCard(context, 'Student', Colors.blue[300]!),
            _buildRoleCard(context, 'Teacher', Colors.green[300]!),
            _buildRoleCard(context, 'Nurse', Colors.orange[300]!),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, Color color) {
    return Card(
      color: color,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserManagementPage(role: role),
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getRoleIcon(role),
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Management':
        return Icons.business;
      case 'Student':
        return Icons.school;
      case 'Teacher':
        return Icons.person;
      case 'Nurse':
        return Icons.health_and_safety;
      default:
        return Icons.help; // Fallback icon
    }
  }
}