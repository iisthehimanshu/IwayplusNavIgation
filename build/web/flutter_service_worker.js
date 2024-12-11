'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "954560c608b67c9ec3819276efc9b733",
"version.json": "2e5b99ff3997893a9f3eca95dcb50eae",
"macos/Flutter/ephemeral/flutter_export_environment.sh": "afacdbe3234aefc042c6e216bbf457fe",
"macos/Flutter/ephemeral/FlutterInputs.xcfilelist": "d41d8cd98f00b204e9800998ecf8427e",
"macos/Flutter/ephemeral/FlutterOutputs.xcfilelist": "d41d8cd98f00b204e9800998ecf8427e",
"macos/Flutter/ephemeral/Flutter-Generated.xcconfig": "88366040cd667d229762c4a3a82269fb",
"index.html": "34e0a479f7aedffdb30c6b1eb535c605",
"/": "34e0a479f7aedffdb30c6b1eb535c605",
"main.dart.js": "8da13aedd92974c640462a314f7ce921",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"ios/Runner/GeneratedPluginRegistrant.h": "decb9041b5e91a07e66f4664e5dac408",
"ios/Runner/GeneratedPluginRegistrant.m": "f6079b630997f8fd4ae1ac639162419a",
"ios/Flutter/flutter_export_environment.sh": "f47f0e386bdac65ec9952f1b37105d4e",
"ios/Flutter/Generated.xcconfig": "c2a1c9542727fd891eb11f3b54fe91c2",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java": "5b3b418ce50367c33bded3c0df06d47f",
"android/local.properties": "94f73ebaef74f9dca56f0c81fda3400a",
"android/gradle/wrapper/gradle-wrapper.jar": "3ef954ed0adb79a5bd8a5303165fae05",
"android/gradlew": "7f1cd7eb3f75a1dc85cd37753972a6e2",
"android/gradlew.bat": "375ddea382b6c56a7be2a967a20e0ab5",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "1f5ab219698e2eae683645acb7eefecd",
"build/1c0cea059202c435d52af16eca77d145/gen_localizations.stamp": "436d2f2faeb7041740ee3f49a985d62a",
"build/1c0cea059202c435d52af16eca77d145/gen_dart_plugin_registrant.stamp": "171683f9e12bb9c3eb0bfe0f1a08e618",
"build/1c0cea059202c435d52af16eca77d145/_composite.stamp": "436d2f2faeb7041740ee3f49a985d62a",
"assets/AssetManifest.json": "24e2a41b8717226bfe7d7571352b9744",
"assets/NOTICES": "086ac6ecb3b0795b80608f30f2692ae1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "6e015e838692fcee5f91f7daec026994",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "9ed310418882cf97302cd4cf3f6c717e",
"assets/packages/quickalert/assets/confirm.gif": "bdc3e511c73e97fbc5cfb0c2b5f78e00",
"assets/packages/quickalert/assets/error.gif": "c307db003cf53e131f1c704bb16fb9bf",
"assets/packages/quickalert/assets/success.gif": "dcede9f3064fe66b69f7bbe7b6e3849f",
"assets/packages/quickalert/assets/loading.gif": "ac70f280e4a1b90065fe981eafe8ae13",
"assets/packages/quickalert/assets/info.gif": "90d7fface6e2d52554f8614a1f5deb6b",
"assets/packages/quickalert/assets/warning.gif": "f45dfa3b5857b812e0c8227211635cc4",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "d034cda85b853e2edaa2640dafa840a3",
"assets/fonts/MaterialIcons-Regular.otf": "fca4bfa90e4576640b90167305f532df",
"assets/assets/trailing-icon.svg": "a778cd0e2ac7e489286bd3fb0fa0a064",
"assets/assets/Landmark.png": "a72e2a0b584d0722390357851cb292a7",
"assets/assets/Femaletoilet.png": "1b5c393a9a9b07adc5940a703a9be966",
"assets/assets/hospital.png": "ae84632ab6db276a93bca4962f57c0d8",
"assets/assets/lucide_scan-qr-code.svg": "d499afeeeb8b552e1bdb71700784de79",
"assets/assets/StartpointVector.svg": "469c854b12bb4ec1138f703457ac4794",
"assets/assets/Maletoilet.png": "3f686131c616e7526feb8bff076d6fbd",
"assets/assets/check-in.png": "87fc934d8ba3480135bdedeeacf1d57f",
"assets/assets/IwaymapsDefaultMarker.png": "42917e6573db81333083be9afba7e78d",
"assets/assets/BuildingInfoScreen_Share.svg": "4a15c8b60156476d83c7965aeaf283ec",
"assets/assets/MainScreen_Map.svg": "5adf700d50d06bb82b58298629077a88",
"assets/assets/pin.png": "9286dfd78f0a886288b6f28d15a2855c",
"assets/assets/default-image.jpeg": "647870ca8d7fcf74135e6a530d3c16b9",
"assets/assets/EmergencyExit.svg": "38e8ed30313d181ad82969fd6a5d09e4",
"assets/assets/default-image.svg": "1b9a980fcbabf4133f15ac4408d9d167",
"assets/assets/Consultation%2520Room.png": "ae080b0061753828305b6c264e12fb8f",
"assets/assets/mapstyle.json": "d3eeead2b2c8837e0965ea26d5c611d3",
"assets/assets/HelpDesk.svg": "da2ec0d0d4e2305f2aa7e5923e29e086",
"assets/assets/main_entry_marker_icon.png": "db32c6713a77f9a140d697c0a2d72d05",
"assets/assets/log-in.png": "6833ce9a6d690d88971323bc71519e1f",
"assets/assets/success1.png": "2ef904fa26b3023a2708cf44c5db3cad",
"assets/assets/userloc0.png": "17cbb61254e0a3d9cf428539ad92be9c",
"assets/assets/Depth%25203,%2520Frame%25201-3.svg": "423e97110cb9882bbb5e162ef2274acc",
"assets/assets/HelpDesk.png": "78376858bfe943fed1d887cc88ab6801",
"assets/assets/Depth%25203,%2520Frame%25200.svg": "d93b00d3cd5e08473baee9a5cb77b15d",
"assets/assets/Depth%25203,%2520Frame%25201.svg": "1af1ee72a579365c77921c06faece8b6",
"assets/assets/Depth%25203,%2520Frame%25201-2.svg": "2ace8f7b39911339e60ecdfcaf4db5c5",
"assets/assets/BuildingInfoScreen_ParkingLogo.svg": "a98c8013827a212cf128889c4d0525cc",
"assets/assets/ExploreInside.svg": "59380a88635f3ce30eb5835ba950416b",
"assets/assets/HomepageSearch_topBarDirectionIcon.svg": "5be37afa7a2cc24dfe7a0920cfc2259d",
"assets/assets/hugeicons_favourite-circle.svg": "8e8cedc523f38aa51a2c297b2d5ef8ae",
"assets/assets/ratingStarBorder.svg": "e663cfbb094da008fff1d6e2b70df296",
"assets/assets/default-image.jpg": "97046e0244c5e0e78098a1194e0364d6",
"assets/assets/Vector.png": "65435b363dc087c67862c711e8821ac9",
"assets/assets/website.svg": "938ce9e6b9abe97f67641571ecceee2f",
"assets/assets/BuildingInfoScreen_ElevatorLogo.svg": "4fd7f13e11c98fc1b06a544aba6411b2",
"assets/assets/washroomservice.svg": "1a1afdd185dbb98438dafbea5cb428a7",
"assets/assets/LoginScreen_GoogleLogo.svg": "0893570d160182ac547d2f8fe0c4c090",
"assets/assets/closeicon.svg": "d8b053f9b5e7dc3855bd29c56c5583a4",
"assets/assets/EmergencyExit.png": "acdf8538a849fa014f451a85feea61f8",
"assets/assets/Depth%25203,%2520Frame%25201-1.svg": "f77150979bb11ba5323ce4406857856e",
"assets/assets/MainScreen_home.svg": "ba69480863ad3fbbefd671761b7076c5",
"assets/assets/Layer2.svg": "313e655717b2a8a9519b463f268aa99c",
"assets/assets/IwaymapsDefaultMarker.svg": "c19665922bd5c5f8f69293da6f6ce07b",
"assets/assets/Events.png": "8a00be20c8bb250005c63a8d8d507b0f",
"assets/assets/accservice.svg": "c0187f1af40ca3f0dad3a1c8dfda31b4",
"assets/assets/DirectionInstruction_locationPin.svg": "7d11d06fc50d944f8a21b2508c906621",
"assets/assets/dooricon.png": "37b9318992b38c65709b31dee48c4f8d",
"assets/assets/DestinationSearchPage_BackIcon.svg": "0298134e02cb676b1cb118fe835deb65",
"assets/assets/LoginScreen_PasswordEye.svg": "f89e18ae215fe30913d71ce1994d8eec",
"assets/assets/ATM.png": "ac1479f28c0a8229189693aee0689493",
"assets/assets/cutlery.png": "d0ac129d9d961ba1f4e3bc55a889bd9a",
"assets/assets/Layer1.svg": "4becdcc4ee9f1669d0a5aa6752d705e2",
"assets/assets/MainScreen_IwayplusLogo.svg": "8cdda3163f86f3115cc98e2b1fce6f73",
"assets/assets/DirectionInstruction_manImage.svg": "8576fbf581786078a71fddbc8f4c558c",
"assets/assets/Iwayplus_Watermark.svg": "6c37fce1934c8322fcfd2f839e1283e6",
"assets/assets/BuildingInfoScreen_VenueLinkIcon.svg": "4451ede365e0bc1e0f23fb08d154bf69",
"assets/assets/lift.png": "63685a065f16720897900326d10b7c64",
"assets/assets/MapLift.png": "96fbfd4c6a824737561fffd8e1ede29f",
"assets/assets/email.svg": "6c91c684c96b8f6f7dfc9c01e6365818",
"assets/assets/loding_animation.json": "57c8ef64f065e94aa9c02039a129ad31",
"assets/assets/routeDetailPannel_manIcon.svg": "603d4560820f15be029f278727de6539",
"assets/assets/rw.png": "0af30aebb45fac23d96086997a2b1622",
"assets/assets/FoodandDrinks.svg": "797514537c20b1989366c15849529e37",
"assets/assets/close.svg": "faaf4423f24956df5c10d2913e252e33",
"assets/assets/Navigation_closeIcon.svg": "3715b7b65f7d41377648c5082eee5e6f",
"assets/assets/MainScreen_Favourite.svg": "c29b33305ca92b10164841106f18d315",
"assets/assets/localized.json": "09f783588c56143d98015ca3f8466041",
"assets/assets/DirectionInstruction_LiftIcon.svg": "ed9e1b2d58672ce71ec279f5fe212c4c",
"assets/assets/entry.png": "362c93d0cfd51f24316686d1849f5557",
"assets/assets/InsideBuildingCard_HeartIcon.svg": "bea1de8935c890ddf06d96a3b1093f86",
"assets/assets/MainScreen_Scanner.svg": "a8ffe5982c42eb2df824344120c54032",
"assets/assets/location_on.png": "3614cf96d53c26afd35ddcde4c9c32c5",
"assets/assets/navigationVector.svg": "96b56d2e31bfe86e307bd105c0a748ac",
"assets/assets/iconamoon_profile-light.svg": "6b0183aabfd739e17a52daeb14930bbb",
"assets/assets/rest_room_marker_icon.png": "b3bcfe379b33f473734c6293db3c9088",
"assets/assets/clarity_home-line.svg": "ef9f9f0c84e13926da25ed8531f83577",
"assets/assets/MainScreen_Profile.svg": "6f11ea7cd6936f87ed859bdab40509e7",
"assets/assets/tealtorch.png": "b5cd44cfbfe9c4fa6d0fd40edfb5e9c7",
"assets/assets/Office.png": "6d15ba796e09d98d2c3db30e11d13b43",
"assets/assets/error.png": "96c52f65050b843fc6152e885831e0b1",
"assets/assets/MapFemaleWashroom.png": "0837bacabbaf8054dedb5b78039ac128",
"assets/assets/BuildingInfoScreen_AccesibilityLogo.svg": "6727cfa66fe070bfb76b14c41a3b5bd8",
"assets/assets/Navigation_RTLIcon.svg": "49f94e84cd5752fa7c75f6ee1114c102",
"assets/assets/qrlogo.png": "b50c588d9e175b42a0ffd74c88b3b975",
"assets/assets/FirstAid.svg": "7e3839789496d25863b591ab75399dbd",
"assets/assets/IndideBuildingCard_HeartRed.svg": "80759f785d657b7c674df6c01ceca716",
"assets/assets/BuildingInfoScreen_VenueLocationIconsvg.svg": "625ff5f262669b22bce09ee378019d76",
"assets/assets/Washroom.svg": "5859c9b1b27978f7cd79885ec27bd9f0",
"assets/assets/noResults.png": "d986f625b8f7ff0c9b87e1c2ec704795",
"assets/assets/greytorch.png": "542b7806930cd52352d9d93ae030e48d",
"assets/assets/AppIcon.png": "fa9daaa5ce9a7cc4bed6fb0f11e3a968",
"assets/assets/ratingStarFilled.svg": "0bd86b77f2da2953322b696c6d03f64e",
"assets/assets/User%2520image.png": "334982b77c69730cb02fef40a7a29afc",
"assets/assets/calibrate.gif": "7a8e6edf41c7c4d49c7d68611dfd2036",
"assets/assets/cleanenergy.png": "21aab30aaceb34396b93d5c18affc6d3",
"assets/assets/HomepageSearch_FoodFilterIcon.svg": "995d22375013ca24e6e728b8e73582db",
"assets/assets/IT%2520park.png": "2c3cbc8e62ca57e242178453403a7eb3",
"assets/assets/Frame.png": "ddc80f708fd1ed8457c835346296c1d8",
"assets/assets/4.png": "e7187d75936420513103eb84ec2eac63",
"assets/assets/image%25206.png": "3c836522912a3a742a13466d42bc2990",
"assets/assets/call.svg": "99f5f2ae6d95ccaa8bbf7d04359c64a8",
"assets/assets/loading_bluetooth.json": "a121f0b77bec458ae500840e669afa85",
"assets/assets/BuildingInfoScreen_VenuePhoneIcon.svg": "082ffb97444237c6d9cfe807051fd3bb",
"assets/assets/Reroutevector.svg": "fa5c9af72cffb8e728b2e6bcefe14359",
"assets/assets/routeDetailPannel_LisftIcon.svg": "b4c8acf1f0916e93701174c2fe675882",
"assets/assets/exitservice.svg": "14309c780d018875fc3210f03cdf11dc",
"assets/assets/Generic%2520Marker.png": "9d0a6c835ff9d0caf8fa56fcbc801ff9",
"assets/assets/MapEntry.png": "76387b47a4c3b3a41e5ae9812abb1891",
"assets/assets/Academic.png": "fef8461db25f7a350e6292251aa91b59",
"assets/assets/foodservice.svg": "018de677a79850d4a2cb90a5c4989eba",
"assets/assets/carbon_map.svg": "7488015c0ca30f861e60a786c3e964e8",
"assets/assets/6.png": "4aa94e117fd044e9f0496c11856541c2",
"assets/assets/DirectionInstruction_sourceIcon.svg": "811db6c87a596c01430c219914eca5de",
"assets/assets/Classroom.png": "8258dbb9cb205436b26bdb752fdc0aee",
"assets/assets/elevator.svg": "9bce68cc00484bc0e4783a8a154a9521",
"assets/assets/SearchpageCategoryResult_manIcon.svg": "43e731c1bca6832ce2579d1195ef7ba2",
"assets/assets/dooricon%25202.png": "37b9318992b38c65709b31dee48c4f8d",
"assets/assets/previewarrow.png": "0efe89c58a1c1c49ede9f952c99e1542",
"assets/assets/3.png": "a67a776eb67c20a30c2e0a63df1470a5",
"assets/assets/pyramids.png": "7f5c380570f211a8f7a4b6c4acc446d6",
"assets/assets/1.png": "9ea48f6fa0c6f443d1a522109527e645",
"assets/assets/door_marker_icon.png": "b05b0a23763e88a4e44f5b70364252d7",
"assets/assets/routeDetailPannel_ShareIcon.svg": "19d781ea8e14812207324f4231ec4dc5",
"assets/assets/entry.svg": "4c7649b70ee6991cdf74d229a79ddb64",
"assets/assets/room_marker_icon.png": "8f9db95f96008a34b5a365723650af52",
"assets/assets/MapMaleWashroom.png": "234860004e6a7b71fdce4c3869c71f44",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
