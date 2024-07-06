import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:template/providers/flutter%20pub%20add%20provider.dart';
import 'package:template/responsive/mobile_screen_layout.dart';
import 'package:template/responsive/rsponsive_layout_screen.dart';
import 'package:template/responsive/web_screen_layout.dart';
import 'package:template/screens/login_screen.dart';
import 'package:template/screens/signup_screen.dart';
import 'package:template/utils/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //       apiKey: 'AIzaSyAvRX_N9M6Hgbm73scTjbmhNgERFQ5q6sw',
  //       appId: '1:942230575861:android:6a27e3f299cbf4f86083bc',
  //       messagingSenderId: '829168300593',
  //       projectId: 'template-7f166',
  //       storageBucket: 'instegram-clo.appspot.com',
  //     ),
  //   );
  // } else {
  // }
    await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        
        debugShowCheckedModeBanner: false,
        title: 'template',
                    localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // AppLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
          Locale('he'), // Spanish
        ],
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
                // return const SignupScreen();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return const SignupScreen();
            // return const LoginScreen();
          },
        ),
      ),
    );
  }
}