import 'package:flutter/material.dart';
import 'package:message_app/models/message_model.dart';
import 'package:message_app/data/message_data.dart';
import 'package:message_app/data/menu_data.dart';
import 'package:message_app/Data/edit_menu_data.dart'; // New import
import 'dart:ui';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _showMenu = false;
  bool _showEditMenu = false;

  late AnimationController _animationController;
  late AnimationController _editMenuAnimationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<BorderRadius?> _borderRadiusAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<Offset> _contentOffsetAnimation;

  // Edit menu animations
  late Animation<double> _editWidthAnimation;
  late Animation<double> _editHeightAnimation;
  late Animation<double> _editOpacityAnimation;
  late Animation<double> _editScaleAnimation;
  late Animation<BorderRadius?> _editBorderRadiusAnimation;
  late Animation<Offset> _editContentOffsetAnimation;

  final GlobalKey menuKey = GlobalKey();
  final GlobalKey editMenuKey = GlobalKey();

  // Pagination variables
  int _visibleMessagesCount = 10;
  final int _messagesPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  bool _showNavMessage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _editMenuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Main menu animations
    _widthAnimation = Tween<double>(begin: 44, end: 240).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _heightAnimation = Tween<double>(begin: 44, end: 280).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _borderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(22),
      end: BorderRadius.circular(40),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _iconOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));
    _contentOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Edit menu animations
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
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _showNavMessage = _scrollController.offset > 60;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _editMenuAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      if (_showEditMenu) {
        _showEditMenu = false;
        _editMenuAnimationController.reverse();
        return;
      }

      _showMenu = !_showMenu;
      if (_showMenu) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleEditMenu() {
    setState(() {
      if (_showMenu) {
        _showMenu = false;
        _animationController.reverse();
        return;
      }

      _showEditMenu = !_showEditMenu;
      if (_showEditMenu) {
        _editMenuAnimationController.forward();
      } else {
        _editMenuAnimationController.reverse();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    final previousCount = _visibleMessagesCount;
    setState(() {
      _visibleMessagesCount += _messagesPerPage;
      if (_visibleMessagesCount > messages.length) {
        _visibleMessagesCount = messages.length;
      }
    });

    await Future.delayed(const Duration(milliseconds: 50));
    final position = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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
    final visibleMessages = messages.take(_visibleMessagesCount).toList();
    final hasMoreMessages = _visibleMessagesCount < messages.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
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
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(top: 70),
                                    itemCount: visibleMessages.length + 1,
                                    itemBuilder: (context, index) {
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

                                      final message = visibleMessages[index - 1];
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return FadeTransition(opacity: animation, child: child);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Row(
                                            children: [
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
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
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
            Container(
              child: Stack(
                children: [
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
                                                      for (final item in editMenuItems) // Using the imported list
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