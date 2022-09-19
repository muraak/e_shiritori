// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:e_shiritori/gameLogic.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'item.dart';
import 'page.dart';

/// This function emulates a REST API call. You can imagine replacing its
/// contents with an actual network call, keeping the signature the same.
///
/// It will fetch a page of items from [startingIndex].
Future<ItemPage> fetchPage(int startingIndex) async {
  // We're emulating the delay inherent to making a network call.
  await Future<void>.delayed(const Duration(milliseconds: 500));
  
  final catalogLength = CoreLogic().getLength();

  // If the [startingIndex] is beyond the bounds of the catalog, an
  // empty page will be returned.
  if (startingIndex > catalogLength) {
    return ItemPage(
      items: [],
      startingIndex: startingIndex,
      hasNext: false,
    );
  }

  List<Image> imageList = [];

  for(var i =startingIndex; i < min(itemsPerPage, catalogLength - startingIndex); i++) {
    imageList.add(await CoreLogic().getImage(i));
  } 

  // The page of items is generated here.
  return ItemPage(
    items: List.generate(
        min(itemsPerPage, catalogLength - startingIndex),
        (index) => Item(
              name: CoreLogic().getName(index),
              image: imageList[index - startingIndex],
            )),
    startingIndex: startingIndex,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: startingIndex + itemsPerPage < catalogLength,
  );
}
