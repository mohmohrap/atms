import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        plotName TEXT,
        houseName TEXT,
        tenantName TEXT,
        
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        
      )
      """);
    //selectedMonths TEXT, phone INTEGER,
  }

// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'tmsapp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(
    String plotName,
    String? houseName,
    String tenantName,
    /*int? phone*/ /*, List<int> selectedMonths*/
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'plotName': plotName,
      'houseName': houseName,
      'tenantName': tenantName,
      //'phone': phone,
      /*'selectedMonths':
          selectedMonths.isNotEmpty ? selectedMonths.join(',') : '',*/
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    final result = await db.query(
      'items',
      orderBy: 'plotName, houseName',
    );
    /* for (var item in result) {
      if (item['selectedMonths'] != null && item['selectedMonths'] != '') {
        item['selectedMonths'] = (item['selectedMonths'] as String)
            .split(',')
            .map((e) => int.parse(e))
            .toList();
      } else {
        item['selectedMonths'] = []; //make empty list if no months are selected
      }
    }*/
    return result;
  }

  // Read a single item by plotName
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
    int id,
    String plotName,
    String? houseName,
    String tenantName,
    /*int? phone*/ /*, List<int> selectedMonths*/
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'plotName': plotName,
      'houseName': houseName,
      'tenantName': tenantName,
      //'phone': phone,
      /*'selectedMonths':
          selectedMonths.isNotEmpty ? selectedMonths.join(',') : '',*/
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deletion: $err");
    }
  }
}
