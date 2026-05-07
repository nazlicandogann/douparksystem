import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'create_reservation_screen.dart';
import 'reservations_screen.dart';
import 'login_screen.dart';
import 'wallet_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Token expire olduğunda kullanıcıyı login ekranına gönder
    ApiService.onSessionExpired = () async {
      ApiService.logout();
      AuthService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    };
  }

  void _changeTab(int index) {
    // Oluştur (1) ve Rezervasyonlar (2) için giriş gerekli
    if ((index == 1 || index == 2 || index == 3) && !AuthService.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) {
        // Giriş yapıldıysa ilgili sekmeye git
        if (AuthService.isLoggedIn) {
          setState(() {
            _selectedIndex = index;
          });
        }
      });
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goHome() {
    setState(() => _selectedIndex = 0);
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0: return const HomeScreen();
      case 1: return const CreateReservationScreen();
      case 2: return ReservationsScreen(onBack: _goHome);
      case 3: return const WalletScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _buildScreen(),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _changeTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.red,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: 'Oluştur',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Rezervasyonlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Cüzdan',
            ),
          ],
        ),
      ),
      ),
    );
  }
}