
import 'package:hive_flutter/hive_flutter.dart';

part '__data.g.dart';


@HiveType(typeId: 0)
class Note extends HiveObject{

    // @HiveField(1) int? id;
    @HiveField(1) late int id;
    @HiveField(2) String value = '';

    @HiveField(3) DateTime? lastTime;
    @HiveField(4) Category? category;

    DateTime? _time;

    DateTime get time {
        _time = _time ?? DateTime.fromMillisecondsSinceEpoch(id~/1000);
        return _time!;
    }

    Note({int? id, this.value = '', DateTime? lastTime}){
        this.id = id ?? DateTime.now().microsecondsSinceEpoch;
        lastTime = lastTime ?? time;
    }
}


@HiveType(typeId: 1)
class Category extends HiveObject{
    @HiveField(1) String name;

    Category(this.name);
}