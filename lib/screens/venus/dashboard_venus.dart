import 'package:flutter/material.dart';
import 'package:pis_management_system/config/menu_config.dart';
import 'package:pis_management_system/service/auth_service.dart';
import 'package:pis_management_system/widgets/modern_menu_dropdown.dart';

class VenusDashboard extends StatefulWidget {
  const VenusDashboard({Key? key}) : super(key: key);

  @override
  State<VenusDashboard> createState() => _VenusDashboardState();
}

class _VenusDashboardState extends State<VenusDashboard> {
  String _userRole = '';
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _userRole = userData['role'] ?? '';
      _userName = userData['fullName'] ?? 'User';
      _isLoading = false;
    });
    print('👤 User Role: $_userRole');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildHamburgerMenu(),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B68EE), Color(0xFF6A5ACD)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VENUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),

            if (_userRole.toUpperCase() == 'MA') ...[
              _buildRecruitmentMetrics(),
              const SizedBox(height: 24),
              _buildOperationalOverview(),
              const SizedBox(height: 24),
              _buildCrewManagement(),
              const SizedBox(height: 24),
              _buildBottomSection(),
              const SizedBox(height: 24),
              _buildDefaultDashboard(),
            ] else if (_userRole.toUpperCase() == 'APPLICANT') ...[
              _buildApplicantDashboard(),
            ] ,

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHamburgerMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
      tooltip: 'Menu',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [
          const PopupMenuItem(
            value: 'dashboard',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.dashboard_outlined, color: Color(0xFF1976D2)),
              title: Text('Portal', style: TextStyle(fontSize: 14)),
            ),
          ),
        ];

        if (MenuConfig.shouldShowMenu('recruitment', _userRole)) {
          items.add(
            PopupMenuItem(
              value: 'recruitment',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF5E35B1)),
                title: const Text('Recruitment', style: TextStyle(fontSize: 14)),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ),
            ),
          );
          items.addAll([
            const PopupMenuItem(
              value: 'divider',
              enabled: false,
              child: Divider(height: 1),
            ),
            const PopupMenuItem(
              value: 'analytics',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.analytics_outlined, color: Color(0xFF1976D2)),
                title: Text('Analytics', style: TextStyle(fontSize: 14)),
              ),
            ),
            const PopupMenuItem(
              value: 'reports',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.assessment_outlined, color: Color(0xFFFB8C00)),
                title: Text('Reports', style: TextStyle(fontSize: 14)),
              ),
            ),
            const PopupMenuItem(
              value: 'divider2',
              enabled: false,
              child: Divider(height: 1),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings_outlined, color: Color(0xFF757575)),
                title: Text('Settings', style: TextStyle(fontSize: 14)),
              ),
            ),
          ]);

        }

        if (MenuConfig.shouldShowMenu('manning', _userRole)) {
          items.add(
            PopupMenuItem(
              value: 'manning',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.people_rounded, color: Color(0xFF00897B)),
                title: const Text('Manning', style: TextStyle(fontSize: 14)),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ),
            ),
          );

        }

        if (MenuConfig.shouldShowMenu('personal_data', _userRole)) {
          items.add(
            PopupMenuItem(
              value: 'personal_data',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF1E88E5)),
                title: const Text('Recruitment', style: TextStyle(fontSize: 14)),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ),
            ),
          );
        }

        items.addAll([
          const PopupMenuItem(
            value: 'logout',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_outlined, color: Color(0xFFE53935)),
              title: Text('Logout', style: TextStyle(fontSize: 14)),
            ),
          ),
        ]);

        return items;
      },
      onSelected: (value) async {
        switch (value) {
          case 'dashboard':
            Navigator.pushNamed(context, '/portal');
            break;
          case 'recruitment':
            _showMenuBottomSheet(
              context,
              title: 'RECRUITMENT',
              icon: Icons.person_add_alt_1_rounded,
              sections: MenuConfig.getRecruitmentMenu(context),
              primaryColor: const Color(0xFF5E35B1),
              secondaryColor: const Color(0xFF4527A0),
            );
            break;
          case 'manning':
            _showMenuBottomSheet(
              context,
              title: 'MANNING',
              icon: Icons.people_rounded,
              sections: MenuConfig.getManningMenu(context),
              primaryColor: const Color(0xFF00897B),
              secondaryColor: const Color(0xFF00695C),
            );
            break;
          case 'personal_data':
            _showMenuBottomSheet(
              context,
              title: 'PERSONAL DATA',
              icon: Icons.person_outline_rounded,
              sections: MenuConfig.getPersonalDataMenu(context),
              primaryColor: const Color(0xFF1E88E5),
              secondaryColor: const Color(0xFF1565C0),
            );
            break;
          case 'analytics':
            Navigator.pushNamed(context, '/analytics');
            break;
          case 'reports':
            Navigator.pushNamed(context, '/reports');
            break;
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            await AuthService.logout();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
            break;
        }
      },
    );
  }

  void _showMenuBottomSheet(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<MenuSection> sections,
        required Color primaryColor,
        required Color secondaryColor,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: sections.length,
                separatorBuilder: (context, index) => Divider(
                  height: 32,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return _buildMenuSection(section);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(MenuSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            section.title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...section.items.map((item) => Builder(
          builder: (BuildContext ctx) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  item.onTap?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    String subtitle = _userRole.toUpperCase() == 'APPLICANT'
        ? 'Track your application status and manage your profile'
        : 'Here\'s what\'s happening with your crew management today';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (_userRole.toUpperCase() == 'MA') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('3,277', 'Total Crew', Icons.groups),
                const SizedBox(width: 8),
                _buildStatCard('1,723', 'On Schedule', Icons.schedule),
                const SizedBox(width: 8),
                _buildStatCard('2,573', 'Active', Icons.check_circle),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // APPLICANT DASHBOARD
  Widget _buildApplicantDashboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildApplicantProfileCard(),
          const SizedBox(height: 16),
          _buildApplicationStatusCard(),
          const SizedBox(height: 16),
          _buildQuickLinksCard(),
        ],
      ),
    );
  }

  Widget _buildApplicantProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1E88E5),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Applicant',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          _buildStatusItem('Pending Review', Icons.schedule, const Color(0xFFFB8C00)),
          _buildStatusItem('Documents to Upload', Icons.upload_file, const Color(0xFF1E88E5)),
          _buildStatusItem('Next Interview', Icons.event, const Color(0xFF5E35B1)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickLinkItem('Update Profile', Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildQuickLinkItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1E88E5), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Dashboard content for your role\nwill be displayed here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MA DASHBOARD SECTIONS
  Widget _buildRecruitmentMetrics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recruitment Metrics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('View all'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _buildMetricCard('304', 'New Applicant', Icons.person_add_alt_1, const Color(0xFF1E88E5)),
              _buildMetricCard('2', 'Waiting Agency Review', Icons.assignment, const Color(0xFF5E35B1)),
              _buildMetricCard('2', 'Waiting FPO Review', Icons.rate_review, const Color(0xFF00897B)),
              _buildMetricCard('2', 'Selection Checklist', Icons.checklist_rtl, const Color(0xFF43A047)),
              _buildMetricCard('21', 'Waiting MCU Result', Icons.health_and_safety, const Color(0xFF3949AB)),
              _buildMetricCard('2,961', 'Accepted', Icons.verified, const Color(0xFF43A047)),
              _buildMetricCard('7,196', 'Expired Certificates', Icons.error_outline, const Color(0xFFFB8C00)),
              _buildMetricCard('2,627', 'Expired Documents', Icons.folder_off, const Color(0xFFE53935)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalOverview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          _buildFleetStatusCard(),
          const SizedBox(height: 16),
          _buildCrewByRankCard(),
          const SizedBox(height: 16),
          _buildCertificationsCard(),
        ],
      ),
    );
  }

  Widget _buildFleetStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_boat,
                  color: Color(0xFF1E88E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fleet Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E88E5).withOpacity(0.1),
                  const Color(0xFF1565C0).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '24',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Vessels',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildVesselItem('MV Pertamina Explorer', '18 crew', 'Singapore'),
          _buildVesselItem('MV Nusantara Jaya', '22 crew', 'Jakarta'),
          _buildVesselItem('MV Samudra Sentosa', '15 crew', 'Maintenance'),
          _buildVesselItem('MV Indo Maritime', '20 crew', 'Surabaya'),
        ],
      ),
    );
  }

  Widget _buildVesselItem(String name, String crew, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$crew • $location',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewByRankCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Color(0xFF5E35B1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Crew by Rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRankBar('Captain', 24, const Color(0xFF1E88E5), 24, 300),
          _buildRankBar('Chief Engineer', 24, const Color(0xFF5E35B1), 24, 300),
          _buildRankBar('Officers', 186, const Color(0xFF00897B), 186, 300),
          _buildRankBar('Engineers', 156, const Color(0xFF43A047), 156, 300),
          _buildRankBar('Ratings', 2183, const Color(0xFFFB8C00), 2183, 2200),
        ],
      ),
    );
  }

  Widget _buildRankBar(String rank, int count, Color color, int value, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / max,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Certifications Expiring Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCertItem('STCW Certificates', '45 crew', '30 days', const Color(0xFFE53935)),
          _buildCertItem('Medical Certificates', '89 crew', '60 days', const Color(0xFFFB8C00)),
          _buildCertItem('Passport Renewal', '124 crew', '90 days', const Color(0xFFFDD835)),
          _buildCertItem('COC/COE Renewal', '67 crew', '90 days', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCertItem(String title, String crew, String days, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$crew • Within $days',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewManagement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crew Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Manage crew'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCrewStatusCard('2,573', 'Active Crews', Icons.people, const Color(0xFF43A047), constraints.maxWidth),
                  _buildCrewStatusCard('375', 'Inactive Crews', Icons.access_time, const Color(0xFFFB8C00), constraints.maxWidth),
                  _buildCrewStatusCard('2,569', 'Non Compliance', Icons.warning, const Color(0xFF1E88E5), constraints.maxWidth),
                  _buildCrewStatusCard('2', 'Rejected', Icons.cancel, const Color(0xFFE53935), constraints.maxWidth),
                  _buildCrewStatusCard('0', 'Temporary Rejected', Icons.timelapse, Colors.grey, constraints.maxWidth),
                  _buildCrewStatusCard('1', 'Blacklist', Icons.block, Colors.black87, constraints.maxWidth),
                  _buildCrewStatusCard('2,074', 'Records Change', Icons.edit_note, const Color(0xFF7CB342), constraints.maxWidth),
                  _buildCrewStatusCard('3', 'Planned', Icons.calendar_today, const Color(0xFF5E35B1), constraints.maxWidth),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCrewStatusCard(String value, String label, IconData icon, Color color, double maxWidth) {
    final cardWidth = (maxWidth - 36) / 2;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentActivity(),
          const SizedBox(height: 20),
          _buildQuickActionsMA(),
          const SizedBox(height: 20),
          _buildUpcomingEvents(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View all →'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityItem('New crew member approved', 'John Doe • 2 minutes ago', Icons.check_circle, const Color(0xFF43A047)),
          _buildActivityItem('Certificate expiring soon', 'Jane Smith - STCW • 15 min ago', Icons.warning_amber, const Color(0xFFFB8C00)),
          _buildActivityItem('Document uploaded', 'Mike Johnson - Medical Cert • 1h ago', Icons.upload_file, const Color(0xFF1E88E5)),
          _buildActivityItem('Interview scheduled', 'Sarah Williams - Chief Engineer • 2h ago', Icons.calendar_today, const Color(0xFF5E35B1)),
          _buildActivityItem('Application rejected', 'Tom Brown - Incomplete docs • 3h ago', Icons.cancel, const Color(0xFFE53935)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsMA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickActionButton('Add New Crew', 'Propose new crew member', Icons.person_add_alt_1, const Color(0xFF1E88E5)),
          _buildQuickActionButton('Schedule Crew', 'Manage crew schedules', Icons.calendar_today, const Color(0xFF43A047)),
          _buildQuickActionButton('Schedule Interview', 'Arrange crew interviews', Icons.people, const Color(0xFF7B68EE)),
          _buildQuickActionButton('Generate Report', 'Export crew data', Icons.assessment, const Color(0xFFFB8C00)),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          _buildEventItem('15', 'JAN', 'Certificate Renewal Deadline', '45 crew members'),
          _buildEventItem('20', 'JAN', 'Crew Rotation Schedule', 'MV Pertamina Explorer'),
          _buildEventItem('25', 'JAN', 'Training Session', 'Safety & Security Training'),
        ],
      ),
    );
  }

  Widget _buildEventItem(String day, String month, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E88E5).withOpacity(0.05),
            const Color(0xFF1565C0).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}