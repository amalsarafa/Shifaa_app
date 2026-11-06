import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_first_app/core/theme/app_colors.dart';


class _NotificationItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  bool unread; 

  _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.unread = false,
  });
}

class _NotificationSection {
  final String label;
  final List<_NotificationItem> items;

  _NotificationSection({required this.label, required this.items});
}


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _emptyIcon = 'assets/icons/empty_notifications.svg';

  static const bool _showSample = true;//false اذا بدي اشوف الاشعارات الفارغة

  late final List<_NotificationSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _showSample ? _buildSample() : [];
  }

  List<_NotificationSection> _buildSample() {
    return [
      _NotificationSection(
        label: 'اليوم',
        items: [
          _NotificationItem(
            title: 'تم تأكيد الحجز',
            body:
                'وافق الممرض علي أحمد على طلبك لخدمة الرعاية التمريضية يوم السبت 10 أكتوبر الساعة 3:30 م.',
            time: 'الآن',
            icon: Icons.event_available_outlined,
            iconColor: const Color(0xFF2F9E99),
            iconBg: const Color(0xFFE6F4F3),
            unread: true,
          ),
          _NotificationItem(
            title: 'موعد قادم',
            body: 'زيارتك مع الممرض علي أحمد تبدأ خلال ساعة.',
            time: '9:10 ص',
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFFE8920C),
            iconBg: const Color(0xFFFFF1D6),
            unread: true,
          ),
        ],
      ),
      _NotificationSection(
        label: 'السبت، 26 سبتمبر',
        items: [
          _NotificationItem(
            title: 'تم رفض الحجز',
            body:
                'للأسف، لا يستطيع الممرض عمر قبول طلبك. تصفّح مقدمي الرعاية المتاحين الآخرين.',
            time: '4:15 م',
            icon: Icons.event_busy_outlined,
            iconColor: const Color(0xFFE8920C),
            iconBg: const Color(0xFFFFF1D6),
          ),
          _NotificationItem(
            title: 'مرحباً بك في شفاء',
            body: 'حسابك جاهز. احجز أول زيارة رعاية منزلية لك.',
            time: '6:30 ص',
            icon: Icons.info_outline,
            iconColor: const Color(0xFF3B6FD4),
            iconBg: const Color(0xFFE3EEFB),
          ),
        ],
      ),
    ];
  }


  int get _unreadCount => _sections.fold(
        0,
        (sum, s) => sum + s.items.where((i) => i.unread).length,
      );

  void _markAsRead(_NotificationItem item) {
    if (!item.unread) return;
    setState(() => item.unread = false);
    // TODO
  }

  void _markAllAsRead() {
    setState(() {
      for (final s in _sections) {
        for (final i in s.items) {
          i.unread = false;
        }
      }
    });
    // TODO
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(child: _sections.isEmpty ? _empty() : _list()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          const Text(
            'الإشعارات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (_unreadCount > 0)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'قراءة الكل',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              _emptyIcon,
              width: 200,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إشعارات بعد!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إشعارك فور وصول أي إشعارات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        for (final section in _sections) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              section.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDarkActive,
              ),
            ),
          ),
          for (final item in section.items)
            _NotificationCard(
              item: item,
              onTap: () => _markAsRead(item),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}


class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, size: 20, color: item.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              item.unread ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.neutralDarkActive,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.unread) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}