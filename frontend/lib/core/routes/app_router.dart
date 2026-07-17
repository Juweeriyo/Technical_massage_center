import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/appointments/presentation/appointments_screen.dart';
import '../../features/treatments/presentation/treatments_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/diagnosis/presentation/diagnosis_screen.dart';
import '../../features/dashboard/presentation/admin_dashboard.dart';
import '../../features/dashboard/presentation/doctor_dashboard.dart';
import '../../features/dashboard/presentation/staff_dashboard.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const PatientsScreen(),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/treatments',
        builder: (context, state) => const TreatmentsScreen(),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/diagnoses',
        builder: (context, state) => const DiagnosisScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboard(),
      ),
      GoRoute(
        path: '/staff-dashboard',
        builder: (context, state) => const StaffDashboard(),
      ),
    ],
  );
});
