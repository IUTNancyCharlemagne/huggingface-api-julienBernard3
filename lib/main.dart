import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomIcon.dart';
import 'package:flutter_application_1/imageHistoryPage.dart';
import 'package:flutter_application_1/imagePrediction.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets.dart';
import 'utils.dart';
import 'package:google_fonts/google_fonts.dart';

final List<String> listPommes = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/apple/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/apple/Image_2.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/apple/Image_7.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/apple/Image_8.jpg'
];

final List<String> listBananes = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/banana/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/banana/Image_8.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/banana/Image_3.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/banana/Image_4.jpg'
];

final List<String> listKiwis = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/kiwi/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/kiwi/Image_2.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/kiwi/Image_3.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/kiwi/Image_4.jpg'
];

final List<String> listMangues = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/mango/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/mango/Image_2.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/mango/Image_3.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/mango/Image_4.jpg'
];

final List<String> listFraises = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/strawberry/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/strawberry/Image_2.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/strawberry/Image_3.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/strawberry/Image_4.jpg'
];

final List<String> listAnanas = [
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/pineapple/Image_1.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/pineapple/Image_2.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/pineapple/Image_3.jpg',
  'https://raw.githubusercontent.com/IUTNancyCharlemagne/huggingface-api-julienBernard3/main/sample_images/pineapple/Image_4.jpg'
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconnaisseur de fruits',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Reconnaisseur de fruits'),
      debugShowCheckedModeBanner: false,
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
  List<ImagePrediction> imageHistory = [];
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String? _resultString;
  Map _resultDict = {
    "label": "None",
    "confidences": [
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0},
      {"label": "None", "confidence": 0.0}
    ]
  };

  String _latency = "N/A";

  File? imageURI; // Show on image widget on app
  Uint8List? imgBytes; // Store img to be sent for api inference
  bool isClassifying = false;

  String parseResultsIntoString(Map results) {
    return """
    ${results['confidences'][0]['label']} - ${(results['confidences'][0]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][1]['label']} - ${(results['confidences'][1]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][2]['label']} - ${(results['confidences'][2]['confidence'] * 100.0).toStringAsFixed(2)}% """;
  }

  setImageURI(File img) {
    setState(() {
      imageURI = img;
    });
    clearInferenceResults();
  }

  clearInferenceResults() {
    _resultString = "";
    _latency = "N/A";
    _resultDict = {
      "label": "None",
      "confidences": [
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0},
        {"label": "None", "confidence": 0.0}
      ]
    };
  }

  Widget buildModalBtmSheetItems() {
    return SizedBox(
      height: 120,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () async {
              final XFile? pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.camera);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);
                // final imgFile = File(pickedFile.path);
                setState(() {
                  imageURI = imgFile;
                  _btnController.stop();
                  isClassifying = false;
                });
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Gallery"),
            onTap: () async {
              final XFile? pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                // Clear result of previous inference as soon as new image is selected
                setState(() {
                  clearInferenceResults();
                });

                File croppedFile = await cropImage(pickedFile);
                final imgFile = File(croppedFile.path);

                setState(
                  () {
                    imageURI = imgFile;
                    _btnController.stop();
                    isClassifying = false;
                  },
                );
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Reconnaisseur de fruits'),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Version'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Historique'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageHistoryPage(
                            imageHistory: imageHistory,
                            setImageURI: setImageURI)),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageURI == null
                  ? SizedBox(
                      height: 200,
                      child: EmptyWidget(
                        image: null,
                        packageImage: PackageImage.Image_3,
                        title: 'Aucune image',
                        subTitle: 'Sélectionnez une image',
                        titleTextStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xff9da9c7),
                          fontWeight: FontWeight.w500,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xffabb8d6),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const Spacer(),
                        Stack(
                          children: [
                            Image.file(imageURI!,
                                height: 200, fit: BoxFit.cover),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: CustomIcon(
                                size: 25, // Taille du cercle
                                onPressed: () {
                                  setState(() {
                                    imageURI = null;
                                    clearInferenceResults();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
              const SizedBox(
                height: 8,
              ),
              if (_resultString != null && _resultString!.isNotEmpty) ...[
                Text("Les 3 meilleures prédictions:",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                FittedBox(child: buildResultsIndicators(_resultDict)),
                const SizedBox(height: 8)
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    popup(context);
                  },
                  child: _resultString != null && _resultString!.isNotEmpty
                      ? const Text('Afficher toutes les prédictions')
                      : const Text('Afficher les éléments prédictibles'),
                ),
              ),
              const SizedBox(height: 8),
              if (_resultString != null && _resultString!.isNotEmpty) Text("Latence: $_latency ms",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text("Pommes: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listPommes),
              Text("Bananes: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listBananes),
              Text("Kiwis: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listKiwis),
              Text("Mangues: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listMangues),
              Text("Fraises: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listFraises),
              Text("Ananas: ", style: Theme.of(context).textTheme.titleLarge),
              buildCarouselSlider(listAnanas),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  child: FloatingActionButton.extended(
                    label: const Text("Depuis l'appareil"),
                    icon: const Icon(Icons.camera),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return buildModalBtmSheetItems();
                        },
                      );
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(Uri.parse(link.url));
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: "Made by https://dicksonneoh.com",
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: RoundedLoadingButton(
          width: MediaQuery.of(context).size.width * 0.5,
          color: Colors.blue,
          successColor: Colors.green,
          resetAfterDuration: true,
          resetDuration: const Duration(seconds: 5),
          controller: _btnController,
          onPressed: isClassifying || imageURI == null
              ? null // null value disables the button
              : () async {
                  isClassifying = true;

                  imgBytes = imageURI!.readAsBytesSync();
                  String base64Image =
                      "data:image/png;base64,${base64Encode(imgBytes!)}";

                  try {
                    Stopwatch stopwatch = Stopwatch()..start();
                    final result = await classifyRiceImage(base64Image);
                    // Traduction en français
                    // Parcours de la liste des confidences
                    for (var i = 0; i < result['confidences'].length; i++) {
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('pineapple', ': Ananas');
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('apple', ': Pomme');
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('banana', ': Banane');
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('kiwi', ': Kiwi');
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('mango', ': Mangue');
                      result['confidences'][i]['label'] = result['confidences']
                              [i]['label']
                          .replaceAll('strawberry', ': Fraise');
                    }

                    setState(() {
                      _resultString = parseResultsIntoString(result);
                      _resultDict = result;
                      _latency = stopwatch.elapsed.inMilliseconds.toString();
                    });
                    popup(context);
                    String prediction = result['confidences'][0]['label'];
                    // On vérifie qu'il n'y a pas déjà cette prediction dans imageHistory
                    if (imageHistory
                        .where((element) => element.image.path == imageURI!.path)
                        .isEmpty) {
                      imageHistory.add(ImagePrediction(
                          image: imageURI!, prediction: prediction));
                    }
                    _btnController.success();
                  } catch (e) {
                    _btnController.error();
                  }
                  isClassifying = false;
                },
          child: const Text('Prédire!', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void popup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _resultString != null && _resultString!.isNotEmpty
              ? const Text('Éléments prédis')
              : const Text('Éléments prédictible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _resultString != null && _resultString!.isNotEmpty
                ? _resultDict['confidences'] != null &&
                        _resultDict['confidences'].isNotEmpty
                    ? _resultDict['confidences'].map<Widget>((confidence) {
                        return Text(
                          '${confidence['label'].substring(2)} - ${(confidence['confidence'] * 100).toStringAsFixed(2)}%',
                        );
                      }).toList()
                    : [const Text('Aucune prédiction disponible')]
                : [const Text('Pomme\nBanane\nKiwi\nMangue\nFraise\nAnanas')],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  CarouselSlider buildCarouselSlider(List<String> img) {
    final List<Widget> imgList = img
        .map((item) => Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          context.loaderOverlay.show();

                          String imgUrl = img[img.indexOf(item)];

                          final imgFile = await getImage(imgUrl);

                          setState(() {
                            imageURI = imgFile;
                            _btnController.stop();
                            isClassifying = false;
                            clearInferenceResults();
                          });
                          context.loaderOverlay.hide();
                        },
                        child: CachedNetworkImage(
                          imageUrl: item,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 00.0, horizontal: 20.0)),
                      ),
                    ],
                  )),
            ))
        .toList();

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        aspectRatio: 2.5,
        viewportFraction: 0.4,
        enlargeCenterPage: false,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      items: imgList,
    );
  }
}
