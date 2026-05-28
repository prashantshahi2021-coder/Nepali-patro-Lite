import 'dart:convert';
import 'dart:io';

import 'package:nepali_patro_lite/models/patro_date.dart';
import 'package:nepali_patro_lite/services/nepali_date_service.dart';

const sourceName = 'Government of Nepal, Ministry of Home Affairs';
const sourceUrl =
    'https://moha.gov.np/assets/2/%E0%A5%A8%E0%A5%A6%E0%A5%AE%E0%A5%A9_%E0%A4%B8%E0%A4%BE%E0%A4%B2%E0%A4%95%E0%A5%8B_%E0%A4%B8%E0%A4%BE%E0%A4%B0%E0%A5%8D%E0%A4%B5%E0%A4%9C%E0%A4%A8%E0%A4%BF%E0%A4%95_%E0%A4%B5%E0%A4%BF%E0%A4%A6%E0%A4%BE_%2867_11_18%29.pdf/file';

void main() {
  final dateService = NepaliDateService();
  final holidays = <Map<String, dynamic>>[];

  void add({
    required String id,
    required int month,
    required int day,
    required String titleEn,
    required String titleNe,
    required String type,
    required String appliesTo,
  }) {
    final adDate = dateService.toAd(2083, month, day);
    holidays.add({
      'id': id,
      'bs_date':
          '2083-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      'ad_date': dateKey(adDate),
      'title_en': titleEn,
      'title_ne': titleNe,
      'type': type,
      'applies_to': appliesTo,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'verified': true,
    });
  }

  add(
    id: 'new_year_2083',
    month: 1,
    day: 1,
    titleEn: 'New Year',
    titleNe: 'नयाँ वर्ष',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'chandi_purnima_buddha_jayanti_ubhauli_2083',
    month: 1,
    day: 18,
    titleEn: 'Chandi Purnima / Buddha Jayanti / Ubhauli festival',
    titleNe: 'चण्डी पूर्णिमा / बुद्ध जयन्ती / उभौली पर्व',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'workers_day_2083',
    month: 1,
    day: 18,
    titleEn: 'International Workers Day',
    titleNe: 'विश्व मजदुर दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'republic_day_2083',
    month: 2,
    day: 15,
    titleEn: 'Republic Day',
    titleNe: 'गणतन्त्र दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'constitution_day_2083',
    month: 6,
    day: 3,
    titleEn: 'Constitution Day (National Day)',
    titleNe: 'संविधान दिवस (राष्ट्रिय दिवस)',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'raksha_bandhan_2083',
    month: 5,
    day: 12,
    titleEn: 'Raksha Bandhan',
    titleNe: 'रक्षाबन्धन',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'krishna_janmashtami_2083',
    month: 5,
    day: 19,
    titleEn: 'Shree Krishna Janmashtami',
    titleNe: 'श्रीकृष्ण जन्माष्टमी',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'ghatasthapana_2083',
    month: 6,
    day: 25,
    titleEn: 'Ghatasthapana',
    titleNe: 'घटस्थापना',
    type: 'national',
    appliesTo: 'Nationwide',
  );

  for (final date in [
    (6, 31),
    (7, 1),
    (7, 2),
    (7, 3),
    (7, 4),
    (7, 5),
    (7, 6),
  ]) {
    add(
      id: 'dashain_holiday_2083_${date.$1}_${date.$2}',
      month: date.$1,
      day: date.$2,
      titleEn: 'Dashain holiday',
      titleNe: 'दशैं बिदा',
      type: 'national',
      appliesTo: 'Nationwide',
    );
  }

  for (final day in [22, 23, 24, 25, 26]) {
    add(
      id: 'tihar_holiday_2083_$day',
      month: 7,
      day: day,
      titleEn: 'Tihar holiday',
      titleNe: 'तिहार बिदा',
      type: 'national',
      appliesTo: 'Nationwide',
    );
  }

  add(
    id: 'chhath_2083',
    month: 7,
    day: 29,
    titleEn: 'Chhath festival',
    titleNe: 'छठ पर्व',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'dhanya_purnima_udhauli_yomari_jyapu_2083',
    month: 9,
    day: 1,
    titleEn: 'Dhanya Purnima / Udhauli festival / Yomari Punhi / Jyapu Day',
    titleNe: 'धान्य पूर्णिमा / उधौली पर्व / योमरी पुन्हि / ज्यापू दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'christmas_day_2083',
    month: 9,
    day: 10,
    titleEn: 'Christmas Day',
    titleNe: 'क्रिसमस डे',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'tamu_lhosar_2083',
    month: 9,
    day: 15,
    titleEn: 'Tamu Lhosar',
    titleNe: 'तमू ल्होसार',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'maghi_makar_sankranti_2083',
    month: 10,
    day: 1,
    titleEn: 'Maghi festival / Maghe Sankranti',
    titleNe: 'माघी पर्व / माघे संक्रान्ति',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'martyrs_day_2083',
    month: 10,
    day: 16,
    titleEn: 'Martyrs Day',
    titleNe: 'सहिद दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'sonam_lhosar_2083',
    month: 10,
    day: 24,
    titleEn: 'Sonam Lhosar',
    titleNe: 'सोनम ल्होसार',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'democracy_day_2083',
    month: 11,
    day: 7,
    titleEn: 'National Democracy Day',
    titleNe: 'राष्ट्रिय प्रजातन्त्र दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'mahashivaratri_2083',
    month: 11,
    day: 22,
    titleEn: 'Maha Shivaratri',
    titleNe: 'महाशिवरात्री',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'international_womens_day_2083',
    month: 11,
    day: 24,
    titleEn: 'International Women’s Day',
    titleNe: 'अन्तर्राष्ट्रिय महिला दिवस',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'gyalpo_lhosar_2083',
    month: 11,
    day: 25,
    titleEn: 'Gyalpo Lhosar',
    titleNe: 'ग्याल्पो ल्होसार',
    type: 'national',
    appliesTo: 'Nationwide',
  );
  add(
    id: 'prithvi_jayanti_2083',
    month: 9,
    day: 27,
    titleEn: 'Prithvi Jayanti (National Unity Day)',
    titleNe: 'पृथ्वी जयन्ती (राष्ट्रिय एकता दिवस)',
    type: 'national',
    appliesTo: 'Nationwide',
  );

  add(
    id: 'fagu_purnima_hill_2083',
    month: 12,
    day: 7,
    titleEn: 'Fagu Purnima',
    titleNe: 'फागुपूर्णिमा',
    type: 'community',
    appliesTo: 'Himalayan and hilly 56 districts listed by MoHA',
  );
  add(
    id: 'fagu_purnima_tarai_2083',
    month: 12,
    day: 8,
    titleEn: 'Fagu Purnima',
    titleNe: 'फागुपूर्णिमा',
    type: 'community',
    appliesTo: 'Tarai districts listed by MoHA',
  );
  add(
    id: 'gaijatra_newar_community_2083',
    month: 5,
    day: 13,
    titleEn: 'Gaijatra',
    titleNe: 'गाईजात्रा',
    type: 'community',
    appliesTo: 'Newar community nationwide',
  );
  add(
    id: 'gaura_parva_2083',
    month: 5,
    day: 19,
    titleEn: 'Gaura Parva',
    titleNe: 'गौरा पर्व',
    type: 'community',
    appliesTo: 'Communities and areas observing Gaura Parva',
  );
  add(
    id: 'dura_rhewra_nakuma_2083',
    month: 9,
    day: 15,
    titleEn: 'Dura Rhewra Nakuma',
    titleNe: 'दुरा र्‍ह्येउ नाकुमा',
    type: 'community',
    appliesTo: 'Dura community nationwide',
  );
  add(
    id: 'teej_women_employees_2083',
    month: 5,
    day: 29,
    titleEn: 'Haritalika Teej fast',
    titleNe: 'हरितालिका (तीज) व्रत',
    type: 'gender',
    appliesTo: 'Women employees only',
  );
  add(
    id: 'jitiya_women_employees_2083',
    month: 6,
    day: 18,
    titleEn: 'Jitiya festival',
    titleNe: 'जितिया पर्व',
    type: 'gender',
    appliesTo: 'Women employees observing Jitiya only',
  );
  add(
    id: 'basanta_panchami_education_2083',
    month: 10,
    day: 28,
    titleEn: 'Basanta Panchami',
    titleNe: 'वसन्त पञ्चमी',
    type: 'office',
    appliesTo: 'Educational institutions only',
  );
  add(
    id: 'international_disability_day_employees_2083',
    month: 8,
    day: 17,
    titleEn: 'International Day of Persons with Disabilities',
    titleNe: 'अन्तर्राष्ट्रिय अपाङ्गता दिवस',
    type: 'office',
    appliesTo: 'Employees with disabilities only',
  );
  add(
    id: 'falgunanda_jayanti_2083',
    month: 7,
    day: 25,
    titleEn: 'Falgunanda Jayanti',
    titleNe: 'फाल्गुनन्द जयन्ती',
    type: 'community',
    appliesTo: 'Kirat religious community',
  );

  add(
    id: 'gaijatra_kathmandu_valley_2083',
    month: 5,
    day: 13,
    titleEn: 'Gaijatra',
    titleNe: 'गाईजात्रा',
    type: 'province',
    appliesTo: 'Kathmandu Valley only',
  );
  add(
    id: 'indra_jatra_2083',
    month: 6,
    day: 9,
    titleEn: 'Indra Jatra',
    titleNe: 'इन्द्रजात्रा',
    type: 'province',
    appliesTo: 'Kathmandu Valley only',
  );
  add(
    id: 'ghode_jatra_2083',
    month: 12,
    day: 23,
    titleEn: 'Ghode Jatra',
    titleNe: 'घोडेजात्रा',
    type: 'province',
    appliesTo: 'Kathmandu Valley only',
  );

  final file = File('assets/data/holidays/2083_holidays.json');
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert(holidays)}\n');
  stdout.writeln('Wrote ${holidays.length} holidays to ${file.path}');
}
