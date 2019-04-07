import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/gestures.dart';
import 'package:vibrate/vibrate.dart';

enum View {home,playing,lost}
double sWidth, sHeight;
int score = 0;

class BalloonGame extends Game {
  List<Balloon> balloons;
  Random r;
  Background bg;
  Play p;
  Teach t;
  View view = View.home;

  BalloonGame() {
    initialize();
  }

  void initialize() async {
    balloons = List<Balloon>();
    r = Random();
    resize(await Flame.util.initialDimensions());
    bg = Background(this);
    p = Play(this);
    t = Teach(this);
  }

  void spawnBalloon() {
    double x = 0.2*sWidth + r.nextDouble() * (0.6*sWidth);
    double y = 0.2*sHeight + r.nextDouble() * (0.6*sHeight);
    balloons.add(Balloon(this,x,y));
  }

  void render(Canvas c) {
    bg.render(c);
    if (view == View.home) {
      p.render(c);
      t.render(c);
    } else {
      balloons.forEach((Balloon b) => b.render(c));
    }
  }

  void reset() {
    score = 0;
    view = View.home;
  }

  void update(double t) {
    print(view.toString());
    bg.update(t);
    if (view == View.playing) {
      balloons.forEach((Balloon b) {
        b.update(t);
        if (b.isBurst) balloons.remove(b);
        if (b.tooFat) {
          Vibrate.feedback(FeedbackType.error);
          balloons.clear();
          view = View.lost;
        }
      });
      if(balloons.length < 4) spawnBalloon();
    }
  }

  void resize(Size size) {
    sWidth = size.width;
    sHeight = size.height;
  }

  void onTapDown(TapDownDetails d) {
    if (view == View.home)
      if(p.r.contains(d.globalPosition)) p.onTapDown();
      if(t.r1.contains(d.globalPosition)) t.onTapDown();
    if (view == View.playing) {
      balloons.forEach((Balloon b) {
        if (b.b.contains(d.globalPosition)) b.onTapDown();
      });
    }
    if (view == View.lost) {
      reset();
    }
  }
}

class Play {
  final BalloonGame game;
  Rect r;
  Sprite play;

  Play(this.game) {
    r = Offset(sWidth *.22,sHeight *.75) & const Size(200,100);
    play = Sprite('ui/s.png');
  }

  void render(Canvas c) => play.renderRect(c,r);
  void onTapDown() => game.view = View.playing;
}

class Teach {
  final BalloonGame game;
  Rect r1, r2;
  Sprite t1, t2;
  TextConfig text = TextConfig(fontSize: 20, fontFamily: 'Bowlby One');
  bool t = false;

  Teach(this.game) {
    r1 = Offset(sWidth *.22,sHeight *.57) & const Size(200,80);
    r2 = Offset(sWidth *.15,sHeight *.50) & const Size(250,150);
    t1 = Sprite('ui/p.png');
    t2 = Sprite('ui/i.png');
  }

  void render(Canvas c) => (t == true) ? t2.renderRect(c,r2) : t1.renderRect(c,r1);
  void onTapDown() => t = (t) ? false : true;
}

class Background {
  final BalloonGame game;
  Rect r;
  Sprite bg, bg2;
  TextConfig s = TextConfig(fontSize: 30, fontFamily: 'Bowlby One');
  TextConfig again = TextConfig(fontSize: 20, fontFamily: 'Bowlby One');
  Background(this.game) {
    bg = Sprite('bg/bg.jpg');
    bg2 = Sprite('bg/bg2.png');
    r = Offset.zero & Size(sWidth,sHeight);
  }

  void render(Canvas c) {
    (game.view == View.home) ? bg.renderRect(c,r) : bg2.renderRect(c,r);
    if(game.view == View.playing) s.render(c,"SCORE: " + score.toString(),Position(sWidth/25,sHeight/40));
    if(game.view == View.lost) {
      s.render(c,"YOUR SCORE: " + score.toString(),Position(sWidth/11,sHeight/2.5));
      again.render(c,"Tap anywhere to try again!",Position(sWidth/13,sHeight/2.1));
    }
  }

  void update(double t) {}
}

class Balloon {
  final BalloonGame game;
  bool isBurst = false;
  bool tooFat = false;
  RRect b;
  Paint p = Paint();

  Balloon(this.game, double x, double y) {
    b = RRect.fromRectXY(Rect.fromLTWH(x,y,25,25),25,25);
    p.color = RandomColor().randomColor();
  }

  void render(Canvas c) {
    c.drawRRect(b, p);
  }

  void update(double t) {
    b = b.inflate(0.75 + score/500);
    if (b.top < 0 || b.bottom > sHeight || b.left < 0 || b.right > sWidth) tooFat = true;
  }

  void onTapDown() {
    isBurst = true;
    score += 1;
    Vibrate.feedback(FeedbackType.medium);
  }
}
