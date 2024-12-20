import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2x2 Rubik\'s Cube',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CubeScreen(),
    );
  }
}

class CubeState {
  List<List<Color>> faces = [
    [Colors.red, Colors.red, Colors.red, Colors.red], // Front
    [Colors.blue, Colors.blue, Colors.blue, Colors.blue], // Left
    [Colors.green, Colors.green, Colors.green, Colors.green], // Right
    [Colors.yellow, Colors.yellow, Colors.yellow, Colors.yellow], // Back
    [Colors.orange, Colors.orange, Colors.orange, Colors.orange], // Top
    [Colors.white, Colors.white, Colors.white, Colors.white], // Bottom
  ];

  /// Rotates the face and adjacent edges.
  void rotateFace(int faceIndex, {bool clockwise = true}) {
    _rotateFace(faceIndex, clockwise);
    switch (faceIndex) {
      case 4: // Top
        _rotateEdges([
          0,
          1,
          3,
          2
        ], [
          [0, 1],
          [0, 1],
          [0, 1],
          [0, 1]
        ], clockwise);
        break;
      case 5: // Bottom
        _rotateEdges([
          0,
          2,
          3,
          1
        ], [
          [2, 3],
          [2, 3],
          [2, 3],
          [2, 3]
        ], clockwise);
        break;
      case 1: // Left
        _rotateEdges([
          0,
          4,
          3,
          5
        ], [
          [0, 2],
          [0, 2],
          [3, 1],
          [0, 2]
        ], clockwise);
        break;
      case 2: // Right
        _rotateEdges([
          0,
          5,
          3,
          4
        ], [
          [1, 3],
          [1, 3],
          [2, 0],
          [1, 3]
        ], clockwise);
        break;
      case 0: // Front
        _rotateEdges([
          4,
          1,
          5,
          2
        ], [
          [2, 3],
          [3, 1],
          [0, 1],
          [0, 2]
        ], clockwise);
        break;
      case 3: // Back
        _rotateEdges([
          4,
          2,
          5,
          1
        ], [
          [3, 1],
          [2, 0],
          [2, 3],
          [0, 2]
        ], clockwise);
        break;
    }
  }

  /// Rotates a single face.
  void _rotateFace(int faceIndex, bool clockwise) {
    List<Color> tempFace = [...faces[faceIndex]];
    faces[faceIndex] = clockwise
        ? [tempFace[2], tempFace[0], tempFace[3], tempFace[1]]
        : [tempFace[1], tempFace[3], tempFace[0], tempFace[2]];
  }

  /// Rotates edges between adjacent faces.
  void _rotateEdges(
      List<int> edgeFaces, List<List<int>> edgeIndices, bool clockwise) {
    List<List<Color>> temp = edgeIndices.map((indices) {
      return indices
          .map((i) => faces[edgeFaces[clockwise ? 3 : 0]][i])
          .toList();
    }).toList();

    for (int i = (clockwise ? 3 : 0);
        clockwise ? i > 0 : i < 3;
        i += (clockwise ? -1 : 1)) {
      for (int j = 0; j < edgeIndices[i].length; j++) {
        faces[edgeFaces[i]][edgeIndices[i][j]] =
            faces[edgeFaces[(i + (clockwise ? -1 : 1)) % 4]]
                [edgeIndices[(i + (clockwise ? -1 : 1)) % 4][j]];
      }
    }

    for (int j = 0; j < edgeIndices[clockwise ? 0 : 3].length; j++) {
      faces[edgeFaces[clockwise ? 0 : 3]][edgeIndices[clockwise ? 0 : 3][j]] =
          temp[clockwise ? 3 : 0][j];
    }
  }
}

class CubeScreen extends StatefulWidget {
  const CubeScreen({Key? key}) : super(key: key);

  @override
  _CubeScreenState createState() => _CubeScreenState();
}

class _CubeScreenState extends State<CubeScreen> {
  CubeState cube = CubeState();

  Widget buildFace(String label, List<Color> faceColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        SizedBox(
          height: 100,
          width: 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              color: faceColors[index],
              alignment: Alignment.center,
              child: Transform(
                transform: Matrix4.rotationY(0), // Keeps text fixed
                alignment: Alignment.center,
                child: Text(
                  'F$index',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2x2 Rubik\'s Cube'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFace('Top', cube.faces[4]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildFace('Left', cube.faces[1]),
                    buildFace('Front', cube.faces[0]),
                    buildFace('Right', cube.faces[2]),
                  ],
                ),
                buildFace('Back', cube.faces[3]),
                buildFace('Bottom', cube.faces[5]),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(4, clockwise: true);
                    });
                  },
                  child: const Text('Rotate Top Clockwise'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(4, clockwise: false);
                    });
                  },
                  child: const Text('Rotate Top Counterclockwise'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(5, clockwise: true);
                    });
                  },
                  child: const Text('Rotate Bottom Clockwise'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(5, clockwise: false);
                    });
                  },
                  child: const Text('Rotate Bottom Counterclockwise'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(1, clockwise: true);
                    });
                  },
                  child: const Text('Rotate Left Clockwise'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cube.rotateFace(1, clockwise: false);
                    });
                  },
                  child: const Text('Rotate Left Counterclockwise'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
