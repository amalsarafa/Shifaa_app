import 'service_models.dart';

// ───────────────────────── مقدمو الرعاية ─────────────────────────

const _sarah = CareProvider(
  name: 'سارة خليل',
  role: 'ممرضة مسجلة',
  rating: 4.9,
  yearsExp: 6,
  image: 'assets/images/patient/nurse_sarah.png',
  phone: '+970 59 000 0001',
  reviewsCount: 20,
  visitsDone: 40,
  about:
      'ممرضة مسجلة بخبرة ست سنوات في الرعاية المنزلية، متخصصة في '
      'الحقن والعناية بالجروح ومتابعة المرضى بعد العمليات.',
  reviews: [
    ProviderReview(
      name: 'منى يوسف',
      timeAgo: 'قبل 3 أيام',
      rating: 5.0,
      comment: 'ممرضة محترفة وهادئة، وكانت حريصة على التعقيم وشرحت لي كل خطوة.',
    ),
    ProviderReview(
      name: 'أحمد سالم',
      timeAgo: 'قبل أسبوعين',
      rating: 4.5,
      comment: 'وصلت بالموعد وكانت الزيارة سريعة ومريحة جداً.',
    ),
    ProviderReview(
      name: 'هديل عمر',
      timeAgo: 'قبل شهر',
      rating: 5.0,
      comment: 'تعاملت مع والدتي بلطف كبير، شكراً لها.',
    ),
  ],
);

const _ali = CareProvider(
  name: 'علي أحمد',
  role: 'ممرض مسجل',
  rating: 4.9,
  yearsExp: 5,
  image: 'assets/images/patient/nurse_ali.png',
  phone: '+970 59 000 0002',
  reviewsCount: 20,
  visitsDone: 30,
  about:
      'ممرض مسجل بخبرة تزيد عن خمس سنوات في الرعاية المنزلية، '
      'ويشمل ذلك الحقن والعناية بالجروح والرعاية بعد العمليات.',
  reviews: [
    ProviderReview(
      name: 'رنا محمد',
      timeAgo: 'قبل يومين',
      rating: 5.0,
      comment: 'كان علي لطيفاً ومحترفاً جداً، وساعدني كثيراً بعد عمليتي.',
    ),
    ProviderReview(
      name: 'خالد أحمد',
      timeAgo: 'قبل أسبوع',
      rating: 5.0,
      comment: 'وصل بالوقت المحدد وشرح كل شيء بوضوح. أنصح به بشدة.',
    ),
    ProviderReview(
      name: 'سامر ناصر',
      timeAgo: 'قبل أسبوعين',
      rating: 4.5,
      comment: 'خدمة ممتازة، والتزم بكل تعليمات الطبيب.',
    ),
    ProviderReview(
      name: 'ليلى حسن',
      timeAgo: 'قبل 3 أسابيع',
      rating: 5.0,
      comment: 'ممرض خلوق وصبور، اعتنى بجرح والدي بشكل رائع.',
    ),
    ProviderReview(
      name: 'يزن كمال',
      timeAgo: 'قبل شهر',
      rating: 4.5,
      comment: 'تجربة جيدة جداً وسأطلبه مرة أخرى.',
    ),
  ],
);

const _lina = CareProvider(
  name: 'لينا صالح',
  role: 'ممرضة مسجلة',
  rating: 4.8,
  yearsExp: 3,
  image: 'assets/images/patient/nurse_lina.png',
  phone: '+970 59 000 0002',
  reviewsCount: 5,
  visitsDone: 10,
  about:
      'ممرضة مسجلة تقدّم رعاية منزلية لكبار السن وتتابع الأدوية '
      'والمؤشرات الحيوية بعناية واهتمام.',
  reviews: [
    ProviderReview(
      name: 'سعاد إبراهيم',
      timeAgo: 'قبل 4 أيام',
      rating: 5.0,
      comment: 'لطيفة جداً مع أبي، وكانت تتابع أدويته بدقة.',
    ),
    ProviderReview(
      name: 'محمود طارق',
      timeAgo: 'قبل أسبوعين',
      rating: 4.5,
      comment: 'ملتزمة بالمواعيد وتشرح كل شيء بهدوء.',
    ),
  ],
);

// ───────────────────────── الخدمات ─────────────────────────

const nursingServices = [
  ServiceItem(
    title: 'الحقن',
    description: 'حقن آمنة ومعقمة.',
    duration: '15-30 د',
    price: '\₪25',
    image: 'assets/images/patient/injections.png',
    rating: 4.8,
    reviewsCount: 100,
    availability: 'يومياً',
    longDescription:
        'حقن آمنة ومعقمة تُعطى في المنزل من قبل ممرضين مرخصين: '
        'حقن عضلية ووريدية وإنسولين ولقاحات، مع تعليمات واضحة بعد الزيارة.',
    providers: [_sarah, _ali, _lina],
  ),
  ServiceItem(
    title: 'العناية بالجروح',
    description: 'تغيير الضمادات وعلاج الحروق.',
    duration: '30-45 د',
    price: '\₪40',
    image: 'assets/images/patient/wound_care.png',
    rating: 4.7,
    reviewsCount: 64,
    availability: 'يومياً',
    longDescription:
        'تنظيف الجروح وتغيير الضمادات ومتابعة التئام الحروق '
        'والجروح الجراحية في المنزل، مع إرشادات للعناية بعد الزيارة.',
    providers: [_sarah, _ali],
  ),
  ServiceItem(
    title: 'رعاية كبار السن',
    description: 'رعاية يومية ومرافقة.',
    duration: '30-45 د',
    price: '\₪40',
    image: 'assets/images/patient/elderly_care.png',
    rating: 4.9,
    reviewsCount: 82,
    availability: 'يومياً',
    longDescription:
        'رعاية يومية ومرافقة لكبار السن تشمل المساعدة في الأدوية '
        'والنظافة الشخصية ومتابعة المؤشرات الحيوية.',
    providers: [_lina],
  ),
];

// باقي الأقسام فاضية لحد ما تضيفي خدماتها
const physioServices = <ServiceItem>[];
const labServices = <ServiceItem>[];
const doctorServices = <ServiceItem>[];