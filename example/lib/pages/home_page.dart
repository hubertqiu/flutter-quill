import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import '../universal_ui/universal_ui.dart';
import 'preview_page.dart';
import 'read_only_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/sample_data.json');
      final doc = Document.fromJson(jsonDecode(result));
      setState(() {
        _controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const CupertinoPageScaffold(child: Center(child: Text('Loading...')));
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Flutter Quill',
          // style: Styles.navBarText,
        ),
        trailing: buildNavBarTextItem(context, '预览', true, MainAxisAlignment.end, () {
          _preview();
        }),
        // backgroundColor: Styles.activeColor,
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.data.isControlPressed && event.character == 'b') {
            if (_controller!.getSelectionStyle().attributes.keys.contains('bold')) {
              _controller!.formatSelection(Attribute.clone(Attribute.bold, null));
            } else {
              _controller!.formatSelection(Attribute.bold);
            }
          }
        },
        child: _buildWelcomeEditor(context),
      ),
    );
  }

  static Widget buildNavBarTextItem(
      BuildContext context, String title, bool enabled, MainAxisAlignment mainAxisAlignment, VoidCallback callback) {
    var navItem = GestureDetector(
      onTap: () {
        if (enabled && callback != null) {
          callback();
        }
      },
      child: Container(
        width: 64,
        color: CupertinoTheme.of(context).barBackgroundColor,
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Container(
              // padding: EdgeInsets.only(bottom: 3),
              child: Text(title,
                  style: TextStyle(
                    color: CupertinoColors.white,
                  )),
            ),
          ],
        ),
      ),
    );
    return navItem;
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    var quillEditor = QuillEditor(
        controller: _controller!,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: _focusNode,
        autoFocus: false,
        readOnly: false,
        placeholder: 'Add content',
        expands: false,
        padding: EdgeInsets.zero,
        customStyles: DefaultStyles(
          h1: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 32,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const Tuple2(16, 0),
              const Tuple2(0, 0),
              null),
          sizeSmall: const TextStyle(fontSize: 9),
        ));
    if (kIsWeb) {
      quillEditor = QuillEditor(
          controller: _controller!,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: false,
          readOnly: false,
          placeholder: 'Add content',
          expands: false,
          padding: EdgeInsets.zero,
          customStyles: DefaultStyles(
            h1: DefaultTextBlockStyle(
                const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  height: 1.15,
                  fontWeight: FontWeight.w300,
                ),
                const Tuple2(16, 0),
                const Tuple2(0, 0),
                null),
            sizeSmall: const TextStyle(fontSize: 9),
          ),
          embedBuilder: defaultEmbedBuilderWeb);
    }
    var toolbar = QuillToolbar.basic(controller: _controller!, onImagePickCallback: _onImagePickCallback);
    final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
    if (isDesktop) {
      toolbar = QuillToolbar.basic(
          controller: _controller!,
          onImagePickCallback: _onImagePickCallback,
          filePickImpl: openFileSystemPickerForDesktop);
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: quillEditor,
            ),
          ),
          kIsWeb
              ? Expanded(
                  child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: toolbar,
                ))
              : Container(child: toolbar)
        ],
      ),
    );
  }

  Future<String?> openFileSystemPickerForDesktop(BuildContext context) async {
    return await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
  }

  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile = await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  Widget _buildMenuBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const itemStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(
          thickness: 2,
          color: Colors.white,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
        ListTile(
          title: const Center(child: Text('Read only demo', style: itemStyle)),
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: _readOnly,
        ),
        Divider(
          thickness: 2,
          color: Colors.white,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
      ],
    );
  }

  void _readOnly() {
    Navigator.push(
      super.context,
      MaterialPageRoute(
        builder: (context) => ReadOnlyPage(),
      ),
    );
  }

  void _preview() {
    String jsonString = jsonEncode(_controller!.document.toDelta().toJson());
    String markdown = DeltaConvertor(jsonString).convert();
    print("\n" + markdown);
    // return;
    Navigator.push(
      super.context,
      CupertinoPageRoute(
        builder: (context) => PreviewPage(markdown),
      ),
    );
  }
}
