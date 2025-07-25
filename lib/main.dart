import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'dart:developer' as dev; // For logging instead of print
import 'package:provider/provider.dart'; // Import Provider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // Import Facebook Auth
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Import Sign in with Apple
import 'account_selection_screen.dart'; // Import the account selection screen
import 'content_aggregation_screen.dart'; // Import content aggregation screen
import 'models/user_data.dart'; // Import the UserData model
import 'package:firebase_core/firebase_core.dart';

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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
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
    );

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
          backgroundColor: Colors.deepPurple[200], // Use a valid color shade
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Use default font
        ),
      ),
    );

    return MaterialApp(
      title: 'Flutter Material AI App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      // Define named routes
      routes: {
        '/': (context) => RegistrationScreen(), // Registration is the initial route
        '/accountSelection': (context) => const AccountSelectionScreen(), // Route to Account Selection
        // You can add other routes here as you build more screens
        // '/postContent': (context) => const PostContentScreen(), // Commented out: class not found
        '/massesSocialContent': (context) => const ContentAggregationScreen(),
      },
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  // Helper function to navigate after successful sign-up/sign-in
  void _navigateToAccountSelection() {
     Navigator.pushReplacementNamed(context, '/accountSelection'); // Use pushReplacementNamed
  }
  
  // Helper function to save new user data to Firestore
  // Helper function to save new user data to Firestore
  Future<void> _saveNewUserToFirestore(User user) async {
     // Create user data object
     final UserData newUser = UserData(
        uid: user.uid,
        email: user.email ?? '',
     );
     // TODO: Save to Firestore would go here
     // For example: FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toMap());
     dev.log('New user data saved to Firestore for ${user.email}');
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signInInteractively();
      if (googleUser == null) {
        dev.log('Google sign in was aborted by the user');
        return;
      }
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user data to Firestore if new user
      if (userCredential.additionalUserInfo!.isNewUser) {
         if (userCredential.user != null) {
            await _saveNewUserToFirestore(userCredential.user!);
         }
      } else {
        dev.log('Existing Google user signed in: ${userCredential.user!.email}');
      }
      
      dev.log('Signed in with Google: ${userCredential.user!.email}');
      // Navigate to the next screen after successful sign-in
      _navigateToAccountSelection();

    } catch (e) {
      dev.log('Error signing in with Google: $e');
    }
  }

  Future<void> _signInWithFacebook() async {
  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        // Once signed in, return the UserCredential
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        // Check if this is a new user and save data to Firestore if so
        if (userCredential.additionalUserInfo!.isNewUser) {
          if (userCredential.user != null) {
            await _saveNewUserToFirestore(userCredential.user!);
          }
        } else {
          dev.log('Existing Facebook user signed in: ${userCredential.user!.displayName}');
        }
        
        dev.log('Signed in with Facebook: ${userCredential.user!.displayName}');
        // Navigate to the next screen after successful sign-in
        _navigateToAccountSelection();
      } else if (result.status == LoginStatus.cancelled) {
        dev.log('Facebook login cancelled');
      } else {
        dev.log('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      dev.log('Error signing in with Facebook: $e');
    }
  }
  Future<void> _signInWithApple() async {
  Future<void> _signInWithApple() async {
    try {
      // Trigger the Apple Sign-In flow
      // Intended future use: Use iCloud account to get media to post.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create a Firebase credential from the Apple credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      
      final firebaseCredential = oauthCredential;
      UserCredential userCredential = await _auth.signInWithCredential(firebaseCredential);

      // Check if this is a new user and save data to Firestore if so
      if (userCredential.additionalUserInfo!.isNewUser) {
         if (userCredential.user != null) {
            await _saveNewUserToFirestore(userCredential.user!);
         }
      } else {
         dev.log('Existing Apple user signed in: ${userCredential.user!.displayName}');
      }
      
      dev.log('Signed in with Apple: ${userCredential.user!.displayName}');
      // Navigate to the next screen after successful sign-in
      _navigateToAccountSelection();

    } catch (e) {
      dev.log('Error signing in with Apple: $e');
      // Handle the specific error when Apple Sign-In is not supported
      if (e is SignInWithAppleNotSupportedException || e is PlatformException) {
        dev.log('Apple Sign-In is not supported on this device.');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
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
                    child: Text('Sign Up with Apple ID'),
                  ),
              SizedBox(height: 16), // Add some spacing
               ElevatedButton(
                 onPressed: _signInWithFacebook, // Call the Facebook Sign-In function
                 child: Text('Sign Up with Facebook'),
               ),
              SizedBox(height: 16), // Add some spacing
               ElevatedButton(
                 onPressed: _signInWithGoogle, // Call the Google Sign-In function
                 child: Text('Sign Up with Google'),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

// Note: Other screen widgets (AccountSelectionScreen, ContentAggregationScreen, PostContentScreen, MassesSocialContentScreen) are in separate files.
