// lib/core/screens/visit_report_view_screen.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/core/models/visit_report.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// بيانات صفحة التقرير، مستقلة عن مستودع المريض أو مقدم الرعاية
class ReportViewArgs {
  final String title; // المريض: "تفاصيل الزيارة"، مقدم الرعاية: "تقرير الزيارة"
  final VisitReport? report; // null = لم يُرفق تقرير لهذه الزيارة
  final String providerName;
  final String providerRole;
  final String? providerImage;
  final String service;
  final String date;
  final String time;

  // أقسام إضافية عند المريض، تظهر فقط إذا موجودة
  final String? address;
  final double? rating;
  final String? comment;

  const ReportViewArgs({
    this.title = 'تقرير الزيارة',
    required this.report,
    required this.providerName,
    required this.providerRole,
    this.providerImage,
    required this.service,
    required this.date,
    required this.time,
    this.address,
    this.rating,
    this.comment,
  });
}

/// تقرير الزيارة للقراءة فقط، مشترك بين المريض ومقدم الرعاية
class VisitReportViewScreen extends StatelessWidget {
  final ReportViewArgs? args;

  /// تُمرَّر args مباشرة، أو تُقرأ من arguments المسار "VisitReportView"
  const VisitReportViewScreen({super.key, this.args});

  static const Color _border = AppColors.border;

  // ───────────────────────── مكونات ─────────────────────────
  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _text(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          height: 1.8,
          color: AppColors.neutralDarkActive,
        ),
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.neutralDark),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(ReportViewArgs a) {
    final n = a.providerName.trim();
    final fallback = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      color: AppColors.primary50,
      child: Text(
        n.isEmpty ? '?' : n[0],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary800,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: a.providerImage == null
            ? fallback
            : Image.asset(
                a.providerImage!,
                fit: BoxFit.cover,
                cacheWidth: 144,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }

  /// من كتب التقرير + الخدمة والموعد
  Widget _visitCard(ReportViewArgs a) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(a),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Text(
                      a.providerRole,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'مكتمل',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  a.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${a.date} · ${a.time}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noReport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 32,
            color: AppColors.primary300,
          ),
          SizedBox(height: 8),
          Text(
            'لم يُرفق تقرير لهذه الزيارة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.neutralDark),
          ),
        ],
      ),
    );
  }

  /// تقييم المريض: نجوم + الرقم + التعليق إن وُجد
  Widget _ratingCard(double rating, String? comment) {
    final c = comment?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: i < rating.round() ? AppColors.star : _border,
                ),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDarkActive,
                ),
              ),
            ],
          ),
          if (c.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              c,
              style: const TextStyle(
                fontSize: 13,
                height: 1.8,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _extraSections(ReportViewArgs a) {
    final address = a.address?.trim() ?? '';
    return [
      if (address.isNotEmpty) ...[
        const SizedBox(height: 24),
        _title('العنوان'),
        _text(address),
      ],
      if (a.rating != null) ...[
        const SizedBox(height: 24),
        _title('تقييمك'),
        _ratingCard(a.rating!, a.comment),
      ],
    ];
  }

  List<Widget> _reportSections(BuildContext context, VisitReport r) {
    final vitals = <Widget>[
      if (r.bloodPressure.isNotEmpty) _mini('ضغط الدم', r.bloodPressure),
      if (r.sugar.isNotEmpty) _mini('السكر', '${r.sugar} mg/dL'),
      if (r.temperature.isNotEmpty) _mini('الحرارة', '${r.temperature} °م'),
      if (r.pulse.isNotEmpty) _mini('النبض', '${r.pulse} نبضة/د'),
    ];

    return [
      _title('ملخص الزيارة'),
      _text(r.summary),
      if (r.procedures.isNotEmpty) ...[
        const SizedBox(height: 24),
        _title('الإجراءات المنفذة'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in r.procedures)
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  p,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary800,
                  ),
                ),
              ),
          ],
        ),
      ],
      if (vitals.isNotEmpty) ...[
        const SizedBox(height: 24),
        _title('القياسات الحيوية'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in vitals)
              SizedBox(
                width: (MediaQuery.sizeOf(context).width - 32 - 8) / 2,
                child: v,
              ),
          ],
        ),
      ],
      if (r.recommendations.isNotEmpty) ...[
        const SizedBox(height: 24),
        _title('توصيات وملاحظات'),
        _text(r.recommendations),
      ],
    ];
  }

  // ───────────────────────── البناء ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final a =
        args ?? ModalRoute.of(context)?.settings.arguments as ReportViewArgs?;

    if (a == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد تقرير')));
    }

    final r = a.report;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.neutralDarkActive,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        a.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _visitCard(a),
                    const SizedBox(height: 24),
                    if (r == null) _noReport() else ..._reportSections(context, r),
                    ..._extraSections(a),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
