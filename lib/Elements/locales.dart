
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
  static const String iss = "iss";
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

  static const String straight='Straight';
  static const String right='Right';
  static const String tright='tRight';
  static const String tslightright= 'tSlightRight';
  static const String tslightleft= 'tSlightLeft';
  static const String tsharpright= 'tSharpRight';
  static const String tsharpleft= 'tSharpLeft';


  static const String ttsright='ttsRight';
  static const String ttsleft='ttsLeft';
  static const String ttsback='ttsBack';
  static const String ttsfront='ttsFront';
  static const String ttsslightright='ttsSlightRight';
  static const String ttsslightleft='ttsSlightLeft';
  static const String ttssharpright='ttsSharpRight';
  static const String ttssharpleft='ttsSharpLeft';
  static const String ttsuturn='ttsUTurn';



  static const String uturn='U Turn';
  static const String sharpleft='Sharp Left';
  static const String left='Left';
  static const String tleft='tLeft';
  static const String slightright='Slight Right';
  static const String slightleft='Slight Left';
  static const String sharpright='Sharp Right';

  static const String tsright='tsRight';
  static const String tsuturn='tsU Turn';
  static const String tssharpleft='tsSharp Left';
  static const String tsleft='tsLeft';

  static const String tsslightright='tsSlight Right';
  static const String tsslightleft='tsSlight Left';
  static const String tssharpright='tsSharp Right';

  static const String hright='hRight';
  static const String hleft='hLeft';
  static const String gostraight='Go Straight';
  static const String then='Then';
  static const String and='and';
  static const String turn='Turn';
  static const String steps='Steps';
  static const String willbeonyourfront='will be on your front';
  static const String onyourfront='on your Front';
  static const String onyourright= 'on your Right';
  static const String onyourleft= 'on your Left';
  static const String onyourback= 'on your Back';
  static const String willbe='will be';
  static const String yourcurrentloc="Your current location";
  static const String lift="Lift";
  static const String floor='Floor';
  static const String goto ='go to';
  static const String from ='from';
  static const String exit ='Exit';
  static const String start='Start';
  static const String min='min';
  static const String take='Take';
  static const String maps='Maps';
  static const String slight='slight';
  static const String onyourslightright='on your Slight Right';
  static const String onyoursharpright= 'on your Sharp Right';
  static const String onyoursharpleft= 'on your Sharp Left';
  static const String onyourslightleft='on your Slight Left';
  static const String front='Front';
  static const String back='Back';
  static const String loadingMaps='Loading maps';
  static const String searchingyourlocation='Searching your location...';
  static const String plswait='Please wait';
  static const String youareon= 'You are on';
  static const String isonyour='is on your';
  static const String near='near';
  static const String unabletofindyourlocation='Unable to find your location. Scan nearby QR to know your location';
  static const String youaregoingawayfromthepath= 'You are going away from the path. Click Reroute to Navigate from here.';
  static const String issss= 'is';
  static const String meteraway='meter away';
  static const String clickstarttonavigate= 'Click Start to Navigate';
  static const String exploremodenabled= 'Explore Mode Enabled';
  static const String direction='Get Direction';
  static const String turnfrm='Turn from';
  static const String approaching='Approaching';
  static const String location='Location';
  static const String none='None';
  static const String ttsgostraight='ttsGoStraight';
  static const String waytogo="Where you want to go?";
  static const String scanQr="Scan nearby QR to know your location";
  static const String reroute="You are going away from the path. Rerouting you to the destination";


  static Map<String, String> get properties => {
    'Slight Right': tsslightright,
    'Right': tsright,
    'Sharp Right': tssharpright,
    'U Turn': tsuturn,
    'Sharp Left': tssharpleft,
    'Left': tsleft,
    'Slight Left': tsslightleft,
    'on your Slight Right':onyourslightright,
    'on your Sharp Right':onyoursharpright,
    'on your Sharp Left':onyoursharpleft,
    'on your Slight Left':onyourslightleft,
    'on your Front':onyourfront,
    'on your Left':onyourleft,
    'on your Back':onyourleft,
    'on your Right':onyourright,
    'None':none



  };


  static String getProperty(String propertyName,context) {

    if(properties[propertyName]!=null){
      return properties[propertyName]!.getString(context);
    }
    return propertyName;

  }

  static Map<String, String> get properties2 => {
    'Right':hright,
    'Left':hleft,
  };


  static String getProperty2(String propertyName,context) {
    if(properties2[propertyName]!=null){
      return properties2[propertyName]!.getString(context);
    }
    return propertyName;
  }

  static Map<String, String> get properties3 => {
    'Right':right,
    'Left':left,
  };


  static String getProperty3(String propertyName,context) {
    if(properties3[propertyName]!=null){
      return properties3[propertyName]!.getString(context);
    }
    return propertyName;
  }
  static Map<String, String> get properties4 => {
    'Right':tright,
    'Left':tleft,
    'Slight Left':tslightleft,
    'Slight Right':tslightright,
    'Straight':straight,
    'Sharp Left':tsharpleft,
    'Sharp Right':tsharpright
  };


  static String getProperty4(String propertyName,context) {
    if(properties4[propertyName]!=null){
      return properties4[propertyName]!.getString(context);
    }
    return propertyName;
  }

  static Map<String, String> get properties5 => {
    'Right':ttsright,
    'Left':ttsleft,
    'Front':ttsfront,
    'Back':ttsback,
    'None':none,
    'Slight Right':ttsslightright,
    'Slight Left':ttsslightleft,
    'Sharp Left':ttssharpleft,
    'Sharp Right':ttssharpright,
    'U Turn':ttsuturn,

  };


  static String getProperty5(String propertyName,context) {



    if(properties5[propertyName]!=null){
      print("property5 ${properties5[propertyName]!.getString(context)}");
      return properties5[propertyName]!.getString(context);
    }
    return propertyName;
  }

  static Map<String, String> get properties6 => {
    'Go Straight':ttsgostraight

  };


  static String getProperty6(String propertyName,context) {
    if(properties6[propertyName]!=null){
      return properties6[propertyName]!.getString(context);
    }
    return propertyName;
  }




  static const Map<String, dynamic> EN = {
    'iss': 'is',
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
    'Straight':'Straight',

    'Right':'Right',
    'U Turn':'U Turn',
    'Sharp Left':'Sharp Left',
    'Left':'Left',
    'Slight Right':'Slight Right',
    'Slight Left':'Slight Left',
    'Sharp Right':'Sharp Right',

    'tsRight':'Turn right and go straight',
    'tsU Turn':'Turn around and go straight',
    'tsSharp Left':'Turn sharp left and go straight',
    'tsLeft':'Turn left and go straight',
    'tsSlight Right':'Turn slight right and go straight',
    'tsSlight Left':'Turn slight left and go straight',
    'tsSharp Right':'Turn sharp right and go straight',

    'tRight':'Right',
    'tLeft':'Left',
    'tSlightRight':'Slight Right',
    'tSlightLeft':'Slight Left',
    'tSharpRight':'Sharp Right',
    'tSharpLeft':'Sharp Left',

    'Go Straight':'Go Straight',
    'Then': 'Then',
    'and': 'and',
    'Turn':'Turn',
    'Steps':'Steps',
    'will be on your front': 'will be on your front',
    'on your Front': 'on your Front',
    'on your Right': 'on your Right',
    'on your Left': 'on your Left',
    'on your Back': 'on your Back',
    'will be': 'will be',
    'Your current location':'Your current location',
    'Lift':'Lift',
    'Floor' :'Floor',
    'go to': 'go to',
    'from': 'from',
    'Exit': 'exit',
    'Start' :'Start',
    'min': 'min',
    'Take': 'Take',
    'Maps' : 'Maps',
    'slight': 'slight',
    'on your Slight Right' :'on your Slight Right',
    'on your Sharp Right': 'on your Sharp Right',
    'on your Sharp Left': 'on your Sharp Left',
    'on your Slight Left': 'on your Slight Left',
    'Front' : 'Front',
    'Back':'Back',
    'Loading maps' :'Loading maps',
    'Searching your location...' : 'Searching your location...',
    'Please wait': 'Please wait',
    'You are on': 'You are on',
    'is on your':'is on your',
    'near':'near',
    'Unable to find your location': 'Unable to find your location',
    'You are going away from the path. Click Reroute to Navigate from here.': 'You are going away from the path. Click Reroute to Navigate from here.',
    'is': 'is',
    'meter away': 'meter away',
    'Click Start to Navigate' : 'Click Start to Navigate',
    'Explore Mode Enabled' : 'Explore Mode Enabled',
    'Get Direction':'Get Direction',
    'Turn from':'Turn from',
    'Approaching': 'Approaching',
    'hRight':'',
    'hLeft':'',
    'Location':'location',
    'ttsRight':'Right',
    'ttsLeft':'Left',
    'ttsBack':'Back',
    'ttsFront':'Front',
    'None':'None',
    'ttsSlightRight':'Slight Right',
    'ttsSlightLeft':'Slight Left',
    'ttsSharpRight':'Sharp Right',
    'ttsSharpLeft':'Sharp Left',
    'ttsUTurn':'U Turn',
    'ttsGoStraight':'Go Straight',
    'Where you want to go?':'Where you want to go?',
    'Scan nearby QR to know your location':'Scan nearby QR to know your location',
    'You are going away from the path. Rerouting you to the destination':'You are going away from the path. Rerouting you to the destination',






  };

  static const Map<String, dynamic> HI = {
    'iss':'',
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
    '> 6 Feet': '> 6 फीट',
    'Straight': 'सीधे',
    'Right': '',
    'U Turn': 'यू टर्न',
    'Sharp Left': 'तेज़ बाएं',
    'Left': '',
    'Slight Right': 'हल्का दायें',
    'Slight Left': 'हल्का बाएं',
    'Sharp Right': 'तेज़ दाएं',

    'hRight':'से दाईं ओर मुड़ें',
    'hLeft':'से बायीं ओर मुड़ें',

    'tRight':'दाईं ओर मुड़ें',
    'tLeft':'बायीं ओर मुड़ें',


    'tSlightRight':'हल्का दायें ओर मुड़ें',
    'tSlightLeft':'हल्का बाएं ओर मुड़े',
    'tSharpRight':'तीव्र दायें ओर मुड़ें',
    'tSharpLeft':'तीव्र बाएं ओर मुड़े',

    'tsRight': 'दाएँ मुड़ें और सीधे जाएँ',
    'tsU Turn': 'उल्टा घूमे और सीधा जाएँ',
    'tsSharp Left': 'एकदम बाएँ मुड़ें और सीधे जाएँ',
    'tsLeft': 'बाएँ मुड़ें और सीधे जाएँ',
    'tsSlight Right': 'थोड़ा दाएं मुड़ें और सीधे जाएं',
    'tsSlight Left': 'थोड़ा बाएँ मुड़ें और सीधे जाएँ',
    'tsSharp Right': 'एकदम दाहिनी ओर मुड़ें और सीधे जाएं',

    'Then': 'फिर',
    'Go Straight': 'सीधे जाएं',
    'and': 'और',
    'Turn': '',
    'Steps': 'कदम',
    'will be on your front': 'आपके सामने होगा',
    'on your Front': 'आपके सामने है',
    'on your Right': 'आपके दाएँ ओर है',
    'on your Left': 'आपके बाएँ ओर है',
    'on your Back': 'आपके पीछे है',
    'will be': '',
    'Your current location':'आपकी वर्तमान स्थिति',
    'Lift':'लिफ्ट',
    'Floor' :'मंजिल',
    'go to': 'जाओ',
    'from': '',
    'Exit': 'निकास',
    'Start' :'स्टार्ट करे',
    'min': 'मिनट',
    'Take': 'लें',
    'Maps' : 'नक्शा',
    'slight': 'हल्का',
    'on your Slight Right' :'आपके हल्के दायें',
    'on your Sharp Right': 'आपके तेज़ दायें',
    'on your Sharp Left': 'आपके तेज़ बायें',
    'on your Slight Left': 'आपके हल्के बायें',
    'Front' : 'सामने',
    'Back' :'पीछे',
    'Loading maps' :'लोडिंग मैप्स',
    'Searching your location...' : 'आपकी वर्तमान जगह को ढूँढ़ा जा रहा है',
    'Please wait': 'कृपया प्रतीक्षा करें',
    'You are on': 'आप हैं',
    'is on your':'आपके पर है',
    'near':'पास',
    'Unable to find your location': 'आपकी वर्तमान जगह हम ढूँढ़ नहीं पा रहे है',
    'You are going away from the path. Click Reroute to Navigate from here.': 'आप मार्ग से भटक रहे हैं। यहाँ से मार्गदर्शन करने के लिए पुनर्निर्देशित पर क्लिक करें।',
    'is': '',
    'meter away': 'मीटर दूर है',
    'Click Start to Navigate' : 'नेविगेट करने के लिए इस्टार्ट पर क्लिक करें',
    'Explore Mode Enabled' : 'एक्सप्लोर मोड सक्षम',
    'Get Direction':'दिशा',
    'Turn from':'से मुड़ो',
    'Approaching': 'पास आ रहे हैं',
    'Location':'लोकेशन',

    'ttsRight':'राइट',
    'ttsLeft':'लेफ्ट',
    'ttsBack':'बैक',
    'ttsFront':'फ्रंट',
    'None':'शून्य',
    'ttsSlightRight':'थोड़ा राइट',
    'ttsSlightLeft':'थोड़ा लेफ्ट',
    'ttsSharpRight':'तीव्र राइट',
    'ttsSharpLeft':'तीव्र लेफ्ट',
    'ttsUTurn':'यू टर्न',
    'ttsGoStraight':'सीधे चले लगभग',
    'Where you want to go?':'आप कहाँ जाना चाहते हैं?',
    'Scan nearby QR to know your location':'अपना स्थान जानने के लिए नजदिकी QR को स्कैन करें',
    'You are going away from the path. Rerouting you to the destination':'आप रास्ते से दूर जा रहे हैं। आपको आपकी मंजिल की दिशा में रीरूट किया जाया जा रहा है',
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