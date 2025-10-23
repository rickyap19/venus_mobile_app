import 'package:flutter/material.dart';

class ModernMenuDropdown extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<MenuSection> sections;
  final Color? primaryColor;
  final Color? secondaryColor;

  const ModernMenuDropdown({
    Key? key,
    required this.title,
    required this.icon,
    required this.sections,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<ModernMenuDropdown> createState() => _ModernMenuDropdownState();
}

class _ModernMenuDropdownState extends State<ModernMenuDropdown>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _closeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Calculate if menu should open upward or downward
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - offset.dy - size.height;
    final menuHeight = _calculateMenuHeight();
    final openUpward = spaceBelow < menuHeight && offset.dy > menuHeight;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: 280,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: openUpward
                    ? Offset(0, -menuHeight - 8)
                    : Offset(0, size.height + 8),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_animation.value * 0.2),
                        alignment: openUpward
                            ? Alignment.bottomCenter
                            : Alignment.topCenter,
                        child: Opacity(
                          opacity: _animation.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildMenuContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMenuHeight() {
    double height = 60.0; // Header
    for (var section in widget.sections) {
      height += 40.0; // Section title
      height += section.items.length * 52.0; // Menu items
      height += 8.0; // Bottom padding
    }
    height += (widget.sections.length - 1) * 1.0; // Dividers
    return height;
  }

  Widget _buildMenuContent() {
    final primaryColor = widget.primaryColor ?? const Color(0xFF1E88E5);
    final secondaryColor = widget.secondaryColor ?? const Color(0xFF1565C0);

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < widget.sections.length; i++) ...[
                      if (i > 0) Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                      _buildMenuSection(widget.sections[i]),
                    ],
                  ],
                ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            section.title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...section.items.map((item) => _buildMenuItem(item)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _closeMenu();
          if (item.onTap != null) {
            item.onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                    height: 1.3,
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
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model classes
class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({
    required this.title,
    required this.items,
  });
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
