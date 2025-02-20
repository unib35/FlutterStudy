import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Firebase Firestore Emulator 사용
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'counter';
  final String _documentId = 'my_counter_id';

  /// **Firestore에 카운터 값이 없으면 0으로 초기화하고 증가시킴**
  Future<void> _incrementCounter() async {
    final docRef = _firestore.collection(_collectionName).doc(_documentId);

    try {
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // 문서가 없으면 초기값 1로 설정
        await docRef.set({'counter': 1});
        print('✅ Firestore 문서 생성: counter = 1');
      } else {
        // 문서가 있으면 기존 값에서 1 증가
        await docRef.update({'counter': FieldValue.increment(1)});
        print('✅ Firestore 문서 업데이트: counter +1');
      }
    } catch (e) {
      print('❌ Firestore 업데이트 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore
                      .collection(_collectionName)
                      .doc(_documentId)
                      .snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  debugPrint(snapshot.error.toString());
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('Counter does not exist');
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || !data.containsKey('counter')) {
                  return const Text('Counter does not exist');
                }

                final counter = data['counter'] as int;

                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineLarge,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
