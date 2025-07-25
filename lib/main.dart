import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'dart:developer'; // For logging instead of print
import 'package:provider/provider.dart'; // Import Provider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // Import Facebook Auth
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Import Sign in with Apple
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

// Comment out Firebase options until you've run flutterfire configure
// import 'firebase_options.dart';

import 'account_selection_screen.dart'; // Import the account selection screen
import 'content_aggregation_screen.dart'; // Import content aggregation screen
import 'models/user_data.dart'; // Import the UserData model
import 'post_content_screen.dart'; // Import the post content screen (assuming it exists)
import 'masses_social_content_screen.dart'; // Import the masses social content screen (assuming it exists)


// Theme provider class
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase without options for now
    await Firebase.initializeApp();
    log('Firebase initialized successfully.');
  } catch (e) {
    log('Error initializing Firebase: $e. Ensure flutterfire configure has been run and google-services.json/GoogleService-Info.plist are in the correct directories.');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const Color primarySeedColor = Colors.deepPurple;

    // Define a common TextTheme (using default font for now)
    final TextTheme appTextTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Use default font
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Use default font
        ),
      ),
    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Use default font
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Corrected foreground color
          backgroundColor: Colors.deepPurple[200], // Use array access instead of .shade200
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Use default font
        ),
      ),
    );
      ),
    );

    return MaterialApp(
      title: 'Flutter Material AI App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      // Define named routes
      routes: {
        '/': (context) => const RegistrationScreen(), // Registration is the initial route
        '/accountSelection': (context) => const AccountSelectionScreen(), // Route to Account Selection
        // Ensure these screens exist as placeholder files if not fully implemented yet
        '/postContent': (context) => const PostContentScreen(), // Route to Post Content Screen
        '/massesSocialContent': (context) => const MassesSocialContentScreen(), // Route to Masses Social Content Screen
      },
      initialRoute: '/', // Set the initial route
    );
  }
}

// Step 1: User Registration
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Get Firestore instance
  // GoogleSignIn instance - initialize in initState
  late GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  Future<void> _initializeGoogleSignIn() async {
    _googleSignIn = GoogleSignIn();
    // You can set scopes later if needed
    // _googleSignIn.scopes.addAll([
    //   'email',
    //   'https://www.googleapis.com/auth/youtube.readonly',
    //   'https://www.googleapis.com/auth/drive.readonly',
    // ]);
  }
    );
  }

  // Helper function to navigate after successful sign-up/sign-in
  void _navigateToAccountSelection() {
     // Check if the widget is still mounted before using context
     if (!mounted) return;
     Navigator.pushReplacementNamed(context, '/accountSelection'); // Use pushReplacementNamed
  }

  // Helper function to save new user data to Firestore
  Future<void> _saveNewUserToFirestore(User user) async {
     // Create user data object
     final UserData newUser = UserData(
        uid: user.uid,
        email: user.email ?? '',
     );
     // Save to Firestore
     await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
     log('New user data saved to Firestore for ${user.email}'); // Use log
  }
  Future<void> _signInWithGoogle() async {
    try {
      // Sign out any previous Google user before signing in again (optional but good practice)
      await _googleSignIn.signOut();
      // Use interactive sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log('Google sign-in cancelled'); // Use log
        return;
      }
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user data to Firestore if new user
      if (userCredential.additionalUserInfo!.isNewUser) {
         if (userCredential.user != null) {
            await _saveNewUserToFirestore(userCredential.user!);
         }
      } else {
        log('Existing Google user signed in: ${userCredential.user!.email}'); // Use log
      }

      log('Signed in with Google: ${userCredential.user!.email}'); // Use log
      // Navigate to the next screen after successful sign-in
      _navigateToAccountSelection();

    } catch (e) {
      log('Error signing in with Google: $e'); // Use log
    }
  }
  Future<void> _signInWithFacebook() async {
    try {
      // Ensure FacebookAuth is correctly initialized if needed (usually done automatically)
      // FacebookAuth.instance.init(); // Uncomment if needed based on package docs

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'], // Add necessary permissions
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken; // Use nullable AccessToken
         if (accessToken == null) {
          log('Facebook login failed: Access Token is null'); // Use log
          return;
        }

        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token); // Use accessToken.token
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Check if this is a new user and save data to Firestore if so
        if (userCredential.additionalUserInfo!.isNewUser) {
           if (userCredential.user != null) {
              await _saveNewUserToFirestore(userCredential.user!);
           }
        } else {
             log('Existing Facebook user signed in: ${userCredential.user!.displayName}'); // Use log
        }

        log('Signed in with Facebook: ${userCredential.user!.displayName}'); // Use log
        _navigateToAccountSelection();

      } else if (result.status == LoginStatus.cancelled) {
        log('Facebook login cancelled'); // Use log
      } else if (result.status == LoginStatus.failed) {
        log('Facebook login failed: ${result.message}'); // Use log
      }
    } catch (e) {
      log('Error signing in with Facebook: $e'); // Use log
    }
  }

  Future<void> _signInWithApple() async {
    try {
      // Trigger the Apple Sign-In flow
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
         // Add nonce and state if you are using them for security
        // nonce: 'YOUR_NONCE',
        // state: 'YOUR_STATE',
      );

      // Create a Firebase credential from the Apple credential
      final OAuthProvider appleProvider = OAuthProvider('apple.com');
      final AuthCredential firebaseCredential = appleProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(firebaseCredential);
    // Check if this is a new user and save data to Firestore if so
    if (userCredential.additionalUserInfo!.isNewUser) {
       if (userCredential.user != null) {
          await _saveNewUserToFirestore(userCredential.user!);
       }
    } else {
       log('Existing Apple user signed in: ${userCredential.user!.displayName}'); // Use log
    }

    log('Signed in with Apple: ${userCredential.user!.displayName}'); // Use log
    _navigateToAccountSelection();

  } catch (e) {
    log('Error signing in with Apple: $e'); // Use log
    // Handle the specific error when Apple Sign-In is not supported
    if (e is SignInWithAppleException || e is PlatformException) { // Check for specific Apple Sign-In exceptions or PlatformException
      log('Apple Sign-In is not supported on this device or encountered an error: ${e.toString()}'); // Use log
    } else {
      log('An unexpected error occurred during Apple Sign-In: ${e.toString()}'); // Use log for unexpected errors
    }
  }
}
  }\


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
            children: [
               // Only show Apple Sign-In button if supported on the device
               if (TargetPlatform.iOS == Theme.of(context).platform || TargetPlatform.macOS == Theme.of(context).platform)
                  ElevatedButton(
                    onPressed: _signInWithApple, // Call the Apple Sign-In function
                    child: const Text('Sign Up with Apple ID'),
                  ),
              const SizedBox(height: 16), // Add some spacing
               ElevatedButton(
                 onPressed: _signInWithFacebook, // Call the Facebook Sign-In function
                 child: const Text('Sign Up with Facebook'),
               ),
              const SizedBox(height: 16), // Add some spacing
               ElevatedButton(
                 onPressed: _signInWithGoogle, // Call the Google Sign-In function
                 child: const Text('Sign Up with Google'),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

  // Note: Other screen widgets (AccountSelectionScreen, ContentAggregationScreen, PostContentScreen, MassesSocialContentScreen) are in separate files.