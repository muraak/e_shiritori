import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum ListMode {
  NormalList,
  HintedList,
  AnswerList,
  ContinuedList,
}

@visibleForTesting
bool isHiraganaOrKatakana(String checkee) {
    final regex = RegExp(r'^[\u3040-\u309F|\u30A1-\u30FC]+$');
    return regex.hasMatch(checkee);
}

class CoreLogic {
  static final CoreLogic _instance = CoreLogic._internal();

  factory CoreLogic() {
    return _instance;
  }

  CoreLogic._internal();
  final DataAdaptor _dataAdaptor = DataAdaptor();
  int _length = 0;
  List<String> _idList = [];
  bool _hideName = true;

  Future<void> updateIdList() async {
    _idList = await _dataAdaptor.getIdList();
    _idList.sort();
  }

  static Future<File> _save(ByteData image, String name) async {
    //var bytes = await rootBundle.load('assets/$imageName.$ext');
    String tempPath = (await getExternalStorageDirectory())!.path;
    File file = File('$tempPath/$name.png');
    await file.writeAsBytes(image.buffer.asUint8List());
    return file;
  }

  bool isValidName(String name) {
    return isHiraganaOrKatakana(name);
  }

  @visibleForTesting
  String nameToId(String name) {
    // id := '[0-9][0-9][0-9]' + '_' + name
    return '${_length.toString().padLeft(3, "0")}_$name';
  }

  @visibleForTesting
  String idToName(String id) {
    final regex = RegExp(r'^([0-9][0-9][0-9])_(.*)$');
    final String name;
    try {
      final match = regex.firstMatch(id);
      name = match!.group(2)!;
    } catch (e) {
      return "？？？";
    }

    return name;
  }

  void newGame() {
    _length = 0;
    _dataAdaptor.clear();
  }

  Future<void> loadGame() async {
    setListMode(ListMode.ContinuedList);
    await update();
  }

  Future<void> addImage(ByteData image, String name) async {
    await _save(image, nameToId(name));
  }

  Future<void> update() async {
    await updateIdList();
    _length = _idList.length;
  }

  Image getImage(int index) {
    return _dataAdaptor.getImage(_idList.elementAt(index));
  }

  String _getHiddenName(String rawName) {
    return '？' * rawName.length;
  }

  String getName(int index) {
    if (getListMode() != ListMode.AnswerList) {
      return '${(index + 1)}.${_getHiddenName(idToName(_idList.elementAt(index)))}';
    } else {
      return '${(index + 1)}.${idToName(_idList.elementAt(index))}';
    }
  }

  int getLength() {
    return _length;
  }

  bool _clearRequired = false;

  void setClearRequired(bool value) {
    _clearRequired = value;
  }

  bool clearRequired() {
    return _clearRequired;
  }

  void discardPreviousImage() {
    _dataAdaptor.deleteImage(_idList.last);
  }

  ListMode _currentListMode = ListMode.NormalList;
  ListMode getListMode() {
    return _currentListMode;
  }

  void setListMode(ListMode mode) {
    _currentListMode = mode;
  }
}

class DataAdaptor {
  String _savePath = "";

  DataAdaptor() {
    getExternalStorageDirectory().then((value) => {_savePath = value!.path});
  }

  Future<List<String>> getIdList() async {
    return (await getExternalStorageDirectory())!
        .listSync()
        .map((e) => e.path)
        .toList()
        .where((element) => (p.extension(element) == '.png'))
        .toList()
        .map((e) => p.basenameWithoutExtension(e))
        .toList();
  }

  void clear() async {
    (await getExternalStorageDirectory())?.list().forEach((element) {
      element.delete();
    });
  }

  Future<File> addImage(ByteData image, String id) async {
    String tempPath = (await getExternalStorageDirectory())!.path;
    File file = File('$tempPath/$id.png');
    await file.writeAsBytes(image.buffer.asUint8List());
    return file;
  }

  void deleteImage(String id) async {
    String tempPath = (await getExternalStorageDirectory())!.path;
    File('$tempPath/$id.png').delete();
  }

  Image getImage(String id) {
    File file = File('$_savePath/$id.png');
    return Image.file(file);
  }
}
