// Step 5: Masses Social Contentclass MassesSocialContentScreen extends StatelessWidget {  @override  Widget build(BuildContext context) {    return Scaffold(      appBar: AppBar(title: Text("Masses Social Content")),      body: Center(        child: Text("Exclusive content hosted by Masses Social."),      ),    );  }}
import 'package:flutter/material.dart';

class MassesSocialContentScreen extends StatelessWidget {
  const MassesSocialContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masses Social Content')),
      body: const Center(child: Text('Masses Social Content Screen')),
    );
  }
}
