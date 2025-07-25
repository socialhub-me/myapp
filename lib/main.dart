import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the Firebase options file
import 'package:provider/provider.dart'; // Import Provider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // Import Facebook Auth
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Import Sign in with Apple
import 'account_selection_screen.dart'; // Import the account selection screen
import 'content_aggregation_screen.dart'; // Import content aggregation screen
import 'models/user_data.dart'; // Import the UserData model

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Create a ThemeProvider
      child: const MyApp(),
    ),
  );
}

// ThemeProvider class to manage the theme state (as per guidelines)
class ThemeProvider with ChangeNotifier {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Use default font
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Material AI App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          // Define named routes
          routes: {
            '/': (context) => const RegistrationScreen(), // Registration is the initial route
            '/accountSelection': (context) => const AccountSelectionScreen(), // Route to Account Selection
            // You can add other routes here as you build more screens
             '/contentAggregation': (context) => const ContentAggregationScreen(),
             '/postContent': (context) => const PostContentScreen(),
             '/massesSocialContent': (context) => const MassesSocialContentScreen(),
          },
          initialRoute: '/', // Set the initial route
        );
      },
    );
  }
}

// Step 1: User Registration
class RegistrationScreen extends StatefulWidget { // Change to StatefulWidget
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Get Firestore instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance

  // Helper function to navigate after successful sign-up/sign-in
  void _navigateToAccountSelection() {
     Navigator.pushReplacementNamed(context, '/accountSelection'); // Use pushReplacementNamed
  }

  // Helper function to save new user data to Firestore
  Future<void> _saveNewUserToFirestore(User user) async {
     UserData newUser = UserData(
        uid: user.uid,
        email: user.email ?? '',
     );
     await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
     print('New user data saved to Firestore for ${user.email}');
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      // Intended future use: Establish YouTube account connection for subscriptions and access Google Drive for media.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Abort if the user cancels the sign-in
      if (googleUser == null) {
        print('Google sign-in cancelled');
        return;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
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
           print('Existing Google user signed in: ${userCredential.user!.email}');
      }
      
      print('Signed in with Google: ${userCredential.user!.email}');
      // Navigate to the next screen after successful sign-in
       _navigateToAccountSelection();

    } catch (e) {
      // Handle errors
      print('Error signing in with Google: $e');
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      // Trigger the Facebook login flow
      // Intended future use: Access followed creators, Instagram (and Threads) data.
      final LoginResult result = await FlutterFacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        
        // Once signed in, return the UserCredential
        UserCredential userCredential = await _auth.signInWithCredential(credential);

         // Check if this is a new user and save data to Firestore if so
        if (userCredential.additionalUserInfo!.isNewUser) {
           if (userCredential.user != null) {
              await _saveNewUserToFirestore(userCredential.user!);
           }
        } else {
             print('Existing Facebook user signed in: ${userCredential.user!.displayName}');
        }

        print('Signed in with Facebook: ${userCredential.user!.displayName}');
         // Navigate to the next screen after successful sign-in
       _navigateToAccountSelection();

      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook login cancelled');
      } else if (result.status == LoginStatus.failed) {
        print('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      print('Error signing in with Facebook: $e');
    }
  }

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
      final OAuthProvider appleProvider = OAuthProvider('apple.com');
      final AuthCredential firebaseCredential = appleProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await _auth.signInWithCredential(firebaseCredential);

      // Check if this is a new user and save data to Firestore if so
      if (userCredential.additionalUserInfo!.isNewUser) {
         if (userCredential.user != null) {
            await _saveNewUserToFirestore(userCredential.user!);
           }
      } else {
           print('Existing Apple user signed in: ${userCredential.user!.displayName}');
      }
      
      print('Signed in with Apple: ${userCredential.user!.displayName}');
       // Navigate to the next screen after successful sign-in
       _navigateToAccountSelection();

    } catch (e) {
      print('Error signing in with Apple: $e');
       // Handle the specific error when Apple Sign-In is not supported
      if (e is PlatformException && e.code == 'NOT_SUPPORTED') {
         print('Apple Sign-In is not supported on this device.');
      }
    }
  }

  @override
  void dispose() {
    // No text controllers to dispose anymore
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Masses Social Sign Up")),
      body: Center( // Center the column
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
