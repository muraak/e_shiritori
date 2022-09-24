import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribble/scribble.dart';

import 'package:e_shiritori/gameLogic.dart';
import 'list.dart';

void main() {
  runApp(const MyApp3());
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              child: const Text('はじめから'),
              onPressed: () {
                CoreLogic().newGame();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
              },
            ),
            ElevatedButton(
              child: const Text('つづきから'),
              onPressed: () {
                CoreLogic().loadGame();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp2()));
              },
            ),
          ],
        )));
  }
}

class MyApp3 extends StatelessWidget {
  const MyApp3({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'えしりとり',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const HomePage(title: 'えをかいてね！'),
      home: const StartPage(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const HomePage(title: 'えをかいてね！');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScribbleNotifier notifier;
  final myController = TextEditingController();

  @override
  void initState() {
    notifier = ScribbleNotifier();
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.done),
          tooltip: "Save to Image",
          onPressed: () => _inputDialog(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Scribble(
                notifier: notifier,
                drawPen: true,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildColorToolbar(context),
                    const Divider(
                      height: 32,
                    ),
                    _buildStrokeToolbar(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _inputDialog(BuildContext context) async {
    final isOK = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('タイトル'),
            content: TextField(
              decoration: const InputDecoration(hintText: "ここに入力"),
              controller: myController,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if (CoreLogic().isValidName(myController.text)) {
                    Navigator.of(context).pop(true);
                  } else {
                    // NOTE: Do nothing and let user to retry
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('「ひらがな」か「カタカナ」にしてね！'),
                          );
                      }
                    );
                  }
                },
              ),
            ],
          );
        });
    if (isOK != null && isOK) {
      notifier.renderImage().then((value) {
        CoreLogic().addImage(value, myController.text).then((value) => {
              CoreLogic().update().then((value) {
                CoreLogic().setListMode(ListMode.NormalList);
                myController.clear();
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyApp2()))
                    .then((value) => {
                          if (CoreLogic().clearRequired()) {notifier.clear()}
                        });
              })
            });
      });
    }
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return StateNotifierBuilder<ScribbleState>(
      stateNotifier: notifier,
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.widths)
            _buildStrokeButton(
              context,
              strokeWidth: w,
              state: state,
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
                color: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                border: state.map(
                  drawing: (_) => null,
                  erasing: (_) => Border.all(width: 1),
                ),
                borderRadius: BorderRadius.circular(50.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return StateNotifierBuilder<ScribbleState>(
      stateNotifier: notifier,
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUndoButton(context),
          const Divider(
            height: 4.0,
          ),
          _buildRedoButton(context),
          const Divider(
            height: 4.0,
          ),
          _buildClearButton(context),
          const Divider(
            height: 20.0,
          ),
          _buildPointerModeSwitcher(context,
              penMode:
                  state.allowedPointersMode == ScribblePointerMode.penOnly),
          const Divider(
            height: 20.0,
          ),
          _buildEraserButton(context, isSelected: state is Erasing),
          _buildColorButton(context, color: Colors.black, state: state),
          _buildColorButton(context, color: Colors.red, state: state),
          _buildColorButton(context, color: Colors.green, state: state),
          _buildColorButton(context, color: Colors.blue, state: state),
          _buildColorButton(context, color: Colors.yellow, state: state),
        ],
      ),
    );
  }

  Widget _buildPointerModeSwitcher(BuildContext context,
      {required bool penMode}) {
    return FloatingActionButton.small(
      heroTag: 'penMode',
      onPressed: () => notifier.setAllowedPointersMode(
        penMode ? ScribblePointerMode.all : ScribblePointerMode.penOnly,
      ),
      tooltip:
          "Switch drawing mode to " + (penMode ? "all pointers" : "pen only"),
      child: AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: !penMode
            ? const Icon(
                Icons.touch_app,
                key: ValueKey(true),
              )
            : const Icon(
                Icons.do_not_touch,
                key: ValueKey(false),
              ),
      ),
    );
  }

  Widget _buildEraserButton(BuildContext context, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FloatingActionButton.small(
        heroTag: 'erase',
        tooltip: "Erase",
        backgroundColor: const Color(0xFFF7FBFF),
        elevation: isSelected ? 10 : 2,
        shape: !isSelected
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
        child: const Icon(Icons.remove, color: Colors.blueGrey),
        onPressed: notifier.setEraser,
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
    required ScribbleState state,
  }) {
    final isSelected = state is Drawing && state.selectedColor == color.value;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FloatingActionButton.small(
          heroTag: 'color${color.value}',
          backgroundColor: color,
          elevation: isSelected ? 10 : 2,
          shape: !isSelected
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
          child: Container(),
          onPressed: () => notifier.setColor(color)),
    );
  }

  Widget _buildUndoButton(
    BuildContext context,
  ) {
    return FloatingActionButton.small(
      tooltip: "Undo",
      heroTag: 'undo',
      onPressed: notifier.canUndo ? notifier.undo : null,
      disabledElevation: 0,
      backgroundColor: notifier.canUndo ? Colors.blueGrey : Colors.grey,
      child: const Icon(
        Icons.undo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRedoButton(
    BuildContext context,
  ) {
    return FloatingActionButton.small(
      tooltip: "Redo",
      heroTag: 'redo',
      onPressed: notifier.canRedo ? notifier.redo : null,
      disabledElevation: 0,
      backgroundColor: notifier.canRedo ? Colors.blueGrey : Colors.grey,
      child: const Icon(
        Icons.redo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'clear',
      tooltip: "Clear",
      onPressed: notifier.clear,
      disabledElevation: 0,
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.clear),
    );
  }
}
