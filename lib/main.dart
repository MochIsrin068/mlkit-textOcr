import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

void main(){
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    )
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  File _imageFile;
  String _mlResult = '<no result>'; 


  Future<bool> _pickImage() async { 
      setState(() => this._imageFile = null); 
      final File imageFile = await showDialog<File>( 
        context: context, 
        builder: (ctx) => SimpleDialog( 
          children: <Widget>[ 
            ListTile( 
              leading: Icon(Icons.camera_alt), 
              title: Text('Take picture'), 
              onTap: () async { 
                final File imageFile = 
                    await ImagePicker.pickImage(source: ImageSource.camera); 
                Navigator.pop(ctx, imageFile); 
              }, 
            ), 
            ListTile( 
              leading: Icon(Icons.image), 
              title: Text('Pick from gallery'), 
              onTap: () async { 
                try { 
                  final File imageFile = 
                      await ImagePicker.pickImage(source: ImageSource.gallery); 
                  Navigator.pop(ctx, imageFile); 
                } catch (e) { 
                  print(e); 
                  Navigator.pop(ctx, null); 
                } 
              }, 
            ), 
          ], 
        ), 
      ); 
      if (imageFile == null) { 
        Scaffold.of(context).showSnackBar( 
          SnackBar(content: Text('Please pick one image first.')), 
        ); 
        return false; 
      } 
      setState(() => this._imageFile = imageFile); 
      print('picked image: ${this._imageFile}'); 
      return true; 
    } 


  ////////////////////////////////////////////////////////////////
  Future<Null> _textOcr() async { 
    setState(() => this._mlResult = '<no result>'); 
    if (await _pickImage() == false) { 
      return; 
    } 
    String result = ''; 
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(this._imageFile); 
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer(); 
    final VisionText visionText = await textRecognizer.processImage(visionImage); 
    final String text = visionText.text; 
    result += 'Detected ${visionText.blocks.length} text blocks.\n'; 
    for (TextBlock block in visionText.blocks) { 
      final Rect boundingBox = block.boundingBox; 
      final List<Offset> cornerPoints = block.cornerPoints; 
      final String text = block.text; 
      final List<RecognizedLanguage> languages = block.recognizedLanguages; 
      result += '\n# Text block:\n ' 
        'bbox=$boundingBox\n ' 
        'cornerPoints=$cornerPoints\n ' 
        'text=$text\n languages=$languages'; 
    // for (TextLine line in block.lines) { 
    //   // Same getters as TextBlock 
    //   for (TextElement element in line.elements) { 
    //     // Same getters as TextBlock 
    //   } 
    // } 
    } 
    if (result.length > 0) { 
      setState(() => this._mlResult = result); 
    } 
  } 




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MLKIT TEXT OCR"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: RaisedButton(
            color: Colors.cyan,
            onPressed: this._textOcr,
            child: Text("TEXT OCR"),
          ),
        ),
      ),
    );
  }
}