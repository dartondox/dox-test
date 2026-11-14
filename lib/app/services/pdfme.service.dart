import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_pdf_me/dox_pdf_me.dart';

/// Makes a PDF from a pdfme template with dox_pdf_me.
@Inject()
class PdfmeService {
  /// [template] and [inputs] are the pdfme JSON from the designer.
  /// A bad template gives 422 with the message of dox_pdf_me.
  Future<Uint8List> generatePdf(Object? template, Object? inputs) async {
    if (template is! Map<String, dynamic>) {
      throw _invalid('template must be an object');
    }
    if (inputs is! List) throw _invalid('inputs must be a list of objects');
    List<Map<String, dynamic>> records = <Map<String, dynamic>>[];
    for (Object? input in inputs) {
      if (input is! Map<String, dynamic>) {
        throw _invalid('inputs must be a list of objects');
      }
      records.add(input);
    }
    try {
      return await generate(
        template: template,
        inputs: records,
        plugins: builtInPlugins,
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

  HttpStatusException _invalid(String message) {
    return HttpStatusException(422, message: message);
  }
}
