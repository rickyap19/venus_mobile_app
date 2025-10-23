import 'package:flutter/material.dart';
import 'package:pis_management_system/widgets/modern_menu_dropdown.dart';

class MenuConfig {
  // Manning Menu - Hanya untuk MA (Manning Agent)
  static List<MenuSection> getManningMenu(BuildContext context) {
    return [
      MenuSection(
        title: 'CREW SCHEDULING',
        items: [
          MenuItem(
            title: 'Propose Schedule',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.pushNamed(context, '/propose-schedule'),
          ),
          MenuItem(
            title: 'Schedule List',
            icon: Icons.list_alt_rounded,
            color: const Color(0xFF1565C0),
            onTap: () => Navigator.pushNamed(context, '/schedule-list'),
          ),
          MenuItem(
            title: 'SignedOff (Standby)',
            icon: Icons.schedule_rounded,
            color: const Color(0xFF0D47A1),
            onTap: () => Navigator.pushNamed(context, '/signed-off'),
          ),
        ],
      ),
      MenuSection(
        title: 'APPRAISAL',
        items: [
          MenuItem(
            title: 'Assign Appraiser For Fleet Manager',
            icon: Icons.assignment_ind_rounded,
            color: const Color(0xFF5E35B1),
            onTap: () => Navigator.pushNamed(context, '/assign-fleet-manager'),
          ),
          MenuItem(
            title: 'Assign Appraiser For LPSQManager',
            icon: Icons.assignment_turned_in_rounded,
            color: const Color(0xFF4527A0),
            onTap: () => Navigator.pushNamed(context, '/assign-lpsq-manager'),
          ),
          MenuItem(
            title: 'Appraisal On Process',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFF6A1B9A),
            onTap: () => Navigator.pushNamed(context, '/appraisal-process'),
          ),
          MenuItem(
            title: 'Appraisal Submitted',
            icon: Icons.done_all_rounded,
            color: const Color(0xFF7B1FA2),
            onTap: () => Navigator.pushNamed(context, '/appraisal-submitted'),
          ),
          MenuItem(
            title: 'Appraisal Approved',
            icon: Icons.verified_rounded,
            color: const Color(0xFF43A047),
            onTap: () => Navigator.pushNamed(context, '/appraisal-approved'),
          ),
          MenuItem(
            title: 'Appraisal Report by Additional Training',
            icon: Icons.school_rounded,
            color: const Color(0xFF00897B),
            onTap: () => Navigator.pushNamed(context, '/appraisal-training'),
          ),
        ],
      ),
    ];
  }

  // Recruitment Menu - Untuk MA (Manning Agent)
  static List<MenuSection> getRecruitmentMenu(BuildContext context) {
    return [
      MenuSection(
        title: 'APPLICATION',
        items: [
          MenuItem(
            title: 'New Applicants',
            icon: Icons.person_add_alt_1_rounded,
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.pushNamed(context, '/new-applicants'),
          ),
          MenuItem(
            title: 'Review Applications',
            icon: Icons.rate_review_rounded,
            color: const Color(0xFF5E35B1),
            onTap: () => Navigator.pushNamed(context, '/review-applications'),
          ),
          MenuItem(
            title: 'Interview Schedule',
            icon: Icons.event_available_rounded,
            color: const Color(0xFF00897B),
            onTap: () => Navigator.pushNamed(context, '/interview-schedule'),
          ),
        ],
      ),
      MenuSection(
        title: 'SELECTION',
        items: [
          MenuItem(
            title: 'Selection Checklist',
            icon: Icons.checklist_rtl_rounded,
            color: const Color(0xFF43A047),
            onTap: () => Navigator.pushNamed(context, '/selection-checklist'),
          ),
          MenuItem(
            title: 'Medical Checkup Results',
            icon: Icons.health_and_safety_rounded,
            color: const Color(0xFF3949AB),
            onTap: () => Navigator.pushNamed(context, '/mcu-results'),
          ),
          MenuItem(
            title: 'Accepted Candidates',
            icon: Icons.verified_rounded,
            color: const Color(0xFF43A047),
            onTap: () => Navigator.pushNamed(context, '/accepted-candidates'),
          ),
        ],
      ),
    ];
  }

  // Personal Data Menu - Khusus untuk APPLICANT
  static List<MenuSection> getPersonalDataMenu(BuildContext context) {
    return [
      MenuSection(
        title: 'MY PROFILE',
        items: [
          MenuItem(
            title: 'Personal Data',
            icon: Icons.person_outline_rounded,
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.pushNamed(context, '/personal-info'),
          ),

        ],
      ),

    ];
  }

  // Dashboard Menu (Optional) - Untuk semua role
  static List<MenuSection> getDashboardMenu(BuildContext context) {
    return [
      MenuSection(
        title: 'OVERVIEW',
        items: [
          MenuItem(
            title: 'Main Dashboard',
            icon: Icons.dashboard_rounded,
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          MenuItem(
            title: 'Analytics',
            icon: Icons.analytics_rounded,
            color: const Color(0xFF5E35B1),
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          MenuItem(
            title: 'Reports',
            icon: Icons.assessment_rounded,
            color: const Color(0xFFFB8C00),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
        ],
      ),
    ];
  }

  // Get Menu berdasarkan Role
  static List<MenuSection> getMenuByRole(BuildContext context, String role) {
    switch (role.toUpperCase()) {
      case 'APPLICANT':
        return getPersonalDataMenu(context);
      case 'MA': // Manning Agent
        return getRecruitmentMenu(context) + getManningMenu(context);
      default:
        return []; // Atau menu default lainnya
    }
  }

  // Check if menu should be shown based on role
  static bool shouldShowMenu(String menuType, String role) {
    role = role.toUpperCase();

    switch (menuType) {
      case 'recruitment':
        return role == 'MA';
      case 'manning':
        return role == 'MA';
      case 'personal_data':
        return role == 'APPLICANT';
      case 'dashboard':
        return role == 'MA';
      default:
        return false;
    }
  }
}