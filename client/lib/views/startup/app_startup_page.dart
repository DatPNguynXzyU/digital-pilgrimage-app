import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_theme.dart';
import '../main_nav.dart';

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({super.key});

  @override
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  late Future<bool> _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _onboardingComplete = _loadStartupState();
  }

  Future<bool> _loadStartupState() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('onboarding_complete') ?? false;
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainNavigation()),
    );
  }

  void _retry() {
    setState(() {
      _onboardingComplete = _loadStartupState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingComplete,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StartupError(onRetry: _retry);
        }

        if (!snapshot.hasData) {
          return const _SplashScreen();
        }

        if (snapshot.data!) {
          return const MainNavigation();
        }

        return _OnboardingPage(onComplete: _openHome);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.secondary.withValues(alpha: 0.65),
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.temple_buddhist_outlined,
                      size: 51,
                      color: AppTheme.surface,
                    ),
                    Positioned(
                      bottom: 10,
                      child: Icon(
                        Icons.local_florist_rounded,
                        size: 22,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 21),
              const Text(
                'HÀNH TRÌNH AN NHIÊN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.2,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Hành trình an nhiên – Lưu dấu chân hành hương',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 30),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const _OnboardingPage({required this.onComplete});

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _finishing = false;

  static const _slides = [
    (
      Icons.temple_buddhist_outlined,
      'Tìm về chốn bình yên',
      'Khám phá những ngôi chùa Việt và câu chuyện văn hóa phía sau mỗi ngôi chùa.',
      'CHÙA VIỆT · VĂN HÓA · HÀNH TRÌNH',
    ),
    (
      Icons.menu_book_outlined,
      'Dành thời gian lắng tâm',
      'Đọc kinh sách và tìm hiểu các biểu tượng Phật giáo trong một không gian thanh tịnh.',
      'KINH SÁCH · TRI THỨC · CHIÊM NGHIỆM',
    ),
    (
      Icons.local_activity_outlined,
      'Lưu dấu mỗi chuyến đi',
      'Check-in NFC và lưu giữ những con tem hành hương do hệ thống xác nhận.',
      'NFC · NHẬT KÝ · SỔ TEM',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setBool('onboarding_complete', true);
      if (!saved) {
        throw Exception('Không thể lưu trạng thái giới thiệu ứng dụng.');
      }
      if (mounted) widget.onComplete();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _advance() {
    if (_currentPage == _slides.length - 1) {
      _finish();
      return;
    }

    _pageController.nextPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishing ? null : _finish,
                child: const Text('Bỏ qua'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final (icon, title, description, eyebrow) = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.25,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 38,
                                  right: 35,
                                  child: Icon(
                                    Icons.circle_outlined,
                                    size: 150,
                                    color: AppTheme.secondary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                Icon(
                                  icon,
                                  size: 114,
                                  color: AppTheme.warmBrown,
                                ),
                                const Positioned(
                                  bottom: 35,
                                  child: Icon(
                                    Icons.local_florist_outlined,
                                    size: 32,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          eyebrow,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  ...List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      width: index == _currentPage ? 22 : 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppTheme.primary
                            : AppTheme.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _finishing ? null : _advance,
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Bắt đầu'
                          : 'Tiếp tục',
                    ),
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

class _StartupError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StartupError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.accent,
                size: 42,
              ),
              const SizedBox(height: 14),
              const Text(
                'Không thể khởi động ứng dụng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng thử lại.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      ),
    );
  }
}
