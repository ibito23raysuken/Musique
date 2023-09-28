import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FNR Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'TREIZE-VINGT-CREW'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusique = [
    new Musique("Orelsan", "Chant des sirenes", "assets/deux.jpg", "orelsan.mp3"),
    new Musique("FireFlght", "Unbrekabel", "assets/un.jpg", "Unbreakable.mp3")
  ];
  late AudioPlayer audioPlayer ;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  late Musique maMusiqueActuelle;
  PlayerState Statut= PlayerState.stopped;
  Duration duree= new Duration( seconds: 10);
  Duration position=new Duration(seconds: 0);
  int index=0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 30.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 3.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind, 30.5, ActionMusique.rewind),
                bouton((Statut == PlayerState.playing) ? Icons.pause:Icons.play_arrow, 40.0, (Statut == PlayerState.playing) ?ActionMusique.pause:ActionMusique.play),
                bouton(Icons.fast_forward, 30.0, ActionMusique.forward)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(Fromduration(position), 0.8),
                texteAvecStyle(Fromduration(duree),0.8)
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                activeColor: Colors.red,
                inactiveColor: Colors.white,
                min: 0.0,
                max: duree.inSeconds.toDouble(),
                onChanged: (double d){
                  setState(() {
                    Duration nouveleduration= new Duration(seconds: d.toInt());
                    position =nouveleduration;
                    audioPlayer.seek(nouveleduration);
                  });
                })
          ],
        ),
      ),
    );
  }
  IconButton bouton(IconData icone,double Taille,ActionMusique Action) {
    return new IconButton(
        icon: new Icon(icone),
        iconSize: Taille,
        color: Colors.white70,
        onPressed: () {
          switch(Action){
            case ActionMusique.play:
              print(Statut);
              play();
              break;
            case ActionMusique.pause:
              print(Statut);
              pause();
              Statut=PlayerState.stopped;
              break;
            case ActionMusique.forward:
              print("forward");
              forward();
              break;
            case ActionMusique.rewind:
              print("rewind");
              rewind();
              break;
            default:
              print("error");
              break;
          }
        }
    );
  }
  Text texteAvecStyle(String data,double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  void configurationAudioPlayer(){
    print(Statut);
    audioPlayer=new AudioPlayer();
    positionSub=audioPlayer.onPositionChanged.listen(
            (pos)=> setState(()=> position = pos)
    );
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => duree = d);
    });
    stateSubscription=audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == PlayerState.playing){
          print("ici jouer");
      }else if(state==PlayerState.stopped){
        setState(() {
          print("arreter");
        });
      }
    },onError: (message){
      print('erreur: $message');
      setState(() {
        Statut=PlayerState.stopped;
        duree=new Duration(seconds: 0);
        position=new Duration(seconds: 0);
      });
    }
    );

  }
  Future play() async{
    await audioPlayer.play(AssetSource(maMusiqueActuelle.urlSong));
    setState(() {
      Statut=PlayerState.playing;
    });
  }
  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      Statut=PlayerState.paused;
    });
  }
  void forward(){
    if(index== maListeDeMusique.length-1){
      index=0;
    }else{
      index++;
    }
    maMusiqueActuelle=maListeDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }
  void rewind(){
    if(position>Duration(seconds: 3)){
      audioPlayer.seek(new Duration(seconds: 0));
    }else{
      if(index== 0 ){
        index=maListeDeMusique.length-1;
      }else{
        index--;
      }
    }
    maMusiqueActuelle=maListeDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }
  String Fromduration(Duration duree){
    return duree.toString().split('.').first;
  }
}


enum ActionMusique{
  play,
  pause,
  forward,
  rewind
}
enum EventPlayerState{
  playing,
  stopped,
  paused
}
