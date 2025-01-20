import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logto_dart_sdk/logto_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Logto Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Logto Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.black,
  padding: const EdgeInsets.all(16.0),
  textStyle: const TextStyle(fontSize: 20),
);

ButtonStyle primaryButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.deepPurpleAccent,
  padding: const EdgeInsets.all(16.0),
  textStyle: const TextStyle(fontSize: 20),
);

class _MyHomePageState extends State<MyHomePage> {
  static String welcome = 'ยินดีต้อนรับสู่ Flutter Logto Demo';
  String? content;
  bool isAuthenticated = false;

  final redirectUri = 'io.logto://callback';

  final config = LogtoConfig(
    appId: '9u7hnd3gomsy4zpgr21xd',
    endpoint: 'https://ycemnq.logto.app/',
    scopes: [
      'openid',
      'profile',
      LogtoUserScope.email.value,
      LogtoUserScope.phone.value,
    ],
  );

  late LogtoClient logtoClient;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void render() async {
    if (await logtoClient.isAuthenticated) {
      var claims = await logtoClient.idTokenClaims;
      setState(() {
        content = claims!.toJson().toString().replaceAll(',', ',\n');
        isAuthenticated = true;
      });
      return;
    }
    setState(() {
      content = '';
      isAuthenticated = false;
    });
  }

  void _init() {
    logtoClient = LogtoClient(
      config: config,
      httpClient: http.Client(),
    );
    render();
  }

  Future<void> _showMyDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              style: secondaryButtonStyle,
              child: const Text('เข้าใจแล้ว'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget signInButton = TextButton(
      style: primaryButtonStyle,
      onPressed: () async {
        try {
          await logtoClient.signIn(redirectUri);
          render();
        } catch (e) {
          _showMyDialog('เกิดข้อผิดพลาด', e.toString());
        }
      },
      child: const Text('เข้าสู่ระบบ'),
    );

    Widget signOutButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        try {
          await logtoClient.signOut();
          render();
        } catch (e) {
          _showMyDialog('เกิดข้อผิดพลาด', e.toString());
        }
      },
      child: const Text('ออกจากระบบ'),
    );

    Widget getUserInfoButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        try {
          var userInfo = await logtoClient.getUserInfo();
          _showMyDialog(
            'ข้อมูลผู้ใช้',
            userInfo.toJson().toString().replaceAll(',', ',\n'),
          );
        } catch (e) {
          _showMyDialog('เกิดข้อผิดพลาด', e.toString());
        }
      },
      child: const Text('ดูข้อมูลผู้ใช้'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText(
              welcome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              child: SelectableText(
                content ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            isAuthenticated ? signOutButton : signInButton,
            if (isAuthenticated) ...[
              const SizedBox(height: 10),
              getUserInfoButton,
            ],
          ],
        ),
      ),
    );
  }
}