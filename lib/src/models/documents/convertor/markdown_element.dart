enum MarkdownElementType {
  P,
  SPAN,
  H1,
  H2,
  H3,
  H4,
  H5,
  H6,
  OL,
  UL,
  BLOCKQUOTE,
  CODEBLOCK,
  CHECKED,
  UNCHECKED,
  A,
  IMG,
}

class MarkdownElement {
  MarkdownElement? parent;
  List<MarkdownElement> children = [];
  String? text;
  Map<String, dynamic> attributes = {};
  MarkdownElementType? type;
}

class LineElement extends MarkdownElement {}

class InlineElement extends MarkdownElement {}

class EmbeddedElement extends InlineElement {
  Map<String, String> data = {};
}
