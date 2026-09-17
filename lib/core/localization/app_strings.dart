import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight localization layer.
///
/// Every user facing string lives here, keyed by id, so translations stay
/// central. Patient UI is always Arabic/RTL; caregiver UI can switch to
/// English. Can be swapped for ARB/gen-l10n later without touching widgets.
enum AppLanguage { ar, en }

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  static const Map<String, Map<AppLanguage, String>> _values = {
    // --- shared / auth
    'appName': {AppLanguage.ar: 'نظام رعاية الزهايمر', AppLanguage.en: 'MindGuard'},
    'appTagline': {
      AppLanguage.ar: 'نظام ذكي لرعاية مرضى الزهايمر بتقنيات الذكاء الاصطناعي',
      AppLanguage.en: 'A smart care system for Alzheimer\'s patients',
    },
    'login': {AppLanguage.ar: 'تسجيل الدخول', AppLanguage.en: 'Log in'},
    'register': {AppLanguage.ar: 'إنشاء حساب جديد', AppLanguage.en: 'Create account'},
    'logout': {AppLanguage.ar: 'خروج', AppLanguage.en: 'Log out'},
    'email': {AppLanguage.ar: 'البريد الإلكتروني', AppLanguage.en: 'Email'},
    'password': {AppLanguage.ar: 'كلمة المرور', AppLanguage.en: 'Password'},
    'fullName': {AppLanguage.ar: 'الاسم بالكامل', AppLanguage.en: 'Full name'},
    'forgotPassword': {AppLanguage.ar: 'نسيت كلمة المرور؟', AppLanguage.en: 'Forgot password?'},
    'role': {AppLanguage.ar: 'نوع الحساب', AppLanguage.en: 'Account type'},
    'patient': {AppLanguage.ar: 'المريض', AppLanguage.en: 'Patient'},
    'caregiver': {AppLanguage.ar: 'المرافق', AppLanguage.en: 'Caregiver'},
    'patientApp': {AppLanguage.ar: 'تطبيق المريض', AppLanguage.en: 'Patient app'},
    'caregiverApp': {AppLanguage.ar: 'المرافق', AppLanguage.en: 'Caregiver'},
    'retry': {AppLanguage.ar: 'إعادة المحاولة', AppLanguage.en: 'Try again'},
    'loadFailed': {AppLanguage.ar: 'تعذّر تحميل البيانات', AppLanguage.en: 'Could not load data'},
    'empty': {AppLanguage.ar: 'لا توجد بيانات بعد', AppLanguage.en: 'Nothing here yet'},
    'gpsLocation': {AppLanguage.ar: 'تتبع الموقع', AppLanguage.en: 'Location'},
    'memoryReminders': {AppLanguage.ar: 'تذكير الأدوية', AppLanguage.en: 'Medication'},
    'aiFeature': {AppLanguage.ar: 'ذكاء اصطناعي', AppLanguage.en: 'AI'},

    // --- patient navigation
    'navHome': {AppLanguage.ar: 'الرئيسية', AppLanguage.en: 'Home'},
    'navExercises': {AppLanguage.ar: 'التمارين', AppLanguage.en: 'Exercises'},
    'navMedications': {AppLanguage.ar: 'الأدوية', AppLanguage.en: 'Medication'},
    'navFamily': {AppLanguage.ar: 'العائلة', AppLanguage.en: 'Family'},
    'navHealth': {AppLanguage.ar: 'صحتي', AppLanguage.en: 'Health'},

    // --- patient home
    'greetingEvening': {AppLanguage.ar: 'مساء النور', AppLanguage.en: 'Good evening'},
    'greetingMorning': {AppLanguage.ar: 'صباح النور', AppLanguage.en: 'Good morning'},
    'howAreYouToday': {AppLanguage.ar: 'كيف حالك اليوم؟', AppLanguage.en: 'How are you today?'},
    'todayInfo': {AppLanguage.ar: 'معلومات اليوم', AppLanguage.en: 'Today'},
    'day': {AppLanguage.ar: 'اليوم', AppLanguage.en: 'Day'},
    'date': {AppLanguage.ar: 'التاريخ', AppLanguage.en: 'Date'},
    'time': {AppLanguage.ar: 'الوقت', AppLanguage.en: 'Time'},
    'quickActions': {AppLanguage.ar: 'الإجراءات السريعة', AppLanguage.en: 'Quick actions'},
    'memoryExercises': {AppLanguage.ar: 'تمارين الذاكرة', AppLanguage.en: 'Memory exercises'},
    'startTodayExercise': {AppLanguage.ar: 'ابدأ تمرين اليوم', AppLanguage.en: 'Start today\'s exercise'},
    'medications': {AppLanguage.ar: 'الأدوية', AppLanguage.en: 'Medications'},
    'nextDose': {AppLanguage.ar: 'موعد دواء الضغط', AppLanguage.en: 'Next dose'},
    'familiarFaces': {AppLanguage.ar: 'وجوه مألوفة', AppLanguage.en: 'Familiar faces'},
    'knowYourFamily': {AppLanguage.ar: 'تعرّف على العائلة', AppLanguage.en: 'Know your family'},
    'myLocation': {AppLanguage.ar: 'موقعي', AppLanguage.en: 'My location'},
    'shareLocation': {AppLanguage.ar: 'مشاركة موقعي', AppLanguage.en: 'Share my location'},
    'todayMedications': {AppLanguage.ar: 'أدوية اليوم', AppLanguage.en: 'Today\'s medications'},
    'sos': {AppLanguage.ar: 'استغاثة', AppLanguage.en: 'SOS'},
    'sosSent': {AppLanguage.ar: 'تم إرسال طلب الاستغاثة للمرافق', AppLanguage.en: 'Emergency alert sent'},

    // --- exercises
    'exercisesSubtitle': {AppLanguage.ar: 'ذكاء اصطناعي تكيّفي', AppLanguage.en: 'Adaptive AI'},
    'todayExercise': {AppLanguage.ar: 'تمرين ذاكرة اليوم', AppLanguage.en: 'Today\'s memory exercise'},
    'answerFourQuestions': {AppLanguage.ar: 'ستجيب على 4 أسئلة متنوعة', AppLanguage.en: 'Answer 4 questions'},
    'adaptiveDifficulty': {
      AppLanguage.ar: 'مستوى الأسئلة يتكيّف مع أدائك تلقائيًا',
      AppLanguage.en: 'Difficulty adapts to your performance',
    },
    'startExercise': {AppLanguage.ar: 'ابدأ التمرين', AppLanguage.en: 'Start exercise'},

    // --- medications
    'medicationsTitle': {AppLanguage.ar: 'تذكير الأدوية', AppLanguage.en: 'Medication reminders'},
    'medicationsSubtitle': {AppLanguage.ar: 'مواعيد أدويتك اليوم', AppLanguage.en: 'Your doses today'},
    'taken': {AppLanguage.ar: 'تم التناول', AppLanguage.en: 'Taken'},
    'notTaken': {AppLanguage.ar: 'لم يتناول بعد', AppLanguage.en: 'Not taken yet'},
    'done': {AppLanguage.ar: 'تم', AppLanguage.en: 'Done'},
    'pending': {AppLanguage.ar: 'معلق', AppLanguage.en: 'Pending'},
    'aiAnalysis': {AppLanguage.ar: 'تحليل الذكاء الاصطناعي', AppLanguage.en: 'AI analysis'},

    // --- family
    'familyTitle': {AppLanguage.ar: 'وجوه مألوفة', AppLanguage.en: 'Familiar faces'},
    'familySubtitle': {AppLanguage.ar: 'أفراد عائلتك المحبوبون', AppLanguage.en: 'Your loved ones'},
    'familyHint': {
      AppLanguage.ar: 'اضغط على زر الصوت لسماع اسم الشخص — المرافق يمكنه إضافة المزيد',
      AppLanguage.en: 'Tap the sound button to hear the name',
    },

    // --- health
    'healthTitle': {AppLanguage.ar: 'صحتي', AppLanguage.en: 'My health'},
    'healthSubtitle': {AppLanguage.ar: 'بيانات الساعة الذكية', AppLanguage.en: 'Smart watch data'},
    'heartRate': {AppLanguage.ar: 'معدل القلب', AppLanguage.en: 'Heart rate'},
    'oxygen': {AppLanguage.ar: 'الأكسجين', AppLanguage.en: 'Oxygen'},
    'steps': {AppLanguage.ar: 'الخطوات', AppLanguage.en: 'Steps'},
    'sleep': {AppLanguage.ar: 'النوم الليلة', AppLanguage.en: 'Sleep'},
    'heartRateToday': {AppLanguage.ar: 'معدل القلب اليوم', AppLanguage.en: 'Heart rate today'},
    'healthGood': {AppLanguage.ar: 'الحالة الصحية جيدة', AppLanguage.en: 'Health status is good'},
    'healthGoodSub': {AppLanguage.ar: 'جميع المؤشرات الحيوية طبيعية', AppLanguage.en: 'All vitals normal'},
    'watchNotPaired': {
      AppLanguage.ar: 'لم يتم ربط ساعة ذكية بعد',
      AppLanguage.en: 'No smart watch paired yet',
    },

    // --- caregiver
    'navDashboard': {AppLanguage.ar: 'لوحة التحكم', AppLanguage.en: 'Dashboard'},
    'navTracking': {AppLanguage.ar: 'التتبع', AppLanguage.en: 'Tracking'},
    'navReports': {AppLanguage.ar: 'التقارير', AppLanguage.en: 'Reports'},
    'navWatch': {AppLanguage.ar: 'الساعة', AppLanguage.en: 'Watch'},
    'dashboard': {AppLanguage.ar: 'لوحة التحكم', AppLanguage.en: 'Dashboard'},
    'atHome': {AppLanguage.ar: 'في المنزل', AppLanguage.en: 'At home'},
    'lastUpdate': {AppLanguage.ar: 'آخر تحديث', AppLanguage.en: 'Last update'},
    'callPatient': {AppLanguage.ar: 'يتصل', AppLanguage.en: 'Call'},
    'memoryScore': {AppLanguage.ar: 'الذاكرة', AppLanguage.en: 'Memory'},
    'weeklyMemoryScore': {AppLanguage.ar: 'درجة الذاكرة الأسبوعية', AppLanguage.en: 'Weekly memory score'},
    'todayAlerts': {AppLanguage.ar: 'تنبيهات اليوم', AppLanguage.en: 'Today\'s alerts'},
    'medicationManager': {AppLanguage.ar: 'مدير الأدوية', AppLanguage.en: 'Medication manager'},
    'medicationManagerSub': {
      AppLanguage.ar: 'إدارة مواعيد أدوية المريض',
      AppLanguage.en: 'Manage the patient\'s doses',
    },
    'voiceNotes': {AppLanguage.ar: 'رسائل صوتية من العائلة', AppLanguage.en: 'Family voice notes'},
    'recordVoiceNote': {AppLanguage.ar: 'تسجيل رسالة جديدة', AppLanguage.en: 'Record a new note'},
    'reportsTitle': {AppLanguage.ar: 'التقارير والتقدّم', AppLanguage.en: 'Reports & progress'},
    'reportsSubtitle': {AppLanguage.ar: 'متابعة تطور حالة المريض', AppLanguage.en: 'Track patient progress'},
    'daily': {AppLanguage.ar: 'يومي', AppLanguage.en: 'Daily'},
    'weekly': {AppLanguage.ar: 'أسبوعي', AppLanguage.en: 'Weekly'},
    'memoryScoreLabel': {AppLanguage.ar: 'درجة الذاكرة', AppLanguage.en: 'Memory score'},
    'adherence': {AppLanguage.ar: 'الالتزام بالأدوية', AppLanguage.en: 'Medication adherence'},
    'zoneExits': {AppLanguage.ar: 'خروج النطاق', AppLanguage.en: 'Zone exits'},
    'avgSteps': {AppLanguage.ar: 'متوسط الخطوات', AppLanguage.en: 'Average steps'},
    'memoryTrend': {AppLanguage.ar: 'تطور درجة الذاكرة', AppLanguage.en: 'Memory score trend'},
    'todayReport': {AppLanguage.ar: 'تقرير اليوم', AppLanguage.en: 'Today\'s report'},
    'addMedication': {AppLanguage.ar: 'إضافة دواء', AppLanguage.en: 'Add medication'},
  };

  String t(String key) => _values[key]?[language] ?? _values[key]?[AppLanguage.ar] ?? key;
}

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.ar);

final stringsProvider = Provider<AppStrings>((ref) => AppStrings(ref.watch(languageProvider)));

/// Patient UI is locked to Arabic/RTL regardless of the caregiver preference.
class PatientDirectionality extends StatelessWidget {
  const PatientDirectionality({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality(textDirection: TextDirection.rtl, child: child);
}
