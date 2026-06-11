import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @app_title.
  ///
  /// In zh, this message translates to:
  /// **'馬太鞍濕地生態導覽'**
  String get app_title;

  /// No description provided for @nav_home.
  ///
  /// In zh, this message translates to:
  /// **'首頁'**
  String get nav_home;

  /// No description provided for @nav_map.
  ///
  /// In zh, this message translates to:
  /// **'導覽地圖'**
  String get nav_map;

  /// No description provided for @nav_audio_guide.
  ///
  /// In zh, this message translates to:
  /// **'語音導覽'**
  String get nav_audio_guide;

  /// No description provided for @nav_settings.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get nav_settings;

  /// No description provided for @nav_about.
  ///
  /// In zh, this message translates to:
  /// **'關於園區'**
  String get nav_about;

  /// No description provided for @nav_trips.
  ///
  /// In zh, this message translates to:
  /// **'我的行程'**
  String get nav_trips;

  /// No description provided for @btn_play.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get btn_play;

  /// No description provided for @btn_pause.
  ///
  /// In zh, this message translates to:
  /// **'暫停'**
  String get btn_pause;

  /// No description provided for @btn_next.
  ///
  /// In zh, this message translates to:
  /// **'下一站'**
  String get btn_next;

  /// No description provided for @btn_back.
  ///
  /// In zh, this message translates to:
  /// **'上一站'**
  String get btn_back;

  /// No description provided for @btn_start_tour.
  ///
  /// In zh, this message translates to:
  /// **'開始導覽'**
  String get btn_start_tour;

  /// No description provided for @btn_more_info.
  ///
  /// In zh, this message translates to:
  /// **'更多資訊'**
  String get btn_more_info;

  /// No description provided for @btn_language.
  ///
  /// In zh, this message translates to:
  /// **'切換語言'**
  String get btn_language;

  /// No description provided for @btn_overview.
  ///
  /// In zh, this message translates to:
  /// **'概覽'**
  String get btn_overview;

  /// No description provided for @btn_view.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get btn_view;

  /// No description provided for @btn_add.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get btn_add;

  /// No description provided for @btn_copy.
  ///
  /// In zh, this message translates to:
  /// **'複製'**
  String get btn_copy;

  /// No description provided for @label_duration.
  ///
  /// In zh, this message translates to:
  /// **'導覽長度'**
  String get label_duration;

  /// No description provided for @label_distance.
  ///
  /// In zh, this message translates to:
  /// **'距離'**
  String get label_distance;

  /// No description provided for @label_minutes.
  ///
  /// In zh, this message translates to:
  /// **'分鐘'**
  String get label_minutes;

  /// No description provided for @label_meters.
  ///
  /// In zh, this message translates to:
  /// **'公尺'**
  String get label_meters;

  /// No description provided for @label_experience.
  ///
  /// In zh, this message translates to:
  /// **'體驗特色'**
  String get label_experience;

  /// No description provided for @label_cultural_wisdom.
  ///
  /// In zh, this message translates to:
  /// **'文化智慧'**
  String get label_cultural_wisdom;

  /// No description provided for @label_ecological_feature.
  ///
  /// In zh, this message translates to:
  /// **'生態特徵'**
  String get label_ecological_feature;

  /// No description provided for @filter_facility.
  ///
  /// In zh, this message translates to:
  /// **'設備'**
  String get filter_facility;

  /// No description provided for @filter_scenic_spot.
  ///
  /// In zh, this message translates to:
  /// **'景點'**
  String get filter_scenic_spot;

  /// No description provided for @filter_wildlife.
  ///
  /// In zh, this message translates to:
  /// **'野生動植物'**
  String get filter_wildlife;

  /// No description provided for @filter_culture.
  ///
  /// In zh, this message translates to:
  /// **'在地文化'**
  String get filter_culture;

  /// No description provided for @tab_upcoming.
  ///
  /// In zh, this message translates to:
  /// **'即將到來'**
  String get tab_upcoming;

  /// No description provided for @tab_history.
  ///
  /// In zh, this message translates to:
  /// **'歷史紀錄'**
  String get tab_history;

  /// No description provided for @trip_plan_new.
  ///
  /// In zh, this message translates to:
  /// **'規劃新行程'**
  String get trip_plan_new;

  /// No description provided for @trip_go.
  ///
  /// In zh, this message translates to:
  /// **'出發'**
  String get trip_go;

  /// No description provided for @trip_name.
  ///
  /// In zh, this message translates to:
  /// **'行程名稱'**
  String get trip_name;

  /// No description provided for @trip_stops.
  ///
  /// In zh, this message translates to:
  /// **'停靠站'**
  String get trip_stops;

  /// No description provided for @trip_my_journeys.
  ///
  /// In zh, this message translates to:
  /// **'我的行程'**
  String get trip_my_journeys;

  /// No description provided for @trip_your_journey.
  ///
  /// In zh, this message translates to:
  /// **'您的旅程'**
  String get trip_your_journey;

  /// No description provided for @trip_no_upcoming.
  ///
  /// In zh, this message translates to:
  /// **'目前沒有即將到來的旅程'**
  String get trip_no_upcoming;

  /// No description provided for @trip_create_journey.
  ///
  /// In zh, this message translates to:
  /// **'建立旅程'**
  String get trip_create_journey;

  /// No description provided for @trip_select_dates.
  ///
  /// In zh, this message translates to:
  /// **'選擇日期'**
  String get trip_select_dates;

  /// No description provided for @category_leisure.
  ///
  /// In zh, this message translates to:
  /// **'休閒活動'**
  String get category_leisure;

  /// No description provided for @category_education.
  ///
  /// In zh, this message translates to:
  /// **'生態教育'**
  String get category_education;

  /// No description provided for @category_culture.
  ///
  /// In zh, this message translates to:
  /// **'文化體驗'**
  String get category_culture;

  /// No description provided for @category_adventure.
  ///
  /// In zh, this message translates to:
  /// **'冒險探索'**
  String get category_adventure;

  /// No description provided for @chatbot_greeting.
  ///
  /// In zh, this message translates to:
  /// **'有什麼我可以幫您的嗎？'**
  String get chatbot_greeting;

  /// No description provided for @chatbot_placeholder.
  ///
  /// In zh, this message translates to:
  /// **'您可以詢問有關景點、行程規劃或旅遊小撇步。'**
  String get chatbot_placeholder;

  /// No description provided for @chatbot_btn_ask.
  ///
  /// In zh, this message translates to:
  /// **'詢問導覽員'**
  String get chatbot_btn_ask;

  /// No description provided for @station_1_title.
  ///
  /// In zh, this message translates to:
  /// **'馬太鞍濕地生態園區概述'**
  String get station_1_title;

  /// No description provided for @station_1_intro.
  ///
  /// In zh, this message translates to:
  /// **'走進花蓮最純淨的自然秘境，感受湧泉濕地與阿美族文化交織的原始魅力。'**
  String get station_1_intro;

  /// No description provided for @station_1_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'歡迎來到馬太鞍濕地，一起走進花蓮最純淨的自然秘境。'**
  String get station_1_audio_open;

  /// No description provided for @station_1_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'眼前這片廣闊濕地，水道縱橫、野草搖曳，潺潺水聲伴隨著鳥鳴，營造出寧靜清幽的氛圍。沿著步道前行，可以看見魚群穿梭、水鳥覓食的生動景象。'**
  String get station_1_audio_desc;

  /// No description provided for @station_1_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'馬太鞍濕地是阿美族重要的傳統生活場域，也是臺灣少見的內陸湧泉溼地。當地人發展出與自然共存的智慧，讓這片土地孕育了極其豐富的動植物生態。'**
  String get station_1_audio_story;

  /// No description provided for @station_1_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'不妨放慢腳步，仔細觀察水面與草叢間，看看您能發現幾種不同的生物呢？'**
  String get station_1_audio_interact;

  /// No description provided for @station_1_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'在這片原始而靜謐的濕地中，感受人與自然最和諧的距離，歡迎開啟您的探索之旅。'**
  String get station_1_audio_end;

  /// No description provided for @station_2_title.
  ///
  /// In zh, this message translates to:
  /// **'巴拉告（Palakaw）生態智慧'**
  String get station_2_title;

  /// No description provided for @station_2_intro.
  ///
  /// In zh, this message translates to:
  /// **'阿美族人為魚蝦量身打造的「三層手作豪宅」，展現不貪心的永續生態哲學。'**
  String get station_2_intro;

  /// No description provided for @station_2_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'嘿！您有聽說過不用魚鉤，只要幫魚「蓋房子」，牠們就會自動搬進來的神奇故事嗎？'**
  String get station_2_audio_open;

  /// No description provided for @station_2_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'請看看您眼前的這座清澈水池，水面上看似雜亂的枯木與竹筒，其實是阿美族人為魚蝦量身打造的「三層高級公寓」。'**
  String get station_2_audio_desc;

  /// No description provided for @station_2_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'這套獨門建築學叫「巴拉告（Palakaw）」：底層竹筒區是鰻魚和土虱的臥室；中層樹枝區是蝦子和螃蟹的物種避風港；最頂樓的雜草與棕櫚葉則是小魚的遮陰幼兒園。族人秉持著「要吃才抓、適量捕撈」的精神，先幫魚造家，等牠們長大了才採收。'**
  String get station_2_audio_story;

  /// No description provided for @station_2_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'現在，您可以靠近水邊觀察，或者捲起褲管親自將雙腳踏入這片沁涼的水域中，摸摸看魚筌的構造，找找看有沒有躲在竹筒空隙裡的小蝦？'**
  String get station_2_audio_interact;

  /// No description provided for @station_2_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'這種「只取所需、不過度撈捕」的共生法則，正是阿美族傳承千年的生態哲學，讓人對大地的智慧肅然起敬。'**
  String get station_2_audio_end;

  /// No description provided for @station_3_title.
  ///
  /// In zh, this message translates to:
  /// **'服務中心與欣綠農園入口'**
  String get station_3_title;

  /// No description provided for @station_3_intro.
  ///
  /// In zh, this message translates to:
  /// **'以可愛的大青蛙地標為起點，進入融合在地餐飲與原民文化的熱情園區。'**
  String get station_3_intro;

  /// No description provided for @station_3_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'歡迎來到馬太鞍休閒農業區，準備開啟一段與濕地共呼吸的自然之旅！'**
  String get station_3_audio_open;

  /// No description provided for @station_3_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'眼前這個入口處，有一隻極為醒目的大青蛙，牠是整個濕地探索的重要地標；而旁邊的欣綠農園，則是充滿在地故事與熱情的人文匯聚地。'**
  String get station_3_audio_desc;

  /// No description provided for @station_3_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'這裡是騎單車或自由行旅人進入濕地最理想的起點。園區內展示了阿美族人長久以來依循自然節奏生活的軌跡，並將在地友善農作與傳統文化緊密結合。'**
  String get station_3_audio_story;

  /// No description provided for @station_3_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'不妨與這隻可愛的大青蛙拍張照，想像自己即將化身為一隻穿梭在濕地間的小青蛙，開啟一段豐富的生態探險吧！'**
  String get station_3_audio_interact;

  /// No description provided for @station_3_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'記住這個充滿生命力的入口，讓您的馬太鞍之旅，有一個最自然、最完整的開始。'**
  String get station_3_audio_end;

  /// No description provided for @station_4_title.
  ///
  /// In zh, this message translates to:
  /// **'阿美族傳統石頭火鍋體驗'**
  String get station_4_title;

  /// No description provided for @station_4_intro.
  ///
  /// In zh, this message translates to:
  /// **'利用滾燙的蛇紋石與新鮮竹筒，就地取材演繹一場令人驚嘆的料理魔法秀。'**
  String get station_4_intro;

  /// No description provided for @station_4_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'你知道嗎？不用瓦斯、不用現代爐具，只靠石頭就能煮出一鍋令人垂涎三尺的鮮美魚湯！'**
  String get station_4_audio_open;

  /// No description provided for @station_4_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'現場可以看到新鮮的竹筒盛裝著清澈泉水與野菜魚蝦，而旁邊一團熊熊烈火中，正燒著一塊塊滾透紅熱的蛇紋石，空氣中瀰漫著淡淡的竹香與柴火氣味。'**
  String get station_4_audio_desc;

  /// No description provided for @station_4_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'這是阿美族傳統的「石煮法」智慧。族人將燒得火紅的石頭直接放入竹筒中，瞬間發出「滋滋」巨響並翻騰起陣陣熱氣，利用極高溫在數秒內讓湯頭快速沸騰，完美鎖住食材的鮮甜。整個用餐過程更提倡零垃圾的「慢食文化」，連衛生紙都不提供，直接用純淨溪水洗手，展現對環境的最高敬意。'**
  String get station_4_audio_story;

  /// No description provided for @station_4_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'請仔細聽聽熱石與泉水碰撞的奇妙交響樂，並聞聞那股撲鼻而來的天然香氣，是不是讓您食指大動了呢？'**
  String get station_4_audio_interact;

  /// No description provided for @station_4_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'這不只是一道讓人大飽口福的風味料理，幕後更是原住民就地取材、與環境共好的純粹感動。'**
  String get station_4_audio_end;

  /// No description provided for @station_5_title.
  ///
  /// In zh, this message translates to:
  /// **'樹豆（Fata\'an）與地名由來'**
  String get station_5_title;

  /// No description provided for @station_5_intro.
  ///
  /// In zh, this message translates to:
  /// **'認識孕育整片濕地名字的靈魂植物——象徵強韌生命力與原民活力的樹豆。'**
  String get station_5_intro;

  /// No description provided for @station_5_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'各位朋友，前方這麼多綠意盎然的植物，您知道哪一種才是這裡的「姓名之源」嗎？'**
  String get station_5_audio_open;

  /// No description provided for @station_5_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'環顧四周，您可以看見前方長著一株株結滿豆莢、在微風中搖曳的灌木，那就是阿美族人視為珍寶的「樹豆」。'**
  String get station_5_audio_desc;

  /// No description provided for @station_5_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'「馬太鞍」這個地名，其實就源自於阿美族語的「Fata\'an」，意思就是「樹豆」。早期這片土地隨處可見野生樹豆，它是族人最重要的傳統主食與活力泉源，吃了能讓人身強體壯，因此成為這片家園的永續象徵。'**
  String get station_5_audio_story;

  /// No description provided for @station_5_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'不妨走近仔細端詳樹豆的葉片與豆莢，摸摸牠強韌的枝幹，猜猜看阿美族人通常會用牠來熬煮什麼樣的美味湯品呢？'**
  String get station_5_audio_interact;

  /// No description provided for @station_5_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'記住這顆小小的樹豆，因為牠代表著流淌在馬太鞍土地上，最深沉、最堅韌的文化根基。'**
  String get station_5_audio_end;

  /// No description provided for @station_6_title.
  ///
  /// In zh, this message translates to:
  /// **'芙登溪與生態木棧道'**
  String get station_6_title;

  /// No description provided for @station_6_intro.
  ///
  /// In zh, this message translates to:
  /// **'漫步在架高的蜿蜒棧道上，俯瞰清澈見底的芙登溪，體會人與大自然的溫柔約定。'**
  String get station_6_intro;

  /// No description provided for @station_6_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'您現在腳下踩的，不只是一條木棧道，而是一個通往濕地生命的綠色入口。'**
  String get station_6_audio_open;

  /// No description provided for @station_6_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'這條蜿蜒的木棧道架高在清澈見底的芙登溪之上，溪水裡水草隨波搖曳，兩旁綠意盎然，潺潺水聲伴隨微風，讓人身心瞬間舒暢。'**
  String get station_6_audio_desc;

  /// No description provided for @station_6_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'芙登溪是馬太鞍的靈魂水源。在沒有這條棧道以前，遊客隨意踩踏會破壞脆弱的濕地泥地與植被；而現在，這條架高的棧道成為一種「溫柔的約定」，讓我們能近距離觀察自然，同時不打擾小生命的家園。'**
  String get station_6_audio_story;

  /// No description provided for @station_6_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'請放慢腳步或停下身來，低頭看看清澈的泉水，試著找找看有沒有穿梭在水草間的小魚，或者閉上眼睛深呼吸，感受空氣中帶有淡淡的植物清香。'**
  String get station_6_audio_interact;

  /// No description provided for @station_6_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'離開之前，記得帶走的不只是相簿裡的照片，更是您曾經與這片土地和諧共處的平靜力量。'**
  String get station_6_audio_end;

  /// No description provided for @station_7_title.
  ///
  /// In zh, this message translates to:
  /// **'水柳區與夜間螢火蟲導覽'**
  String get station_7_title;

  /// No description provided for @station_7_intro.
  ///
  /// In zh, this message translates to:
  /// **'走進長滿水柳樹的寧靜水域，在夏夜裡尋找閃爍的綠色微光，聆聽大自然的健康訊號。'**
  String get station_7_intro;

  /// No description provided for @station_7_audio_open.
  ///
  /// In zh, this message translates to:
  /// **'歡迎大家，準備好跟著我們一起走進這片只屬於夜晚的「光之森林」了嗎？'**
  String get station_7_audio_open;

  /// No description provided for @station_7_audio_desc.
  ///
  /// In zh, this message translates to:
  /// **'現在我們所在的位置是水柳區，周圍可以看到一整排水柳樹生長在濕地之中，環境非常自然安靜。當夜幕完全垂下，點點神祕的綠色微光會慢慢在您身旁亮起。'**
  String get station_7_audio_desc;

  /// No description provided for @station_7_audio_story.
  ///
  /// In zh, this message translates to:
  /// **'水柳是一種極其適合潮濕環境的植物，能深度淨化水質。而這裡更是螢火蟲的繁衍天堂，因為螢火蟲對環境極度敏感，只有在最純淨的水質、完全沒有光害的地方才能生存。牠們閃爍的生命，其實正是在向人類宣告：這片土地還很健康！'**
  String get station_7_audio_story;

  /// No description provided for @station_7_audio_interact.
  ///
  /// In zh, this message translates to:
  /// **'接下來，請大家試著關掉身上的強光與手電筒，放慢步伐、放低說話音量，用雙眼去尋找那一閃一閃的光點，看看您能發現幾隻螢火蟲呢？'**
  String get station_7_audio_interact;

  /// No description provided for @station_7_audio_end.
  ///
  /// In zh, this message translates to:
  /// **'請深深記住今晚的微光與水柳倒影，因為這璀璨的夜光不只是風景，更是大自然送給馬太鞍最珍貴的健康勳章。'**
  String get station_7_audio_end;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
