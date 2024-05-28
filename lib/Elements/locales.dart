
import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES=[
  MapLocale('en', LocaleData.EN), //English
  MapLocale('hi', LocaleData.HI), // Hindi
  MapLocale('ta', LocaleData.TA), // Tamil
  MapLocale('te', LocaleData.TE), // Telugu
  MapLocale('pa', LocaleData.PA), // Punjabi
  MapLocale('ne', LocaleData.NE), // Punjabi
];

mixin LocaleData {

  static const String title = 'title';
  static const String generalSettings = 'generalSettings';
  static const String language = 'language';
  static const String pushNotification = 'pushNotification';
  static const String appInformation = 'appInformation';
  static const String updateAvailable = 'updateAvailable';
  static const String accessibilitySettings = 'accessibilitySettings';
  static const String highContrastMode = 'highContrastMode';
  static const String personWithDisability = 'personWithDisability';
  static const String navigationSettings = 'navigationSettings';
  static const String navigationMode = 'navigationMode';
  static const String orientationSetting = 'orientationSetting';
  static const String pathDetails = 'pathDetails';
  static const String naturalDirection = 'naturalDirection';
  static const String clockDirection = 'clockDirection';
  static const String focusMode = 'focusMode';
  static const String exploreMode = 'exploreMode';
  static const String distanceInMeters = 'distanceInMeters';
  static const String estimatedSteps = 'estimatedSteps';
  static const String blind = 'Blind';
  static const String lowVision = 'Low Vision';
  static const String wheelchair = 'Wheelchair';
  static const String regular = 'Regular';
  static const String userHeight = 'userHeight';
  static const String less5Feet = '< 5 Feet';
  static const String between56Feet = '5 to 6 Feet';
  static const String more6Feet = '> 6 Feet';

  static const Map<String, dynamic> EN = {
    'title': 'Settings',
    'generalSettings': 'General Settings',
    'language': 'Language',
    'pushNotification': 'Push Notification',
    'appInformation': 'App Information',
    'updateAvailable': 'Update Available',
    'accessibilitySettings': 'Accessibility Settings',
    'highContrastMode': 'High Contrast Mode',
    'personWithDisability': 'Person with Disability',
    'navigationSettings': 'Navigation Settings',
    'navigationMode': 'Navigation Mode',
    'orientationSetting': 'Orientation Setting',
    'pathDetails': 'Path Details',
    'naturalDirection': 'Natural Direction',
    'clockDirection': 'Clock Direction',
    'focusMode': 'Focus Mode',
    'exploreMode': 'Explore Mode',
    'distanceInMeters': 'Distance in meters',
    'estimatedSteps': 'Estimated steps',
    'blind': 'Blind',
    'lowVision': 'Low Vision',
    'wheelchair': 'Wheelchair',
    'regular': 'Regular',
    'userHeight': 'User Height',
    '< 5 Feet':'< 5 Feet',
    '5 to 6 Feet':'5 to 6 Feet',
    '> 6 Feet':'> 6 Feet',
  };

  static const Map<String, dynamic> HI = {
    'title': 'सेटिंग्स',
    'generalSettings': 'सामान्य सेटिंग्स',
    'language': 'भाषा',
    'pushNotification': 'पुश सूचना',
    'appInformation': 'ऐप सूचना',
    'updateAvailable': 'अपडेट उपलब्ध है',
    'accessibilitySettings': 'पहुँचनीयता सेटिंग्स',
    'highContrastMode': 'उच्च अंतर के मोड',
    'personWithDisability': 'विकलांग व्यक्ति',
    'navigationSettings': 'नेविगेशन सेटिंग्स',
    'navigationMode': 'नेविगेशन मोड',
    'orientationSetting': 'अभिविन्यास सेटिंग',
    'pathDetails': 'मार्ग विवरण',
    'naturalDirection': 'प्राकृतिक दिशा',
    'clockDirection': 'घड़ी की दिशा',
    'focusMode': 'फोकस मोड',
    'exploreMode': 'अन्वेषण मोड',
    'distanceInMeters': 'मीटर में दूरी',
    'estimatedSteps': 'अनुमानित कदम',
    'blind': 'अंधा',
    'lowVision': 'कम दृष्टि',
    'wheelchair': 'व्हीलचेयर',
    'regular': 'नियमित',
    'userHeight': 'उपयोगकर्ता की ऊंचाई',
    '< 5 Feet': '< 5 फीट',
    '5 to 6 Feet': '5 से 6 फीट',
    '> 6 Feet': '> 6 फीट'
  };

  static const Map<String, dynamic> TA = {
    'title': 'அமைப்புகள்',
    'generalSettings': 'பொது அமைப்புகள்',
    'language': 'மொழி',
    'pushNotification': 'தடவை அறிவிப்பு',
    'appInformation': 'பயன்பாடு தகவல்',
    'updateAvailable': 'புதுப்பிக்கம் கிடைக்கும்',
    'accessibilitySettings': 'அணுகுமுறை அமைப்புகள்',
    'highContrastMode': 'உயர் மேற்கோள் முறை',
    'personWithDisability': 'இருந்து மனிதர்',
    'navigationSettings': 'வழிசெலுத்து அமைப்புகள்',
    'navigationMode': 'வழிசெலுத்து முறை',
    'orientationSetting': 'அமைப்பு அமைப்பு',
    'pathDetails': 'பாதை விவரங்கள்',
    'naturalDirection': 'இயல்புநிலை வழி',
    'clockDirection': 'கடிகார இடைவேளை',
    'focusMode': 'கோல்கள் முறை',
    'exploreMode': 'ஆராய்வு முறை',
    'distanceInMeters': 'மீட்டரில் தூரம்',
    'estimatedSteps': 'மதிப்பிட்ட படிகள்',
    'blind': 'குருட்டு',
    'lowVision': 'குறைந்த கண்ணோட்டம்',
    'wheelchair': 'சுட்டி நாற்பந்து',
    'regular': 'நியமான',
    'userHeight': 'பயனர் உயரம்',
    '< 5 Feet': '< 5 அடி',
    '5 to 6 Feet': '5 முதல் 6 அடி',
    '> 6 Feet': '> 6 அடி',
  };

  static const Map<String, dynamic> TE = {
    'title': 'అమరికలు',
    'generalSettings': 'సాధారణ అమరికలు',
    'language': 'భాష',
    'pushNotification': 'పుష్ నోటిఫికేషన్',
    'appInformation': 'అప్లికేషన్ సమాచారం',
    'updateAvailable': 'అందుబాటులో నవీకరణ',
    'accessibilitySettings': 'అభ్యాసకంపను అమరికలు',
    'highContrastMode': 'అధిక సరళం మోడ్',
    'personWithDisability': 'అంగనులకు వ్యక్తి',
    'navigationSettings': 'నావిగేషన్ అమరికలు',
    'navigationMode': 'నావిగేషన్ మోడ్',
    'orientationSetting': 'సమాన్య అమరికలు',
    'pathDetails': 'మార్గం వివరాలు',
    'naturalDirection': 'ప్రాకృత దిగ్భాంతం',
    'clockDirection': 'గడియారం దిశ',
    'focusMode': 'ఫోకస్ మోడ్',
    'exploreMode': 'అన్వేషణ మోడ్',
    'distanceInMeters': 'మీటర్లునాటి దూరం',
    'estimatedSteps': 'అంచనా పటకాలు',
    'blind': 'కాగాబడి',
    'lowVision': 'కనుక వెనుక',
    'wheelchair': 'వీల్‌చేర్‌',
    'regular': 'నియమిత',
    'userHeight': 'వాడుకరి ఎత్తు',
    '< 5 Feet': '< 5 అడుగులు',
    '5 to 6 Feet': '5 నుండి 6 అడుగులు',
    '> 6 Feet': '> 6 అడుగులు'
  };

  static const Map<String, dynamic> PA = {
    'title': 'ਸੈਟਿੰਗਾਂ',
    'generalSettings': 'ਆਮ ਸੈਟਿੰਗਾਂ',
    'language': 'ਭਾਸ਼ਾ',
    'pushNotification': 'ਪੁਸ਼ ਸੂਚਨਾ',
    'appInformation': 'ਐਪ ਜਾਣਕਾਰੀ',
    'updateAvailable': 'ਅਪਡੇਟ ਉਪਲੱਬਧ ਹੈ',
    'accessibilitySettings': 'ਪਹੁੰਚਯੋਗਤਾ ਸੈਟਿੰਗਾਂ',
    'highContrastMode': 'ਉੱਚਾ ਤਫ਼ਾਵਤ ਮੋਡ',
    'personWithDisability': 'ਅਸਮਰਥ ਵਿਅਕਤੀ',
    'navigationSettings': 'ਨੇਵੀਗੇਸ਼ਨ ਸੈਟਿੰਗਾਂ',
    'navigationMode': 'ਨੇਵੀਗੇਸ਼ਨ ਮੋਡ',
    'orientationSetting': 'ਅਭਿਸਥਾਨ ਸੈਟਿੰਗ',
    'pathDetails': 'ਮਾਰਗ ਵੇਰਵਾ',
    'naturalDirection': 'ਪ੍ਰਾਕ੃ਤਿਕ ਦਿਸ਼ਾ',
    'clockDirection': 'ਘੜੀ ਦਿਸ਼ਾ',
    'focusMode': 'ਫੋਕਸ ਮੋਡ',
    'exploreMode': 'ਅਨਿਵੇਸ਼ਣ ਮੋਡ',
    'distanceInMeters': 'ਮੀਟਰ ਵਿੱਚ ਦੂਰੀ',
    'estimatedSteps': 'ਅਨੁਮਾਨਤ ਕਦਮ',
    'blind': 'ਅੰਧਾ',
    'lowVision': 'ਘੱਟੀ ਦਿਮਾਗ',
    'wheelchair': 'ਵੀਲਚੇਅਰ',
    'regular': 'ਨਿਯਮਿਤ',
    'userHeight': 'ਉਪਭੋਗਤਾ ਦੀ ਉਚਾਈ',
    '< 5 Feet': '< 5 ਫੁੱਟ',
    '5 to 6 Feet': '5 ਤੋਂ 6 ਫੁੱਟ',
    '> 6 Feet': '> 6 ਫੁੱਟ',
  };
  static const Map<String, dynamic> NE = {
    'title': 'सेटिङहरू',
    'generalSettings': 'सामान्य सेटिङहरू',
    'language': 'भाषा',
    'pushNotification': 'पुष सूचना',
    'appInformation': 'अनुप्रयोग जानकारी',
    'updateAvailable': 'अद्यावधिक उपलब्ध',
    'accessibilitySettings': 'पहुँचयोग्यता सेटिङहरू',
    'highContrastMode': 'उच्च अन्तर विधि',
    'personWithDisability': 'अपाङ्ग व्यक्ति',
    'navigationSettings': 'नेभिगेसन सेटिङहरू',
    'navigationMode': 'नेभिगेसन मोड',
    'orientationSetting': 'ओरियन्टेसन सेटिङ',
    'pathDetails': 'पथ विवरणहरू',
    'naturalDirection': 'प्राकृतिक दिशा',
    'clockDirection': 'घडी दिशा',
    'focusMode': 'फोकस मोड',
    'exploreMode': 'अन्वेषण मोड',
    'distanceInMeters': 'मिटरमा दूरी',
    'estimatedSteps': 'अनुमानित कदम',
    'blind': 'अन्धो',
    'lowVision': 'कम दृष्टि',
    'wheelchair': 'ह्वीलचेयर',
    'regular': 'नियमित',
    'userHeight': 'प्रयोगकर्ता उचाइ',
    '< 5 Feet': '< ५ फिट',
    '5 to 6 Feet': '५ देखि ६ फिट',
    '> 6 Feet': '> ६ फिट'
  };

}