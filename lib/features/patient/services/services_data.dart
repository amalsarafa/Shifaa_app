import 'service_models.dart';

const nursingServices = [
  ServiceItem(
    title: 'الحقن',
    description: 'حقن آمنة ومعقمة.',
    duration: '15-30 د',
    price: '\$25',
    image: 'assets/images/patient/injections.png',
    rating: 4.8,
    reviewsCount: 100,
    availability: 'يومياً',
    longDescription:
        'حقن آمنة ومعقمة تُعطى في المنزل من قبل ممرضين مرخصين: '
        'حقن عضلية ووريدية وإنسولين ولقاحات، مع تعليمات واضحة بعد الزيارة.',
    providers: [
      CareProvider(
        name: 'سارة خليل',
        role: 'ممرضة مسجلة',
        rating: 4.9,
        yearsExp: 6,
        image: 'assets/images/patient/nurse_sarah.png',
      ),
      CareProvider(
        name: 'علي أحمد',
        role: 'ممرض مسجل',
        rating: 4.9,
        yearsExp: 5,
        image: 'assets/images/patient/nurse_ali.png',
        reviewsCount: 120,
        visitsDone: 150,
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
        ],
      ),
      CareProvider(
        name: 'لينا صالح',
        role: 'ممرضة مسجلة',
        rating: 4.8,
        yearsExp: 3,
        image: 'assets/images/patient/nurse_lina.png',
      ),
    ],
  ),
  ServiceItem(
    title: 'العناية بالجروح',
    description: 'تغيير الضمادات وعلاج الحروق.',
    duration: '30-45 د',
    price: '\$40',
    image: 'assets/images/patient/wound_care.png',
    rating: 4.7,
    reviewsCount: 64,
    availability: 'يومياً',
    longDescription:
        'تنظيف الجروح وتغيير الضمادات ومتابعة التئام الحروق '
        'والجروح الجراحية في المنزل، مع إرشادات للعناية بعد الزيارة.',
    providers: [
      CareProvider(
        name: 'سارة خليل',
        role: 'ممرضة مسجلة',
        rating: 4.9,
        yearsExp: 6,
        image: 'assets/images/patient/sarah.png',
      ),
    ],
  ),
  ServiceItem(
    title: 'رعاية كبار السن',
    description: 'رعاية يومية ومرافقة.',
    duration: '30-45 د',
    price: '\$40',
    image: 'assets/images/patient/elderly_care.png',
    rating: 4.9,
    reviewsCount: 82,
    availability: 'يومياً',
    longDescription:
        'رعاية يومية ومرافقة لكبار السن تشمل المساعدة في الأدوية '
        'والنظافة الشخصية ومتابعة المؤشرات الحيوية.',
    providers: [
      CareProvider(
        name: 'لينا صالح',
        role: 'ممرضة مسجلة',
        rating: 4.8,
        yearsExp: 3,
        image: 'assets/images/patient/lina.png',
      ),
    ],
  ),
];

// باقي الأقسام فاضية لحد ما تضيفي خدماتها
const physioServices = <ServiceItem>[];
const labServices = <ServiceItem>[];
const doctorServices = <ServiceItem>[];
