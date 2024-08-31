// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:web/web.dart';
import 'dart:typed_data';

/// Initializes a DOM container where we can host elements.
html.Element _ensureInitialized(String id) {
  var target = html.querySelector('#$id');
  if (target == null) {
    final html.Element targetElement = html.Element.tag('flt-x-file')..id = id;

    html.querySelector('body')?.children.add(targetElement);
    target = targetElement;
  }
  return target;
}

html.AnchorElement _createAnchorElement(String href, String suggestedName) {
  return html.AnchorElement(href: href)..download = suggestedName;
}

/// Add an element to a container and click it
void _addElementToContainerAndClick(
    html.Element container, html.Element element) {
  // Add the element and click it
  // All previous elements will be removed before adding the new one
  container.children.add(element);
  element.click();
}

/// Present a dialog so the user can save as... a bunch of bytes.
Future<void> saveAsBytes(Uint8List bytes, String suggestedName) async {
  // Convert bytes to an ObjectUrl through Blob
  final blob = html.Blob([bytes]);
  final path = html.Url.createObjectUrl(blob);

  // Create a DOM container where we can host the anchor.
  final target = _ensureInitialized('__x_file_dom_element');

  // Create an <a> tag with the appropriate download attributes and click it
  // May be overridden with XFileTestOverrides
  final html.AnchorElement element = _createAnchorElement(path, suggestedName);

  // Clear the children in our container so we can add an element to click
  target.children.clear();
  _addElementToContainerAndClick(target, element);
}
