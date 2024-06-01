import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:final_bnsp/widgets/image_picker_modal.dart';
import 'package:final_bnsp/widgets/location_picker.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

class AddDataPage extends StatefulWidget {
  const AddDataPage({Key? key}) : super(key: key);

  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  File _file = File('');

  Future<bool> _simpan() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.100.129:8000/api/api-datadiri'), // Endpoint API Laravel Anda
      );

      request.fields['name'] = _nameController.text;
      request.fields['birth'] = _dateController.text;
      request.fields['location'] = _locationController.text;

      if (_file.path.isNotEmpty) {
        final mimeTypeData =
            lookupMimeType(_file.path, headerBytes: [0xFF, 0xD8])?.split('/');
        final fileStream = http.ByteStream(_file.openRead());
        final length = await _file.length();

        request.files.add(
          http.MultipartFile(
            'image', // Nama parameter sesuai dengan API Laravel
            fileStream,
            length,
            filename: _file.path.split('/').last,
            contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
          ),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $respStr');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(respStr);
        return responseData['message'] ==
            'Data created successfully'; // Sesuaikan dengan respon dari API Laravel
      } else {
        print('Error status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void imagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ImagePickerModal();
        }).then((value) {
      if (value != null) {
        setState(() {
          _file = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data'),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Tambah Data Disini!"),
                GestureDetector(
                  onTap: () {
                    imagePicker(context);
                  },
                  child: Container(
                    margin: EdgeInsets.all(20),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _file.path == ''
                          ? Image.asset(
                              'assets/icons8-upload-photo-100.png',
                            )
                          : Image.file(
                              _file,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Nama",
                      labelText: "Nama",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Nama tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Tanggal Lahir",
                      labelText: "Tanggal Lahir",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Tanggal lahir tidak boleh kosong";
                      }
                      return null;
                    },
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
          
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        });
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _locationController,
                    maxLines: 4,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Lokasi",
                      labelText: "Lokasi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Lokasi tidak boleh kosong";
                      }
                      return null;
                    },
                    onTap: () async {
                      final String? address = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LocationPicker()),
                      );
                      if (address != null) {
                        setState(() {
                          _locationController.text = address;
                        });
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      _simpan().then((value) {
                        final snackBar = SnackBar(
                          content: Text(value
                              ? 'Data berhasil disimpan'
                              : 'Data gagal disimpan'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
          
                        if (value) {
                          Navigator.of(context).pop(true);
                        }
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Simpan Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
