import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/screens/login.dart';
import 'package:my_first_app/features/auth/screens/terms_screen.dart';
import 'package:my_first_app/features/auth/screens/verification_screen.dart';
import 'package:my_first_app/features/patient/screens/book_service_screen.dart';
import 'package:my_first_app/features/patient/screens/booking_confirmation_screen.dart';
import 'package:my_first_app/features/patient/screens/bookings_screen.dart';
import 'package:my_first_app/features/patient/screens/categories_screen.dart';
import 'package:my_first_app/features/patient/screens/help_screen.dart';
import 'package:my_first_app/features/patient/screens/main_shell.dart';
import 'package:my_first_app/features/patient/screens/notifications_screen.dart';
import 'package:my_first_app/features/patient/screens/onboarding_screen.dart';
import 'package:my_first_app/features/patient/screens/personal_profile.dart';
import 'package:my_first_app/features/patient/screens/privacy_policy_screen.dart';
import 'package:my_first_app/features/patient/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/patient/screens/service_details_screen.dart';
import 'package:my_first_app/features/patient/screens/services_screen.dart';
import 'package:my_first_app/features/patient/screens/personal_info_screen.dart';
import 'package:my_first_app/features/patient/screens/edit_personal_info_screen.dart';
import 'package:my_first_app/features/patient/screens/addresses_screen.dart';
import 'package:my_first_app/features/patient/screens/address_form_screen.dart';
import 'package:my_first_app/features/patient/screens/medical_record_screen.dart';
import 'package:my_first_app/features/patient/screens/edit_medical_record_screen.dart';
import 'package:my_first_app/features/patient/screens/settings_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_notifications_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_patient_profile_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_shell.dart';
import 'package:my_first_app/features/provider/screens/provider_home_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_appointments_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_patients_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_profile_screen.dart'
    as provider_app;
import 'package:my_first_app/features/provider/screens/provider_appointment_details_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_visit_report_screen.dart';
import 'package:my_first_app/features/provider/screens/provider_report_view_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // general

    // patient
    //"Main": (context) =>MainShell(),
    "Onboarding": (context) => OnboardingScreen(),
    "Login": (context) => LoginScreen(),
    "Verification": (context) => VerificationScreen(),
    "Terms": (context) => TermsScreen(),
    "Notifications": (context) => NotificationsScreen(),
    "Home": (context) => MainShell(),
    "Categories": (context) => CategoriesScreen(),
    "Services": (context) => ServicesScreen(),
    "ServiceDetails": (context) => ServiceDetailsScreen(),
    "ProviderProfile": (context) => ProviderProfileScreen(),
    "Bookings": (context) => BookingsScreen(),
    "BookService": (context) => BookServiceScreen(),
    "BookingConfirmation": (context) => BookingConfirmationScreen(),
    "PersonalProfileScreen": (context) => PersonalProfileScreen(),
    "PersonalInfo": (context) => const PersonalInfoScreen(),
    "EditPersonalInfo": (context) => const EditPersonalInfoScreen(),
    "Help": (context) => const HelpScreen(),
    "Addresses": (context) => const AddressesScreen(),
    "AddAddress": (context) => const AddressFormScreen(),
    "MedicalRecord": (context) => const MedicalRecordScreen(),
    "EditMedicalRecord": (context) => const EditMedicalRecordScreen(),
    "Settings": (context) => const SettingsScreen(),
    "PrivacyPolicy": (context) => const PrivacyPolicyScreen(),

    // provider
    "ProviderHome": (context) => const ProviderShell(),
    "ProviderHomeScreen": (context) => const ProviderHomeScreen(),
    "ProviderAppointments": (context) => const ProviderAppointmentsScreen(),
    "ProviderPatients": (context) => const ProviderPatientsScreen(),
    "ProviderMyProfile": (context) =>
        const provider_app.ProviderMyProfileScreen(),
    "ProviderNotifications": (context) => const ProviderNotificationsScreen(),
    "ProviderAppointmentDetails": (context) =>
        const ProviderAppointmentDetailsScreen(),
    "ProviderVisitReport": (context) => const ProviderVisitReportScreen(),
    "ProviderReportView": (context) => const ProviderReportViewScreen(),
    "ProviderPatientProfile": (context) =>
    const ProviderPatientProfileScreen(),
  };
}
