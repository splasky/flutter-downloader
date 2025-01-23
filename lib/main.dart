import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ZipDownloaderScreen(),
    );
  }
}

class ZipDownloaderScreen extends StatefulWidget {
  @override
  _ZipDownloaderScreenState createState() => _ZipDownloaderScreenState();
}

class _ZipDownloaderScreenState extends State<ZipDownloaderScreen> {
  TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _downloadZipFile() async {
    setState(() {
      _isLoading = true;
    });

    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User ID cannot be empty")));
      return;
    }

    final url = Uri.parse("https://your-backend.com/download?userId=$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final file = File("${dir!.path}/downloaded.zip");
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File downloaded: ${file.path}")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to download file")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ZIP File Downloader")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: "Enter User ID"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _downloadZipFile,
                    child: Text("Submit"),
                  ),
          ],
        ),
      ),
    );
  }
}
