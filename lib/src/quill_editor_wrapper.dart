import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

class QuillHtmlEditor extends StatefulWidget {
  const QuillHtmlEditor(
      {this.text,
      required Key editorKey,
      required this.height,
      this.isEnabled = true,
      this.hintText = 'Description'})
      : super(key: editorKey);

  /// to set initial text to the editor, please use text
  /// We can also use the setText method for the same
  final String? text;

  /// to define the height of the editor
  final double height;

  /// hintText is a placeholder, by default, the hint will be 'Description'
  /// We can override the placeholder text by passing hintText to the editor
  final String? hintText;

  /// isEnabled as the name suggests, is used to enable or disable the editor
  /// When it is set to false, the user cannot edit or type in the editor
  final bool isEnabled;

  @override
  QuillHtmlEditorState createState() => QuillHtmlEditorState();
}

class QuillHtmlEditorState extends State<QuillHtmlEditor> {
  /// it is the controller used to access the functions of quill js library
  late WebViewXController _webviewController;

  /// this variable is used to set the html code that renders the quill js library
  String _initialContent = "";

  /// isEnabled as the name suggests, is used to enable or disable the editor
  /// When it is set to false, the user cannot edit or type in the editor
  bool isEnabled = true;

  @override
  void initState() {
    isEnabled = widget.isEnabled;
    super.initState();
  }

  @override
  void dispose() {
    _webviewController.dispose();
    super.dispose();
  }

  /// getText method is used to get the html string from the editor
  /// To avoid getting empty html tags, we are validating the html string
  /// if it doesn't contain any text, the method will return empty string instead of empty html tag
  Future<String> getText() async {
    String? text = await _getHtmlFromEditor();
    String parsedText = _stripHtmlIfNeeded(text);
    try {
      if (parsedText.trim() == "") {
        return "";
      } else {
        return text;
      }
    } catch (e) {
      return "";
    }
  }

  /// setText method is used to set the html text to the editor
  /// it will override the existing text in the editor with the new one
  Future setText(String text) async {
    return await _setHtmlTextToEditor(htmlText: text);
  }

  /// it is a regex method to remove the tags and replace them with empty space
  static String _stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  /// This method is used to enable/ disable the editor,
  /// while, we can enable or disable the editor directly by passing isEnabled to the widget,
  /// this is an additional function that can be used to do the same with the state key
  /// We can choose either of these ways to enable/disable
  void enableEditor(bool enable) async {
    isEnabled = enable;
    await _enableTextEditor(isEnabled: isEnabled);
  }

  /// This method is used to clear the editor
  void clear() async {
    await _setHtmlTextToEditor(htmlText: '');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenHeight = widget.height;
      _initialContent =
          _getQuillPage(height: screenHeight, width: constraints.maxWidth);

      return Center(
        child: _buildEditorView(
            context: context,
            height: screenHeight,
            width: constraints.maxWidth),
      );
    });
  }

  Widget _buildEditorView(
      {required BuildContext context,
      required double height,
      required double width}) {
    _initialContent = _getQuillPage(height: height, width: width);

    return WebViewX(
      key: ValueKey(widget.hintText ?? "webviewEditor"),
      initialContent: _initialContent,
      initialSourceType: SourceType.html,
      height: height,
      ignoreAllGestures: false,
      width: width - 5,
      onWebViewCreated: (controller) => _webviewController = controller,
      onPageStarted: (src) {},
      onPageFinished: (src) {
        if (widget.text != null) {
          _setHtmlTextToEditor(htmlText: widget.text!);
        }
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: false,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        return NavigationDecision.navigate;
      },
    );
  }

  /// a private method to get the Html text from the editor
  Future<String> _getHtmlFromEditor() async {
    return await _webviewController.callJsMethod("getHtmlText", []);
  }

  /// a private method to set the Html text to the editor
  Future _setHtmlTextToEditor({required String htmlText}) async {
    await _webviewController.callJsMethod("setHtmlText", [htmlText]);
  }

  /// a private method to enable/disable the editor
  Future _enableTextEditor({required bool isEnabled}) async {
    await _webviewController.callJsMethod("enableEditor", [isEnabled]);
  }

  /// This method generated the html code that is required to render the quill js editor
  /// We are rendering this html page with the help of webviewx and using the callbacks to call the quill js apis
  String _getQuillPage({required double height, required double width}) {
    double finalHeight = width < 350
        ? height - 110
        : width < 600
            ? height - 85
            : height - 65;

    return '''
 <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">
      
      <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet" />
      <style>
      .ql-container.ql-snow {
      margin-top:0px;
      width:100%;
      border:none;
      height: ${finalHeight.toInt() - 43}px;
      min-height:100%;  
      }
      
      <style>
      .ql-toolbar { position: absolute; top: 0;left:0;right:0}
      </style>
      
      </style>
      </head>
      <body>
      
      
      <!-- Create the toolbar container -->
      
      <div id="toolbar-container">
      
      <span class="ql-formats">
      <button class="ql-bold"></button>
      <button class="ql-italic"></button>
      <button class="ql-underline"></button>
      <button class="ql-strike"></button>
      <button class="ql-blockquote"></button>
      <select class="ql-size"></select>
      
      <select class="ql-color"></select>
      <select class="ql-background"></select>
      
      <button class="ql-header" value="1"></button>
      <button class="ql-header" value="2"></button>
      
      <button class="ql-list" value="ordered"></button>
      <button class="ql-list" value="bullet"></button>
      <select class="ql-align"></select>
      <button class="ql-indent" value="-1"></button>
      <button class="ql-indent" value="+1"></button>
      <button class="ql-link"></button>
      
      <button class="ql-clean"></button>
      </span>
      </div>
      
      <!-- Create the editor container -->
      <div style="position:relative;margin-top:0em;">
      <div id="editorcontainer" style="height:${finalHeight.toInt()}px; min-height:100%; overflow-y:auto;margin-top:0em">
      <div id="editor" style="min-height:100%; height:${finalHeight.toInt() - 43}px;  width:100%;"></div>
      </div>
      </div>
      <!-- Include the Quill library -->
      <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
      
      <!-- Initialize Quill editor -->
      <script>
      
      
      let fullWindowHeight = window.innerHeight;
      let keyboardIsProbablyOpen = false;
      
      window.addEventListener("resize", function() {
      
      resizeElementHeight(document.getElementById("editorcontainer"),1);
      resizeElementHeight(document.getElementById("editor"),1);
      if(window.innerHeight == fullWindowHeight) {
      keyboardIsProbablyOpen = false;
      
      } else if(window.innerHeight < fullWindowHeight*0.9) {
      
      keyboardIsProbablyOpen = true;
      }
      });
      
      
      function resizeElementHeight(element, ratio) {
      var height = 0;
      var body = window.document.body;
      if (window.innerHeight) {
      height = window.innerHeight;
      } else if (body.parentElement.clientHeight) {
      height = body.parentElement.clientHeight;
      } else if (body && body.clientHeight) {
      height = body.clientHeight;
      }
        let isIOS = /iPad|iPhone|iPod/.test(navigator.platform)
        || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
        if(isIOS){
        element.style.height = ((height/ratio - element.offsetTop) + "px");
        }else{
        element.style.height = ((height - element.offsetTop-60) + "px");
        }
      
      }
      
      function applyGoogleKeyboardWorkaround(editor) {
      
      try {
      
      if (editor.applyGoogleKeyboardWorkaround) {
          return
      }
      editor.applyGoogleKeyboardWorkaround = true
      editor.on('editor-change', function (eventName, ...args) {
          if (eventName === 'text-change') {
           
            // args[0] will be delta
            var ops = args[0]['ops']
            if(ops===null){
            return
            }
            var oldSelection = editor.getSelection()
            var oldPos = oldSelection.index
            var oldSelectionLength = oldSelection.length
            if (ops[0]["retain"] === undefined || !ops[1] || !ops[1]["insert"] || !ops[1]["insert"] ||ops[1]["list"] === "bullet"|| ops[1]["list"] === "ordered"  || ops[1]["insert"] !=  "\\n" || oldSelectionLength > 0) {
              return
            }
          
            setTimeout(function () {
      
              var newPos = editor.getSelection().index
              if (newPos === oldPos) {
                console.log("Change selection bad pos")
                editor.setSelection(editor.getSelection().index + 1, 0)
              }
            }, 30);
          } 
        });
      } catch (e) {
        console.log(e);
       }
      }
      
      const Inline = Quill.import('blots/inline');
      class RequirementBlot extends Inline {}
      RequirementBlot.blotName = 'requirement';
      RequirementBlot.tagName = 'requirement';
      Quill.register(RequirementBlot);
      
      class ResponsibilityBlot extends Inline {}
      ResponsibilityBlot.blotName = 'responsibility';
      ResponsibilityBlot.tagName = 'responsibility';
      Quill.register(ResponsibilityBlot);
      
      var quilleditor = new Quill('#editor', {
        modules: { toolbar: '#toolbar-container' },
        theme: 'snow',
        placeholder: '${widget.hintText ?? "Description"}',
        clipboard: {
            matchVisual: false
        }
      });
      
      quilleditor.enable($isEnabled);
      
      quilleditor.root.addEventListener("blur",function (){
      
      resizeElementHeight(document.getElementById("editorcontainer"),1);
      resizeElementHeight(document.getElementById("editor"),1);                     
      
      });
                          
      quilleditor.root.addEventListener("focus",function (){
      resizeElementHeight(document.getElementById("editorcontainer"),2);
      resizeElementHeight(document.getElementById("editor"),2);       
      
      });
      applyGoogleKeyboardWorkaround(quilleditor);
      
      function getHtmlText()
      {
        var html = quilleditor.root.innerHTML;
        return html;
      }
      
      function setHtmlText(htmlString) 
      {
        quilleditor.container.firstChild.innerHTML = htmlString;
      } 
      
        function enableEditor(isEnabled) 
      {
        quilleditor.enable(isEnabled);
      } 
      
      </script>
      </body>
      </html>
     ''';
  }
}
