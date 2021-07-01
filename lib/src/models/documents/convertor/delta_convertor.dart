import 'dart:convert';

import '../../../../flutter_quill.dart';
import '../../../../utils/color.dart';
import 'markdown_element.dart';

class ConvertorContext {
  ConvertorContext(this.source) {
    operationLines.add(currentOperationLine);
  }
  String source;
  String? result;
  List<OperationLine> operationLines = [];
  OperationLine currentOperationLine = OperationLine();
  List<LineElement> lines = [];
  LineElement? currentLine;
}

class OperationLine {
  OperationLine();
  List<Operation> operations = [];
}

class DeltaConvertor {
  DeltaConvertor(String input) {
    context = ConvertorContext(input);
  }
  late ConvertorContext context;

  String convert() {
    final inputJson = jsonDecode(context.source) as List<dynamic>?;
    if (inputJson is! List<dynamic>) {
      throw ArgumentError('Unexpected formatting of the input delta string.');
    }
    final delta = Delta.fromJson(inputJson);
    final iterator = DeltaIterator(delta);

    while (iterator.hasNext) {
      final operation = iterator.next();

      if (operation.data is String) {
        final operationData = operation.data as String;

        if (!operationData.contains('\n')) {
          parseInline(operation);
        } else {
          List<Operation> operations;

          if (operationData != '\n') {
            operations = splitOpertation(operation);
          } else {
            operations = [operation];
          }
          for (final op in operations) {
            final data = op.data as String;
            if (data != '\n') {
              parseInline(op);
            } else {
              parseLine(op);
            }
          }
        }
      } else if (operation.data is Map<String, dynamic>) {
        parseEmbedded(operation);
      } else {
        throw ArgumentError('Unexpected formatting of the input delta string.');
      }
    }

    convertLines();
    renderResult();
    return context.result ?? '';
  }

  void renderResult() {
    final result = StringBuffer();
    for (var i = 0; i < context.lines.length; i++) {
      final currentLine = context.lines[i];
      final lastLine = i > 0 ? context.lines[i - 1] : null;
      // ignore: lines_longer_than_80_chars
      final nextLine = i < context.lines.length - 1 ? context.lines[i + 1] : null;
      result.write(renderLine(currentLine, lastLine, nextLine));
    }
    context.result = result.toString();
  }

  StringBuffer renderLine(LineElement lineElement, LineElement? lastLine, LineElement? nextLine) {
    final stringBuffer = StringBuffer();
    renderLineStart(stringBuffer, lineElement, lastLine, nextLine);
    renderLineContent(stringBuffer, lineElement, lastLine, nextLine);
    renderLineEnd(stringBuffer, lineElement, lastLine, nextLine);
    stringBuffer.write('  \n');
    return stringBuffer;
  }

  void renderLineStart(
      StringBuffer stringBuffer, LineElement lineElement, LineElement? lastLine, LineElement? nextLine) {
    if (lineElement.type == MarkdownElementType.H1) {
      stringBuffer.write('# ');
    } else if (lineElement.type == MarkdownElementType.H2) {
      stringBuffer.write('## ');
    } else if (lineElement.type == MarkdownElementType.H3) {
      stringBuffer.write('### ');
    } else if (lineElement.type == MarkdownElementType.H4) {
      stringBuffer.write('#### ');
    } else if (lineElement.type == MarkdownElementType.H5) {
      stringBuffer.write('##### ');
    } else if (lineElement.type == MarkdownElementType.H6) {
      stringBuffer.write('###### ');
    } else if (lineElement.type == MarkdownElementType.BLOCKQUOTE) {
      stringBuffer.write('> ');
    } else if (lineElement.type == MarkdownElementType.CODEBLOCK) {
      stringBuffer.write('```\n');
    } else if (lineElement.type == MarkdownElementType.CHECKED) {
      final indent = lineElement.attributes['indent'] ?? 0;
      stringBuffer.write('    ' * indent + '- [x] ');
    } else if (lineElement.type == MarkdownElementType.UNCHECKED) {
      final indent = lineElement.attributes['indent'] ?? 0;
      stringBuffer.write('    ' * indent + '- [ ] ');
    } else if (lineElement.type == MarkdownElementType.UL) {
      final indent = lineElement.attributes['indent'] ?? 0;
      stringBuffer.write('    ' * indent + '- ');
    } else if (lineElement.type == MarkdownElementType.OL) {
      final indent = lineElement.attributes['indent'] ?? 0;
      var order = 1;
      if (lastLine?.type == MarkdownElementType.OL) {
        final lastLineIndent = lastLine?.attributes['indent'] ?? 0;
        if (indent == lastLineIndent) {
          order = lastLine?.attributes['order'] ?? 1;
          order++;
        }
      }
      lineElement.attributes['order'] = order;
      stringBuffer.write('    ' * indent + order.toString() + '. ');
    } else {
      stringBuffer.write('');
    }
  }

  void renderLineContent(
      StringBuffer stringBuffer, LineElement lineElement, LineElement? lastLine, LineElement? nextLine) {
    for (var inlineElement in lineElement.children) {
      if (inlineElement.type == MarkdownElementType.SPAN) {
        stringBuffer.write(renderSpanContent(inlineElement as InlineElement));
      } else if (inlineElement.type == MarkdownElementType.A) {
        stringBuffer.write('[' + inlineElement.text! + '](' + inlineElement.attributes['link'] + ')');
      } else if (inlineElement.type == MarkdownElementType.IMG) {
        stringBuffer.write('![' + inlineElement.text! + '](' + inlineElement.attributes['url'] + ')');
      }
    }
  }

  String renderSpanContent(InlineElement inlineElement) {
    var result = inlineElement.text!;
    if (inlineElement.attributes['bold'] == true) {
      result = '**' + result + '**';
    }
    if (inlineElement.attributes['italic'] == true) {
      result = '*' + result + '*';
    }
    if (inlineElement.attributes['italic'] == true) {
      result = '*' + result + '*';
    }
    if (inlineElement.attributes['strike'] == true) {
      result = '~~' + result + '~~';
    }
    if (inlineElement.attributes['underline'] == true) {
      result = '<u>' + result + '</u>';
    }
    return result;
  }

  void renderLineEnd(StringBuffer stringBuffer, LineElement lineElement, LineElement? lastLine, LineElement? nextLine) {
    if (lineElement.type == MarkdownElementType.H1) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.H2) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.H3) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.H4) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.H5) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.H6) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.BLOCKQUOTE) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.CODEBLOCK) {
      if (lineElement.children.length == 0 || lineElement.children.last.text != '\n') {
        stringBuffer.write('\n');
      }
      stringBuffer.write('```\n');
    } else if (lineElement.type == MarkdownElementType.CHECKED) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.UNCHECKED) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.UL) {
      stringBuffer.write('');
    } else if (lineElement.type == MarkdownElementType.OL) {
      stringBuffer.write('');
    } else {
      stringBuffer.write('');
    }
  }

  List<Operation> splitOpertation(Operation operation) {
    var operationData = operation.data as String;
    List<Operation> list = [];
    var index = operationData.indexOf('\n');
    while (index != -1) {
      if (index != 0) {
        String ahead = operationData.substring(0, index);
        Operation op = Operation.insert(ahead, null);
        list.add(op);
      }
      String newLine = operationData.substring(index, index + 1);
      Operation op = Operation.insert(newLine, index == operationData.length - 1 ? operation.attributes : null);
      list.add(op);
      if (index + 1 < operationData.length) {
        operationData = operationData.substring(index + 1);
        index = operationData.indexOf('\n');
      } else {
        index = -1;
        operationData = '';
      }
    }
    if (operationData.isNotEmpty) {
      Operation op = Operation.insert(operationData, operation.attributes);
      list.add(op);
    }
    return list;
  }

  void parseLine(Operation operation) {
    context.currentOperationLine.operations.add(operation);
    context.currentOperationLine = OperationLine();
    context.operationLines.add(context.currentOperationLine);
  }

  void parseInline(Operation operation) {
    context.currentOperationLine.operations.add(operation);
  }

  void parseEmbedded(Operation operation) {
    context.currentOperationLine.operations.add(operation);
  }

  void convertLines() {
    for (var operationLine in context.operationLines) {
      context.currentLine = LineElement();
      context.currentLine!.type = MarkdownElementType.P;
      context.lines.add(context.currentLine!);
      for (var operation in operationLine.operations) {
        if (operation.value is String) {
          if (operation.value == '\n') {
            covertLineAttributes(context.currentLine!, operation);
          } else {
            covertInlineAttributes(context.currentLine!, operation);
          }
        } else if (operation.value is Map<String, dynamic>) {
          covertEmbeddedAttributes(context.currentLine!, operation);
        }
      }
    }
  }

  void covertInlineAttributes(LineElement lineElement, Operation operation) {
    final inlineElement = InlineElement();
    lineElement.children.add(inlineElement);
    inlineElement.parent = lineElement;
    inlineElement.text = operation.value;
    inlineElement.type = MarkdownElementType.SPAN;
    if (operation.hasAttribute('background')) {
      final value = operation.attributes!['background'];
      final color = stringToColor(value);
      inlineElement.attributes['background'] = color;
    }
    if (operation.hasAttribute('color')) {
      final value = operation.attributes!['color'];
      final color = stringToColor(value);
      inlineElement.attributes['color'] = color;
    }
    if (operation.hasAttribute('italic')) {
      final value = operation.attributes!['italic'];
      inlineElement.attributes['italic'] = value;
    }
    if (operation.hasAttribute('bold')) {
      final value = operation.attributes!['bold'];
      inlineElement.attributes['bold'] = value;
    }
    if (operation.hasAttribute('strike')) {
      final value = operation.attributes!['strike'];
      inlineElement.attributes['strike'] = value;
    }
    if (operation.hasAttribute('underline')) {
      final value = operation.attributes!['underline'];
      inlineElement.attributes['underline'] = value;
    }
    if (operation.hasAttribute('link')) {
      final value = operation.attributes!['link'];
      inlineElement.attributes['link'] = value;
      inlineElement.type = MarkdownElementType.A;
    }
    if (operation.hasAttribute('font')) {
      final value = operation.attributes!['font'];
      inlineElement.attributes['font'] = value;
    }
    if (operation.hasAttribute('size')) {
      final value = operation.attributes!['size'];
      inlineElement.attributes['size'] = value;
    }
    if (operation.hasAttribute('token')) {
      final value = operation.attributes!['token'];
      inlineElement.attributes['token'] = value;
    }
  }

  void covertEmbeddedAttributes(LineElement lineElement, Operation operation) {
    final data = operation.data as Map<String, dynamic>;
    if (data.containsKey('image')) {
      final image = data['image'];
      final inlineElement = InlineElement();
      lineElement.children.add(inlineElement);
      inlineElement.parent = lineElement;
      inlineElement.text = 'image';
      inlineElement.type = MarkdownElementType.IMG;
      inlineElement.attributes['url'] = image;
    }
  }

  void covertLineAttributes(LineElement lineElement, Operation operation) {
    if (operation.hasAttribute('header')) {
      final value = operation.attributes!['header'];
      if (value == 1) {
        lineElement.type = MarkdownElementType.H1;
      } else if (value == 2) {
        lineElement.type = MarkdownElementType.H2;
      } else if (value == 3) {
        lineElement.type = MarkdownElementType.H3;
      } else if (value == 4) {
        lineElement.type = MarkdownElementType.H4;
      } else if (value == 5) {
        lineElement.type = MarkdownElementType.H5;
      } else if (value == 6) {
        lineElement.type = MarkdownElementType.H6;
      }
    } else if (operation.hasAttribute('list')) {
      final value = operation.attributes!['list'];
      if (value == 'ordered') {
        lineElement.type = MarkdownElementType.OL;
      } else if (value == 'bullet') {
        lineElement.type = MarkdownElementType.UL;
      } else if (value == 'checked') {
        lineElement.type = MarkdownElementType.CHECKED;
      } else if (value == 'unchecked') {
        lineElement.type = MarkdownElementType.UNCHECKED;
      }
    } else if (operation.hasAttribute('code-block')) {
      final value = operation.attributes!['code-block'];
      if (value == true) {
        lineElement.type = MarkdownElementType.CODEBLOCK;
      }
    } else if (operation.hasAttribute('blockquote')) {
      final value = operation.attributes!['blockquote'];
      if (value == true) {
        lineElement.type = MarkdownElementType.BLOCKQUOTE;
      }
    }
    if (operation.hasAttribute('indent')) {
      final value = operation.attributes!['indent'];
      lineElement.attributes['indent'] = value;
    }
    if (operation.hasAttribute('align')) {
      final value = operation.attributes!['align'];
      lineElement.attributes['align'] = value;
    }
  }
}
