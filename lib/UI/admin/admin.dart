import 'package:flutter/material.dart';
import 'package:pizza_management/UI/admin/revenue_management.dart';
import 'package:pizza_management/UI/admin/user_management.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent.withAlpha(100),
      appBar: AppBar(
        title: const Text("Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Admin 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: [

                  _buildCard(
                    context,
                    icon: Icons.local_pizza,
                    title: "Pizza",
                    color: Colors.orange,
                    onTap: () {},
                  ),

                  _buildCard(
                    context,
                    icon: Icons.people,
                    title: "Users",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)
                            => const UserManagement()
                        )
                      );
                    },
                  ),

                  _buildCard(
                    context,
                    icon: Icons.attach_money,
                    title: "Revenue",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)
                            => const RevenueManagement()
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Statistics",
                    color: Colors.red,
                    onTap: () {},
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withAlpha(100),
                child: Icon(
                  icon,
                  size: 35,
                  color: color,
                ),
              ),

              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}