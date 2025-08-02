import 'package:flutter/material.dart';
import 'package:message_app/data/message_data.dart';
import 'package:message_app/data/menu_data.dart';
import 'package:message_app/Data/edit_menu_data.dart';
import 'dart:ui';

// Main application entry point
void main() => runApp(const MyApp());

/// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(), // Set MyHomePage as the initial screen
    );
  }
}

/// The home page widget that contains the main message app interface
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state class for MyHomePage that manages all the interactive elements
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // State variables to control menu visibility
  bool _showMenu = false; // Controls the main menu (three-line menu)
  bool _showEditMenu = false; // Controls the edit menu

  // Animation controllers and animations for the menus
  late AnimationController _animationController; // For main menu animations
  late AnimationController _editMenuAnimationController; // For edit menu animations

  // Main menu animations
  late Animation<double> _widthAnimation; // Controls menu width expansion
  late Animation<double> _heightAnimation; // Controls menu height expansion
  late Animation<double> _opacityAnimation; // Controls menu fade in/out
  late Animation<double> _scaleAnimation; // Controls menu scale effect
  late Animation<BorderRadius?> _borderRadiusAnimation; // Controls border radius change
  late Animation<double> _iconOpacityAnimation; // Controls hamburger icon fade
  late Animation<Offset> _contentOffsetAnimation; // Controls menu content slide effect

  // Edit menu animations (similar to main menu but with different parameters)
  late Animation<double> _editWidthAnimation;
  late Animation<double> _editHeightAnimation;
  late Animation<double> _editOpacityAnimation;
  late Animation<double> _editScaleAnimation;
  late Animation<BorderRadius?> _editBorderRadiusAnimation;
  late Animation<Offset> _editContentOffsetAnimation;

  // Keys to identify the menu widgets for hit testing
  final GlobalKey menuKey = GlobalKey();
  final GlobalKey editMenuKey = GlobalKey();

  // Variables for message pagination
  int _visibleMessagesCount = 10; // Number of messages currently visible
  final int _messagesPerPage = 10; // Number of messages to load at once
  final ScrollController _scrollController = ScrollController(); // Controls message list scrolling

  bool _showNavMessage = false; // Controls visibility of the title when scrolling

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with 350ms duration
    _animationController = AnimationController(
      vsync: this, // Uses the TickerProviderStateMixin
      duration: const Duration(milliseconds: 350),
    );

    _editMenuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Set up all the animations for the main menu
    _setupMainMenuAnimations();

    // Set up all the animations for the edit menu
    _setupEditMenuAnimations();

    // Add scroll listener to show/hide the navigation title
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _showNavMessage = _scrollController.offset > 60;
        });
      }
    });
  }

  /// Sets up all animation configurations for the main menu
  void _setupMainMenuAnimations() {
    // Width animation: expands from 44 to 240 pixels
    _widthAnimation = Tween<double>(begin: 44, end: 240).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Smooth easing curve
    ));

    // Height animation: expands from 44 to 280 pixels
    _heightAnimation = Tween<double>(begin: 44, end: 280).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Opacity animation: fades from 30% to 90% opacity
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Scale animation: grows from 90% to 100% size
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Border radius animation: transitions from circular to rounded rectangle
    _borderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(22),
      end: BorderRadius.circular(40),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Icon opacity: fades out the hamburger icon quickly (first 30% of animation)
    _iconOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));

    // Content offset: slides content down slightly when opening
    _contentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  /// Sets up all animation configurations for the edit menu
  void _setupEditMenuAnimations() {
    // Similar to main menu but with different starting values
    _editWidthAnimation = Tween<double>(begin: 84, end: 240).animate(CurvedAnimation(
      parent: _editMenuAnimationController,
      curve: Curves.easeInOut,
    ));

    _editHeightAnimation = Tween<double>(begin: 44, end: 180).animate(CurvedAnimation(
      parent: _editMenuAnimationController,
      curve: Curves.easeInOut,
    ));

    _editOpacityAnimation = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(
      parent: _editMenuAnimationController,
      curve: Curves.easeInOut,
    ));

    _editScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _editMenuAnimationController,
      curve: Curves.easeInOut,
    ));

    _editBorderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(22),
      end: BorderRadius.circular(40),
    ).animate(CurvedAnimation(parent: _editMenuAnimationController, curve: Curves.easeInOut));

    _editContentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _editMenuAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // Clean up all controllers when widget is disposed
    _animationController.dispose();
    _editMenuAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Toggles the main menu visibility and handles animation
  void _toggleMenu() {
    setState(() {
      if (_showEditMenu) {
        // If edit menu is open, close it first
        _showEditMenu = false;
        _editMenuAnimationController.reverse();
        return;
      }

      // Toggle main menu state
      _showMenu = !_showMenu;
      if (_showMenu) {
        _animationController.forward(); // Animate open
      } else {
        _animationController.reverse(); // Animate closed
      }
    });
  }

  /// Toggles the edit menu visibility and handles animation
  void _toggleEditMenu() {
    setState(() {
      if (_showMenu) {
        // If main menu is open, close it first
        _showMenu = false;
        _animationController.reverse();
        return;
      }

      // Toggle edit menu state
      _showEditMenu = !_showEditMenu;
      if (_showEditMenu) {
        _editMenuAnimationController.forward(); // Animate open
      } else {
        _editMenuAnimationController.reverse(); // Animate closed
      }
    });
  }

  /// Loads more messages when "View More" is tapped
  Future<void> _loadMoreMessages() async {
    final previousCount = _visibleMessagesCount;
    setState(() {
      _visibleMessagesCount += _messagesPerPage;
      // Don't exceed total message count
      if (_visibleMessagesCount > messages.length) {
        _visibleMessagesCount = messages.length;
      }
    });

    // Wait briefly for the widget to rebuild with new messages
    await Future.delayed(const Duration(milliseconds: 50));

    // Scroll to show the newly loaded messages
    final position = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Checks if a tap position is inside the main menu
  bool _isInsideMenu(Offset position) {
    final renderBox = menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height)
          .contains(position);
    }
    return false;
  }

  /// Checks if a tap position is inside the edit menu
  bool _isInsideEditMenu(Offset position) {
    final renderBox = editMenuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height)
          .contains(position);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently visible messages based on pagination
    final visibleMessages = messages.take(_visibleMessagesCount).toList();
    final hasMoreMessages = _visibleMessagesCount < messages.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content column (messages list and search bar)
            Column(
              children: [
                // Expanded message list area
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      // Close menus if tapped outside of them
                      if (_showMenu && !_isInsideMenu(details.globalPosition)) {
                        _toggleMenu();
                      }
                      if (_showEditMenu && !_isInsideEditMenu(details.globalPosition)) {
                        _toggleEditMenu();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                // Message list with header
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(top: 70), // Space for top menus
                                    itemCount: visibleMessages.length + 1, // +1 for header
                                    itemBuilder: (context, index) {
                                      // First item is the "Messages" header
                                      if (index == 0) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Messages',
                                              style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      // Build message items
                                      final message = visibleMessages[index - 1];
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return FadeTransition(opacity: animation, child: child);
                                        },
                                        child: Padding(
                                          key: ValueKey(message.senderName), // Unique key for animation
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Row(
                                            children: [
                                              // Sender avatar
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Color.fromRGBO(109, 143, 175, 1),
                                                child: Icon(
                                                  message.avatarIcon,
                                                  size: 28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Message content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Sender name and time row
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            message.senderName,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: message.isRead
                                                                  ? FontWeight.normal
                                                                  : FontWeight.bold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          message.time,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                            fontWeight: message.isRead
                                                                ? FontWeight.normal
                                                                : FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    // Message preview text
                                                    Text(
                                                      message.lastMessage,
                                                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // "View More" button if there are more messages to load
                                if (hasMoreMessages)
                                  Container(
                                    child: TextButton(
                                      onPressed: _loadMoreMessages,
                                      child: Text(
                                        'View More',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom search bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Search bar
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(Icons.search, size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.mic, size: 20, color: Colors.grey[700]),
                                padding: const EdgeInsets.all(8),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      // Notes button
                      const SizedBox(width: 12),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.note_alt_outlined, size: 24, color: Colors.grey[700]),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            // Overlay for the menus and blur effect
            Container(
              child: Stack(
                children: [
                  // Blur overlay that appears behind the menus
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          height: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  // "Messages" title that appears when scrolling
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showNavMessage ? 1.0 : 0.0,
                      child: Center(
                        child: Text(
                          "Messages",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Main menu (three-line menu on the right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        if (!_showMenu) _toggleMenu();
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final double currentWidth = _widthAnimation.value.clamp(44, 220);
                          final bool canShowContent = currentWidth > 100;

                          return ClipRRect(
                            borderRadius: _borderRadiusAnimation.value ?? BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _showMenu ? 1.5 : 0,
                                sigmaY: _showMenu ? 1.5 : 0,
                              ),
                              child: Opacity(
                                opacity: 0.8,
                                child: Material(
                                  borderRadius: _borderRadiusAnimation.value,
                                  elevation: 2,
                                  child: Container(
                                    key: menuKey,
                                    width: currentWidth,
                                    height: _heightAnimation.value,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(_showMenu ? 0.7 : 0.9),
                                      borderRadius: _borderRadiusAnimation.value,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1 * _opacityAnimation.value),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _showMenu
                                        ? Opacity(
                                      opacity: _opacityAnimation.value,
                                      child: Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: Transform.translate(
                                          offset: _contentOffsetAnimation.value,
                                          child: canShowContent
                                              ? SingleChildScrollView(
                                            physics: const NeverScrollableScrollPhysics(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                for (final item in menuItems)
                                                  Builder(
                                                    builder: (_) {
                                                      // Handle different menu item types
                                                      if (item.containsKey('divider')) {
                                                        return Divider(height: 0.5, color: Colors.grey[500]);
                                                      } else if (item.containsKey('header')) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(left: 0, top: 12, bottom: 8),
                                                          child: Text(
                                                            item['header'],
                                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        );
                                                      } else {
                                                        return _buildMenuItem(
                                                          icon: item['icon'],
                                                          text: item['text'],
                                                          hasCheckmark: item['check'] ?? false,
                                                        );
                                                      }
                                                    },
                                                  ),
                                              ],
                                            ),
                                          )
                                              : const SizedBox(),
                                        ),
                                      ),
                                    )
                                        : Opacity(
                                      opacity: _iconOpacityAnimation.value,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Hamburger icon lines
                                          Container(height: 2.5, width: 20, margin: const EdgeInsets.only(bottom: 4), color: Colors.black),
                                          Container(height: 2, width: 14, margin: const EdgeInsets.only(bottom: 4), color: Colors.black),
                                          Container(height: 2, width: 10, color: Colors.black),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Edit menu (on the left)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: _toggleEditMenu,
                      child: AnimatedBuilder(
                        animation: _editMenuAnimationController,
                        builder: (context, child) {
                          return _showEditMenu
                              ? ClipRRect(
                            borderRadius: _editBorderRadiusAnimation.value ?? BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                              child: Opacity(
                                opacity: 0.8,
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: _editBorderRadiusAnimation.value,
                                  elevation: 2,
                                  child: Container(
                                    key: editMenuKey,
                                    width: _editWidthAnimation.value,
                                    height: _editHeightAnimation.value,
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: _editBorderRadiusAnimation.value,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1 * _editOpacityAnimation.value),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Opacity(
                                      opacity: _editOpacityAnimation.value,
                                      child: Transform.scale(
                                        scale: _editScaleAnimation.value,
                                        child: Transform.translate(
                                          offset: _editContentOffsetAnimation.value,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return SingleChildScrollView(
                                                physics: const ClampingScrollPhysics(),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minHeight: constraints.maxHeight,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Build edit menu items from the imported list
                                                      for (final item in editMenuItems)
                                                        _buildEditMenuItem(
                                                          icon: item['icon'],
                                                          text: item['text'],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Material(
                            borderRadius: _editBorderRadiusAnimation.value,
                            elevation: 2,
                            child: Container(
                              key: editMenuKey,
                              width: _editWidthAnimation.value,
                              height: _editHeightAnimation.value,
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: _editBorderRadiusAnimation.value,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1 * _editOpacityAnimation.value),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 19),
                                    child: Text('Edit'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Builds a standard menu item with icon and text
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    bool hasCheckmark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasCheckmark) const Icon(Icons.check, size: 20, color: Colors.black),
          if (hasCheckmark) const SizedBox(width: 8),
          Icon(icon, size: 22, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an edit menu item with icon and text
  Widget _buildEditMenuItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}