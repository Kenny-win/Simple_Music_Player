import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class PlayMusic extends StatefulWidget {
  const PlayMusic({ Key? key }) : super(key: key);

  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  var isPlay = false;
  var isPause = false;

  int seek = 0;
  int maxduration = 0;
  int maxplayDurSec = 0;
  int maxplayDurMin = 0;
  int currentpos = 0;
  int sec = 0;
  String currentpostlabel = "00:00";
  String audioasset = "assets/hewei.mp3";
  late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {

       ByteData bytes = await rootBundle.load(audioasset); //load music dari assets/
       audiobytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
       //convert ByteData to Uint8List
      
       player.onDurationChanged.listen((Duration d) { //ambil durasi music
           maxplayDurSec = (d.inSeconds%60).floor();
           maxplayDurMin = d.inMinutes;
           maxduration = d.inSeconds;
           print(maxduration);

           setState(() {
             
           });
       });

      player.onAudioPositionChanged.listen((Duration  p){
        currentpos = p.inMilliseconds; //tampung posisi waktu sekarang ketika music sedang berjalan
        sec = p.inSeconds;
          //durasi waktu yang berjalan dalam jam:menit:detik
          int shours = Duration(milliseconds:currentpos).inHours;
          int sminutes = Duration(milliseconds:currentpos).inMinutes;
          int sseconds = Duration(milliseconds:currentpos).inSeconds;

          int rhours = shours;
          int rminutes = sminutes - (shours * 60);
          int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

          currentpostlabel = "$rhours:$rminutes:$rseconds";
          print(sec);
          setState(() {
             //refresh the UI
          });
      });

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    Widget playButton({
      required Function() onPressed 
    }){
      return VxBox(
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.play_circle_outline_rounded, size: 50, color: Colors.purple,),
        )
      ).roundedFull.makeCentered();
    }

    Widget pauseStopButton({
      required Function() onPausePressed,
      required Function() onStopPressed
    }){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VxBox(
            child: IconButton(
              onPressed: onPausePressed,
              icon: Icon(
                isPause?Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded, size: 50, color: Colors.purple,),
            )
          ).roundedFull.makeCentered(),
          VxBox(
            child: IconButton(
              onPressed: onStopPressed,
              icon: const Icon(Icons.stop_circle_outlined, size: 50, color: Colors.purple,),
            )
          ).roundedFull.makeCentered()
        ],
      );
    }


    return Container(
      width: MediaQuery.of(context).size.width,
      child: [
        Slider(
          divisions: 200,
          onChanged: (val){
            seek = val.toInt();
            player.seek(Duration(seconds: seek));
            
          },
          value: sec.toDouble(),
          min: 0,
          max: maxduration.toDouble(),
          activeColor: Colors.purple,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              currentpostlabel.toString().text.maxFontSize(14).minFontSize(10).make(),
              "$maxplayDurMin:$maxplayDurSec".text.black.maxFontSize(14).minFontSize(10).make(),
            ],
          )
        ),
        Container(
          width: double.infinity,
          child: 
          isPlay && sec != maxduration? pauseStopButton(
            onPausePressed: () async {
              await player.pause();
              setState(() {
                isPause = !isPause;
                isPause? player.pause(): player.resume();
                
              });
            },
            onStopPressed: ()async{
              await player.stop();
              setState(() {
                isPlay = false;
                isPause = false;
                sec = 0;
              });
            }
          ) : 
          playButton(
            onPressed: () async {
              await player.playBytes(audiobytes);
              setState(() {
                isPlay = true;
              });
            }
          ),
        )
      ].column(
        crossAlignment: CrossAxisAlignment.center
      )
    );
  }
}