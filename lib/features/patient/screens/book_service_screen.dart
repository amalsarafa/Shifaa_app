// lib/features/patient/screens/book_service_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/patient/screens/provider_profile_screen.dart';
import 'package:my_first_app/features/patient/services/address_model.dart';
import 'package:my_first_app/features/patient/services/availability_repository.dart';
import 'package:my_first_app/features/patient/services/patient_repository.dart';
import 'package:my_first_app/features/patient/services/service_models.dart';
import 'package:my_first_app/features/patient/widgets/app_button.dart';

/// بيانات الحجز اللي بتنتقل لشاشة التأكيد
class BookingDraft {
  final CareProvider provider;
  final ServiceItem service;
  final String categoryTitle;
  final DateTime date;
  final String time; // "HH:mm"
  final Address address;
  final String notes;

  const BookingDraft({
    required this.provider,
    required this.service,
    required this.categoryTitle,
    required this.date,
    required this.time,
    required this.address,
    required this.notes,
  });
}

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  static const String _font = 'Cairo';
  static const Color _border = AppColors.border;
  static const Color _disabledBg = AppColors.neutralLight;
  static const Color _disabledText = AppColors.neutralNormal;

  /// عدد الأيام المعروضة (نافذة الحجز)
  static const int _daysCount = 7;

  // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  static const _dayNames = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const _monthNames = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final _notesCtrl = TextEditingController();
  final Map<DateTime, List<TimeSlot>> _slots = {};

  late ProviderProfileArgs _args;
  late List<DateTime> _days;
  bool _ready = false;

  DateTime? _selectedDay;
  String? _selectedTime;

  /// يبدأ بالعنوان الافتراضي للمريض
  late Address _address = PatientRepository.current.value.address;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;

    _args = ModalRoute.of(context)!.settings.arguments as ProviderProfileArgs;

    final today = DateTime.now();
    _days = List.generate(
      _daysCount,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
    for (final d in _days) {
      _slots[d] = AvailabilityRepository.slotsFor(
        providerKey: _args.provider.name, // لاحقاً: provider.id
        date: d,
      );
    }
    // أول يوم فيه وقت متاح
    for (final d in _days) {
      if (_hasFree(d)) {
        _selectedDay = d;
        break;
      }
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool _hasFree(DateTime d) => (_slots[d] ?? const []).any((s) => !s.isBooked);

  String _fmtTime(String t) {
    final h = int.parse(t.substring(0, 2));
    final m = t.substring(3);
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m ${h >= 12 ? 'م' : 'ص'}';
  }

  String _initial(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0];
  }

  /// ثيم الشاشة بخط Cairo. بنستخدمه للشاشة وللنوافذ المنبثقة
  /// (النوافذ بتنفتح برا الشاشة، فلازم نلفها بنفس الثيم والاتجاه)
  ThemeData _cairoTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(textTheme: base.textTheme.apply(fontFamily: _font));
  }

  Widget _sheetShell(Widget child) {
    return Theme(
      data: _cairoTheme(context),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }

  void _continue() {
    final draft = BookingDraft(
      provider: _args.provider,
      service: _args.service,
      categoryTitle: _args.categoryTitle,
      date: _selectedDay!,
      time: _selectedTime!,
      address: _address,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.pushNamed(context, 'BookingConfirmation', arguments: draft);
  }

  // ───────────────────────── اختيار / إضافة عنوان ─────────────────────────
  Future<void> _pickAddress() async {
    // العناوين المحفوظة للمريض
    final addresses = PatientRepository.current.value.addresses;
    final canAdd = addresses.length < PatientRepository.maxAddresses;

    final picked = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _sheetShell(
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('اختر عنوان الزيارة'),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: addresses.map((a) {
                      final selected = a.id == _address.id;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: AppColors.primary600,
                        ),
                        title: Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutralDarkActive,
                          ),
                        ),
                        subtitle: Text(
                          a.details,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        onTap: () => Navigator.pop(ctx, a),
                      );
                    }).toList(),
                  ),
                ),
                if (canAdd) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _addAddress();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary700,
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                    label: const Text(
                      'إضافة عنوان جديد',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _address = picked);
  }

  /// يفتح صفحة "إضافة عنوان"، وبعد الحفظ يختار العنوان الجديد
  Future<void> _addAddress() async {
    final before = PatientRepository.current.value.addresses.length;
    await Navigator.pushNamed(context, 'AddAddress');
    if (!mounted) return;

    final list = PatientRepository.current.value.addresses;
    if (list.length > before) setState(() => _address = list.last);
  }

  // ───────────────────────── عناصر مشتركة ─────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.neutralDarkActive,
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _border),
  );

  // ───────────────────────── بطاقة الخدمة ─────────────────────────
  Widget _providerPhoto(CareProvider p) {
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
          p.image,
          fit: BoxFit.cover,
          cacheWidth: 100,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary50,
            alignment: Alignment.center,
            child: Text(
              _initial(p.name),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// عنصر معلومة صغير (أيقونة + نص) مثل المدة والسعر
  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary800,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    final service = _args.service;
    final provider = _args.provider;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 24,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _args.categoryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        _metaItem(Icons.schedule_rounded, service.duration),
                        _metaItem(Icons.payments_outlined, service.price),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _border),
          const SizedBox(height: 16),
          Row(
            children: [
              _providerPhoto(provider),
              const SizedBox(width: 8),
              const Text(
                'مقدم الرعاية:',
                style: TextStyle(fontSize: 12, color: AppColors.neutralDark),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  provider.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDarkActive,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── اختيار اليوم ─────────────────────────
  Widget _dayCard(DateTime d) {
    final enabled = _hasFree(d);
    final selected = _selectedDay == d;

    final nameColor = selected
        ? AppColors.white
        : enabled
        ? AppColors.neutralDark
        : _disabledText;
    final numColor = selected
        ? AppColors.white
        : enabled
        ? AppColors.neutralDarkActive
        : _disabledText;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled
          ? () => setState(() {
              _selectedDay = d;
              _selectedTime = null; // أوقات كل يوم مختلفة
            })
          : null,
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary600
              : enabled
              ? AppColors.white
              : _disabledBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary600 : _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dayNames[d.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: nameColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: numColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daySection() {
    final shown = _selectedDay ?? _days.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('اختر اليوم')),
            Text(
              '${_monthNames[shown.month - 1]} ${shown.year}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primary700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _dayCard(_days[i]),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── اختيار الوقت ─────────────────────────
  Widget _timeChip(TimeSlot s) {
    final selected = _selectedTime == s.time;
    final booked = s.isBooked;

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: booked ? null : () => setState(() => _selectedTime = s.time),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary600
              : booked
              ? _disabledBg
              : AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: selected ? AppColors.primary600 : _border),
        ),
        // widthFactor: 1 => العرض على قد النص (مش بياخد عرض السطر كله)
        child: Center(
          widthFactor: 1,
          child: Text(
            _fmtTime(s.time),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.white
                  : booked
                  ? _disabledText
                  : AppColors.neutralDarkActive,
              decoration: booked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }

  /// مربع صغير + نص لتوضيح حالات الأوقات
  Widget _legendItem({
    required Color fill,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.neutralDark),
        ),
      ],
    );
  }

  Widget _timeLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(
          fill: AppColors.white,
          borderColor: _border,
          label: 'متاح',
        ),
        _legendItem(
          fill: AppColors.primary600,
          borderColor: AppColors.primary600,
          label: 'محدد',
        ),
        _legendItem(fill: _disabledBg, borderColor: _border, label: 'محجوز'),
      ],
    );
  }

  Widget _timeSection() {
    final slots = _selectedDay == null
        ? const <TimeSlot>[]
        : (_slots[_selectedDay] ?? const <TimeSlot>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('اختر الوقت'),
        const SizedBox(height: 8),
        if (slots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration,
            child: const Text(
              'لا توجد أوقات متاحة لمقدم الرعاية حالياً.',
              style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
            ),
          )
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map(_timeChip).toList(),
          ),
          const SizedBox(height: 16),
          _timeLegend(),
        ],
      ],
    );
  }

  // ───────────────────────── العنوان ─────────────────────────
  Widget _addressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('عنوان الزيارة'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: _cardDecoration,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _address.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      _address.details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _pickAddress,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary700,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'تغيير',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────── الملاحظات ─────────────────────────
  Widget _notesSection() {
    OutlineInputBorder border() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'ملاحظات ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDarkActive,
            ),
            children: const [
              TextSpan(
                text: '(اختياري)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.neutralDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          maxLength: 200,
          style: const TextStyle(fontSize: 13, color: AppColors.neutralDark),
          decoration: InputDecoration(
            hintText: 'أضف أي ملاحظات لمقدم الرعاية...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.neutralDark,
            ),
            counterStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.neutralDark,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(16),
            border: border(),
            enabledBorder: border(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary500),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── الشريط السفلي ─────────────────────────
  Widget _bottomBar() {
    final canContinue = _selectedDay != null && _selectedTime != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'الدفع نقداً عند الزيارة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                  Text(
                    _args.service.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralDarkActive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppButton(
                text: 'متابعة',
                onPressed: canContinue ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      // خط Cairo (احذفي هذا الغلاف إذا الخط عام في main.dart)
      data: _cairoTheme(context),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            toolbarHeight: 90,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: AppColors.neutralDarkActive,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'حجز الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _summaryCard(),
              const SizedBox(height: 16),
              _daySection(),
              const SizedBox(height: 16),
              _timeSection(),
              const SizedBox(height: 16),
              _addressSection(),
              const SizedBox(height: 16),
              _notesSection(),
            ],
          ),
          bottomNavigationBar: _bottomBar(),
        ),
      ),
    );
  }
}