import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  final String username;

  const TutorialPage({super.key, required this.username});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialPages = [
    {
      'title': 'Welcome to Life Points',
      'description':
          'Life Points helps you manage your tasks in a fun and rewarding way. Complete tasks to earn points and build better habits!',
      'icon': Icons.stars,
    },
    {
      'title': 'Task Management',
      'description':
          'Create tasks with deadlines or untimed tasks. Organize your life and never miss important deadlines.',
      'icon': Icons.task_alt,
    },
    {
      'title': 'Point System',
      'description':
          'Earn points by completing tasks on time. The more challenging the task, the more points you earn!',
      'icon': Icons.emoji_events,
    },
    {
      'title': 'Deadline Tracking',
      'description':
          'Tasks approaching their deadline will show a countdown. Overdue tasks are highlighted in red.',
      'icon': Icons.timer,
    },
    {
      'title': 'Penalty System',
      'description':
          'Be careful! Missing deadlines will result in point deductions, encouraging you to stay on track.',
      'icon': Icons.remove_circle_outline,
    },
    {
      'title': 'Account Management',
      'description':
          'Manage your account information by clicking on your name at the home page.',
      'icon': Icons.account_circle_outlined,
    },
    {
      'title': 'Rewards Store',
      'description':
          'Spend your hard-earned points on rewards you set for yourself so that you can enjoy, Guilt Free!',
      'icon': Icons.store,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _tutorialPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page['icon'] as IconData,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['description'] as String,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _tutorialPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'Previous',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _tutorialPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Tutorial completed - clear stack and return to homepage
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false, // Remove all routes from stack
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _currentPage < _tutorialPages.length - 1
                              ? 'Next'
                              : 'Continue',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
