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


  // The page of items is generated here.
  return ItemPage(
    items: List.generate(
        min(itemsPerPage, catalogLength - startingIndex),
        (index) => Item(
              name: CoreLogic().getName(index + startingIndex),
              image: CoreLogic().getImage(index + startingIndex),
            )),
    startingIndex: startingIndex,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: startingIndex + itemsPerPage < catalogLength,
  );
}
