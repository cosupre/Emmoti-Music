import 'package:emoti_music/database/database.dart';
import 'package:emoti_music/models/track.dart';
import 'package:flutter/material.dart';

class TrackDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createTrack(CustomTrack track) async {
    final db = await dbProvider.database;

    var result = await db.insert(trackTABLE, track.toDatabase());
    return result;
  }

  Future<List<CustomTrack>> getTracks({@required String playlistId}) async {
    final db = await dbProvider.database;

    var result = await db.query(trackTABLE, where: 'playlistId = ?', whereArgs: [playlistId]);
    return result.map<CustomTrack>((e) => CustomTrack.fromDatabase(e)).toList();
  }

  Future<int> updateTrack(CustomTrack track) async {
    final db = await dbProvider.database;

    var result = await db.update(trackTABLE, track.toDatabase(), where: 'id = ?', whereArgs: [track.id]);
    return result;
  }

  Future<int> deleteTrack(String id) async {
    final db = await dbProvider.database;

    var result = await db.delete(trackTABLE, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future<bool> exists(String id) async {
    final db = await dbProvider.database;
    var result = await db.query(trackTABLE, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    await db.delete(trackTABLE);
  }
}
