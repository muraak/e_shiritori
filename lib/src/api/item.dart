// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class Item {

  final String name;
  final Widget image;

  Item({
    required this.image,
    required this.name,
  });

  Item.loading() : this(image: FlutterLogo(), name: '...',);

  bool get isLoading => name == '...';
}
