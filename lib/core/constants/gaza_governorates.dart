// lib/core/constants/gaza_governorates.dart

/// محافظة من محافظات قطاع غزة، نطابق بها المريض مع مقدم الرعاية
class GazaGovernorate {
  final String id;
  final String name;

  const GazaGovernorate(this.id, this.name);
}

/// محافظات قطاع غزة بالترتيب من الشمال للجنوب
/// 🔥 لاحقاً: تُقرأ من Firebase
const List<GazaGovernorate> gazaGovernorates = [
  GazaGovernorate('north_gaza', 'شمال غزة'),
  GazaGovernorate('gaza', 'غزة'),
  GazaGovernorate('deir_al_balah', 'دير البلح'),
  GazaGovernorate('khan_younis', 'خان يونس'),
  GazaGovernorate('rafah', 'رفح'),
];

/// اسم المحافظة من الـ id، أو "" إذا ما لقيناها
String governorateName(String id) {
  for (final g in gazaGovernorates) {
    if (g.id == id) return g.name;
  }
  return '';
}
