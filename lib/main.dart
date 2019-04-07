import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:balloon_pop/balloon-game.dart';

void main() async {
  Util fUtil = Util();
  await fUtil.fullScreen();
  await fUtil.setOrientation(DeviceOrientation.portraitUp);

  //Flame.images.loadAll(<String>['bg/backyard.png','bg/title.png']);

  BalloonGame game = BalloonGame();
  runApp(game.widget);

  TapGestureRecognizer tapper = TapGestureRecognizer();
  tapper.onTapDown = game.onTapDown;
  fUtil.addGestureRecognizer(tapper);
}