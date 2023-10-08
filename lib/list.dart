// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:window_size/window_size.dart';

import 'src/catalog.dart';
import 'src/item_tile.dart';

import 'package:e_shiritori/gameLogic.dart';
import 'package:e_shiritori/main.dart';

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider<Catalog>(
  //     create: (context) => Catalog(),
  //     // child: const MaterialApp(
  //     //   title: 'いままでのえ',
  //     //   home: MyHomePage(),
  //     // ),
  //     child: const MyHomePage(),
  //   );
  // }

  // @override
  // State<StatefulWidget> createState() => MyHomePage();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Catalog>(
      create: (context) => Catalog(),
      child: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('いままでのえ'),
        automaticallyImplyLeading: false,
        actions: getActionsList(context, CoreLogic().getListMode()),
      ),
      body: Selector<Catalog, int?>(
        // Selector is a widget from package:provider. It allows us to listen
        // to only one aspect of a provided value. In this case, we are only
        // listening to the catalog's `itemCount`, because that's all we need
        // at this level.
        selector: (context, catalog) => catalog.itemCount,
        builder: (context, itemCount, child) => ListView.builder(
          reverse: true,
          // When `itemCount` is null, `ListView` assumes an infinite list.
          // Once we provide a value, it will stop the scrolling beyond
          // the last element.
          itemCount: itemCount,
          padding: const EdgeInsets.symmetric(vertical: 18),
          itemBuilder: (context, index) {
            // Every item of the `ListView` is individually listening
            // to the catalog.
            var catalog = Provider.of<Catalog>(context);

            // Catalog provides a single synchronous method for getting
            // the current data.
            var item = catalog.getByIndex(index);

            if (item.isLoading) {
              return const LoadingItemTile();
            }

            return ItemTile(item: item);
          },
        ),
      ),
    );
  }

  List<Widget> getActionsList(BuildContext context, ListMode mode) {
    if (mode == ListMode.AnswerList) {
      return [
        TextButton(
          onPressed: () {
            CoreLogic().setListMode(ListMode.NormalList);
            Navigator.pop(context);
          },
          child: const Text(
            'もどる',
            style: TextStyle(color: Colors.white),
          ),
        ),
        // TextButton(
        //   onPressed: () {
        //     CoreLogic().setClearRequired(true);
        //     Navigator.of(context).pop();
        //   },
        //   child: const Text(
        //     'つづける',
        //     style: TextStyle(color: Colors.white),
        //   ),
        // ),
      ];
    } else if (mode == ListMode.ContinuedList) {
      return [
        TextButton(
          onPressed: () {
            CoreLogic().setClearRequired(true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
          },
          child: const Text(
            'すすむ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () {
            CoreLogic().setClearRequired(false);
            CoreLogic().discardPreviousImage();
            Navigator.of(context).pop();
          },
          child: const Text(
            'もどる',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            CoreLogic().setClearRequired(true);
            Navigator.of(context).pop();
          },
          child: const Text(
            'すすむ',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            CoreLogic().setListMode(ListMode.AnswerList);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyApp2()));
          },
          child: const Text(
            'こたえあわせ',
            style: TextStyle(color: Colors.white),
          ),
        )
      ];
    }
  }
}
