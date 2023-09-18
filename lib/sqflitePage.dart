import 'package:flutter/material.dart';

import 'SQLHelper.dart';
import 'Utility.dart';
import 'sqfLiteBottomSheet.dart';

class SqFlitePersonMode {
  int? id;
  String? name;
  String? photo;
  int? age;
  SqFlitePersonMode({this.age, this.id, this.name, this.photo});
}

typedef void RefreshPage();

class SqflitePage extends StatefulWidget {
  const SqflitePage({Key? key}) : super(key: key);

  @override
  _SqflitePageState createState() => _SqflitePageState();
}

class _SqflitePageState extends State<SqflitePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  List<SqFlitePersonMode> listPersonSqflite = [];

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  bool isLoading = false;

  @override
  void initState() {
    //addSuplie();
    getAllData();
    super.initState();
  }

  Future addSupplier() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Mustaq',
      DatabaseHelper.columnAge: '25'
    };

    final allRow = await dbHelper.getAllSupplier();
    for (var element in allRow) {
      print('ALL ROW - - - > ${element['name']}');
    }
  }

  Future getAllData() async {
    isLoading = true;
    final allRows = await dbHelper.getAll();

    for (var element in allRows) {
      print('$element');
      listPersonSqflite.add(SqFlitePersonMode(
          age: int.parse('${element['age']}'),
          id: element['_id'],
          name: '${element['name']}',
          photo: '${element['photo']}'));
    }
    setState(() {
      isLoading = false;
    });
  }

  Future _showForm(int? id, List<SqFlitePersonMode> listPersonSqflite) async {
    print("User id->$id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQ-flite"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? ListView()
          : ListView.builder(
              shrinkWrap: true,
              key: listKey,
              itemCount: listPersonSqflite.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      leading: listPersonSqflite[index].photo != null
                          ? Utility.imageFromBase64String(
                              listPersonSqflite[index].photo.toString())
                          : null,
                      title: Text("${listPersonSqflite[index].name}"),
                      subtitle: Text("${listPersonSqflite[index].age}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                if (listPersonSqflite[index].id != null) {
                                  final objectSingle =
                                      listPersonSqflite.firstWhere((element) =>
                                          element.id ==
                                          listPersonSqflite[index].id);
                                  _titleController.text =
                                      objectSingle.name.toString();
                                  _ageController.text =
                                      objectSingle.age.toString();
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SqfLiteBottomSheet(
                                                id: listPersonSqflite[index].id,
                                                listPersonSqflite:
                                                    listPersonSqflite)));
                              },
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  dbHelper.delete(listPersonSqflite[index].id!);
                                  setState(() {
                                    listPersonSqflite.clear();
                                    getAllData();
                                  });
                                }),
                          ],
                        ),
                      )),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SqfLiteBottomSheet(
                      id: null, listPersonSqflite: listPersonSqflite)));
        },
      ),
    );
  }
}
