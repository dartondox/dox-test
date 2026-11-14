import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_pdf_me/dox_pdf_me.dart';
import 'package:dox_test/config/pdfme.dart';

/// Makes a PDF from a pdfme template with dox_pdf_me.
@Inject()
class PdfmeService {
  /// The font option, read from disk on the first request.
  Map<String, FontSource>? _fonts;

  /// Roboto (the fallback) and the fonts of `pdfmeFonts`, like pdfme's `options.font`.
  Map<String, FontSource> get fonts {
    return _fonts ??= <String, FontSource>{
      'Roboto': FontSource(FontStore.defaultFont.data, fallback: true),
      for (MapEntry<String, String> e in pdfmeFonts.entries)
        e.key: FontSource(File(e.value).readAsBytesSync()),
    };
  }

  /// [template] and [inputs] are the pdfme JSON from the designer.
  /// A bad template gives 422 with the message of dox_pdf_me.
  Future<Uint8List> generatePdf(Object? template, Object? inputs) async {
    if (template is! Map<String, dynamic>) {
      throw _invalid('template must be an object');
    }
    if (inputs is! List) throw _invalid('inputs must be a list of objects');
    List<Map<String, String>> records = <Map<String, String>>[];
    for (Object? input in inputs) {
      if (input is! Map<String, dynamic>) {
        throw _invalid('inputs must be a list of objects');
      }
      records.add(_stringValues(input));
    }
    try {
      return await generate(
        template: Template.fromJson(template),
        inputs: records,
        plugins: builtInPlugins,
        options: GenerateOptions(font: fonts),
      );
    } on ArgumentError catch (e) {
      /// "Invalid argument (basePdf): must be ..." names the field
      throw _invalid(e.toString());
    } on FormatException catch (e) {
      throw _invalid(e.message);
    } on PDFLibError catch (e) {
      throw _invalid(e.toString());
    } on TypeError catch (e) {
      /// a field with the wrong JSON type, eg. a string for `width`
      throw _invalid('bad template: $e');
    }
  }

  /// dox_pdf_me takes strings only. A table or a list is a JSON string.
  /// A null is left out.
  Map<String, String> _stringValues(Map<String, dynamic> input) {
    return <String, String>{
      for (MapEntry<String, dynamic> e in input.entries)
        if (e.value != null)
          e.key: e.value is String ? e.value as String : jsonEncode(e.value),
    };
  }

  HttpStatusException _invalid(String message) {
    return HttpStatusException(422, message: message);
  }
}
