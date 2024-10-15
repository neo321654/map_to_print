import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Dock(),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  @override
  _DockState createState() => _DockState();
}

class _DockState extends State<Dock> {
  List<IconData> items = [
    Icons.home,
    Icons.search,
    Icons.notifications,
    Icons.person,
  ];

  int? draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Draggable(feedback: Text('1'),
            child: Text('1')),
            Row(
              mainAxisSize: MainAxisSize.max,

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                return Draggable<IconData>(
                  onDragStarted: () {
                    print('onDragStarted');
                  },
                  onDragEnd: (details) {
                    print('onDragEnd $details');
                  },
                  // affinity: ,
                  // dragAnchorStrategy: ,
                  // feedbackOffset: ,
                  // dragAnchorStrategy: ,

                  // data: Icon(Icons.import_contacts),
                  data: items[index],
                  feedback: Material(
                    color: Colors.transparent,
                    child: Icon(
                      items[index],
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  childWhenDragging: Container(width: 50,height: 50,color: Colors.red,),
                  child: DragTarget<IconData>(
                    onMove:(m){

                    m;

                    } ,
                    onLeave: (l){

                      l;

                    },
                    onAcceptWithDetails: (data) {
                      //   var d = data;

                      setState(() {
                        int oldIndex = items.indexOf(data.data);
                        // Меняем местами иконки
                        IconData temp = items[oldIndex];
                        items[oldIndex] = items[index];
                        items[index] = temp;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {



                      print('candidateData $candidateData');
                      print('rejectedData $rejectedData');


                      if( candidateData.isNotEmpty)return
                        Positioned(
                          left:120,
                          right: 100,
                          child: Container(
                            color: Colors.blue,
                          // duration: const Duration(milliseconds: 5300),
                          height: draggedIndex == index ? 70 : 50,
                          width: draggedIndex == index ? 70 : 50,
                          child: IconButton(
                            icon: Icon(items[index]),
                            iconSize: 40,
                            onPressed: () {},
                          ),
                                                ),
                        );

                      return Container(
                        // duration: const Duration(milliseconds: 5300),
                        height: draggedIndex == index ? 70 : 50,
                        width: draggedIndex == index ? 70 : 50,
                        child: IconButton(
                          icon: Icon(items[index]),
                          iconSize: 40,
                          onPressed: () {},
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}