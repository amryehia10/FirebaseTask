import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_auth/firestore_service.dart';
import 'package:user_auth/screens/login_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showNoteBox(context);
          },
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    const Text(
                      "Hello these are your notes",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(onPressed: ()async{
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context, MaterialPageRoute<void>(builder: (((BuildContext context) => const Login()))));
                    }, icon: Icon(Icons.logout))
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FireStoreService.getNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasData) {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.isEmpty ? 1: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("No notes"),
                              );
                            } else {
                              var note = snapshot.data!.docs[index];
                              return Card(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            note['noteTitle'] ?? "",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                              onPressed: () => FireStoreService.deleteNote(noteId: note.id),
                                              icon: const Icon(Icons.delete)),
                                          IconButton(
                                              onPressed: () => showNoteBox(
                                                  context,
                                                  oldTitle: note['noteTitle'],
                                                  noteId: note.id,
                                                  oldBody: note['noteBody']),
                                              icon: const Icon(Icons.settings))
                                        ],
                                      ),
                                      Text(
                                        note['noteBody'] ?? "",
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return const Text("something went wrong");
                      }
                    })
              ],
            ),
          ),
        ));
  }
}

Future<dynamic> showNoteBox(BuildContext context,
    {String? oldTitle, String? oldBody, String? noteId}) {
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController bodyTextEditingController = TextEditingController();

  if (oldTitle != null && oldBody != null && noteId != null) {
    titleTextEditingController.text = oldTitle;
    bodyTextEditingController.text = oldBody;
  }

  late String addOrEdit;

  if (oldTitle != null && oldBody != null && noteId != null) {
    addOrEdit = 'Edit';
  } else {
    addOrEdit = 'Add';
  }

  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Text('$addOrEdit your note'),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: "Title"),
                  controller: titleTextEditingController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    decoration: const InputDecoration(hintText: "SubTitle"),
                    controller: bodyTextEditingController),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (oldTitle != null && oldBody != null && noteId != null) {
                    FireStoreService.updateNote(
                        noteId: noteId,
                        newBody: bodyTextEditingController.text,
                        newTitle: titleTextEditingController.text);
                  } else {
                    await FireStoreService.addNote(
                        body: bodyTextEditingController.text,
                        title: titleTextEditingController.text);
                  }
                  Navigator.pop(context);
                },
                child: Text('$addOrEdit Note'),
              )
            ],
          ));
}
