import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _displayMode = DisplayMode.cubes;

  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    light: vector.Vector3(-0.5, -0.5, 0.5),
  );

  Future<List<Face3D>> _loadMesh() async {
    final objText = await rootBundle.loadString('ff.obj');
    return ObjParser().parse(objText);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: SafeArea(
                child: Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children: [
              Expanded(
                child: FutureBuilder<List<Face3D>>(
                  future: _loadMesh(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return DiTreDiDraggable(
                          controller: _controller,
                          child: DiTreDi(
                            figures: snapshot.data!,
                            controller: _controller,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ), 
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Drag to rotate. Scroll to zoom"),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: DisplayMode.values
                    .map((e) => Material(
                          child: InkWell(
                            onTap: () => setState(() => _displayMode = e),
                            child: ListTile(
                              title: Text(e.title),
                              leading: Radio<DisplayMode>(
                                value: e,
                                groupValue: _displayMode,
                                onChanged: (e) => setState(
                                  () => _displayMode = e ?? DisplayMode.cubes,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
            )]))));
  }
}

enum DisplayMode {
  cubes,
  wireframe,
  points,
}

extension DisplayModeExtension on DisplayMode {
  String get title {
    switch (this) {
      case DisplayMode.cubes:
        return 'Cubes';
      case DisplayMode.wireframe:
        return 'Wireframe';
      case DisplayMode.points:
        return 'Points';
      default:
        return '';
    }
  }
}

