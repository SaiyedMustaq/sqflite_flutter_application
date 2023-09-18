import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sqflite_application/sqflitePage.dart';
import 'package:image_picker/image_picker.dart';

import 'SQLHelper.dart';
import 'Utility.dart';

class SqfLiteBottomSheet extends StatefulWidget {
  SqfLiteBottomSheet({Key? key, this.id, required this.listPersonSqflite});
  final int? id;
  List<SqFlitePersonMode> listPersonSqflite;

  @override
  State<SqfLiteBottomSheet> createState() => _SqfLiteBottomSheetState();
}

class _SqfLiteBottomSheetState extends State<SqfLiteBottomSheet> {
  File? file;
  int? id;
  late List<int> bytes;
  late Uint8List bytesImage;
  late String imageUrl;
  TextEditingController ageController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    if (widget.id != null) {
      final objectSingle = widget.listPersonSqflite
          .firstWhere((element) => element.id == widget.id);
      nameController.text = objectSingle.name.toString();
      ageController.text = objectSingle.age.toString();
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Center(
                child: Stack(
                  children: [
                    file == null
                        ? const CircleAvatar(
                            radius: 70.0,
                            child: ClipRect(clipBehavior: Clip.hardEdge))
                        : CircleAvatar(
                            radius: 70.0, backgroundImage: FileImage(file!)),
                    Positioned(
                      bottom: 2.0,
                      right: 2.0,
                      child: InkWell(
                        onTap: () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((imgFile) async {
                            file = File(imgFile!.path.toString());
                            imageUrl = Utility.base64String(
                                await imgFile.readAsBytes());
                          }).then((value) => setState(() {}));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            TextField(
              controller: nameController,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.black),
              decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.black),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Age',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.id == null) {
                  Map<String, dynamic> row = {
                    DatabaseHelper.columnName: nameController.text,
                    DatabaseHelper.columnAge: ageController.text,
                    DatabaseHelper.columnPhoto: imageUrl
                  };
                  final id = await dbHelper.insert(row);
                  print('inserted row id: $id');
                } else {
                  Map<String, dynamic> row = {
                    DatabaseHelper.columnId: widget.id,
                    DatabaseHelper.columnName: nameController.text,
                    DatabaseHelper.columnAge: ageController.text,
                    DatabaseHelper.columnPhoto: imageUrl
                  };
                  final rowsAffected = await dbHelper.update(row);
                  print('Update row: $rowsAffected');
                }

                Navigator.pop(context, true);
                setState(() {
                  nameController.clear();
                  ageController.clear();
                });
              },
              child: Text(widget.id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }
}
