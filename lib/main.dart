import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/theme/theme_barrel.dart';
import 'services/api_service.dart';
import 'screens/user_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local posts before creating ApiService
  print('Initializing local posts storage...');
  await ApiService.initializeLocalPosts();
  print('Local posts storage initialized');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserBloc(apiService: ApiService())),
        BlocProvider(
          create: (context) {
            final themeBloc = ThemeBloc();
            themeBloc.add(const ThemeInitialized());
            return themeBloc;
          }
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'User Management',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF5C6BC0),
                primary: const Color(0xFF5C6BC0),
                secondary: const Color(0xFF26A69A),
                tertiary: const Color(0xFFFFAB40),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.05),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5C6BC0)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF7986CB),
                primary: const Color(0xFF7986CB),
                secondary: const Color(0xFF4DB6AC),
                tertiary: const Color(0xFFFFD54F),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
              ),
              cardTheme: CardTheme(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7986CB)),
                ),
              ),
            ),
            themeMode: themeState.themeMode,
            home: const UserListScreen(),
          );
        },
      ),
    );
  }
}
