import 'dart:convert';

import 'package:final_bnsp/pages/add_data_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _listData = [];

  Future _getData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.129:8000/api/api-datadiri'),
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Pastikan data memiliki key 'data' dan merupakan list
        if (data.containsKey('data') && data['data'] is List) {
          setState(() {
            _listData = data['data'];
          });
        } else {
          print('Unexpected data format');
        }
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Profil'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _listData.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(_listData[index]['name'] ?? ""),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tanggal Lahir: ${_listData[index]['birth'] ?? ""}"),
                    Text("Alamat: ${_listData[index]['location'] ?? ""}"),
                  ],
                ),
                trailing: _listData[index]['image'] != null
                    ? Image.network(
                        'http://192.168.100.129:8000/storage/images/${_listData[index]['image']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDataPage(),
            ),
          );

          if (result == true) {
            _getData(); // Panggil _getData() untuk memperbarui data
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
