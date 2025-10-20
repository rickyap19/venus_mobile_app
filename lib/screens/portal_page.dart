import 'package:flutter/material.dart';
import '../widgets/app_card.dart';

class PortalPage extends StatelessWidget {
  const PortalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_boat_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'PERTAMINA',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            iconSize: 26,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined, color: Colors.black87),
            iconSize: 26,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black87),
            iconSize: 26,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.pushReplacementNamed(context, '/login');
                } else if (value == 'profile') {
                  // Navigate to profile page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile page coming soon')),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline, color: Color(0xFF1976D2), size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.red, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1976D2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xFF1976D2),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1976D2).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Welcome to PIS\nManagement System',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select an application to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildAppGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        AppCard(
          title: 'Venus',
          subtitle: 'Crew Management System',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF7B68EE),
          isAvailable: true,
          onTap: () {},
        ),
        AppCard(
          title: 'WRH',
          subtitle: 'Warehouse Management',
          icon: Icons.warehouse_rounded,
          color: const Color(0xFFE97FBA),
          isAvailable: false,
          onTap: () {},
        ),
        AppCard(
          title: 'Financial',
          subtitle: 'Financial Analytics & Reports',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF5FC9E8),
          isAvailable: false,
          onTap: () {},
        ),
        AppCard(
          title: 'Performance',
          subtitle: 'KPI & Performance Metrics',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF7FD99F),
          isAvailable: false,
          onTap: () {},
        ),
        AppCard(
          title: 'SmartShip',
          subtitle: 'Vessel Monitoring System',
          icon: Icons.directions_boat_filled_rounded,
          color: const Color(0xFFFFB347),
          isAvailable: false,
          onTap: () {},
        ),
      ],
    );
  }
}