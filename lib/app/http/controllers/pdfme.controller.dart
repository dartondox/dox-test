import 'dart:io';
import 'dart:typed_data';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/services/pdfme.service.dart';
import 'package:dox_test/constants/app_constants.dart';

/// The pdfme playground (/inertia/pdfme) sends its template here.
@Tags(<String>['pdfme'])
@Inject()
class PdfmeController {
  final PdfmeService service;

  PdfmeController(this.service);

  /// Make a PDF from a pdfme template with dox_pdf_me
  ///
  /// Body: `{"template": {...}, "inputs": [{...}]}`. The answer is the PDF.
  /// The `X-Generate-Ms` header has the time it took on the server.
  Future<DoxResponse> generate(DoxRequest req) async {
    /// The app wide MAX_BODY_SIZE (1 MB here) stops bigger bodies first.
    if (req.httpRequest.contentLength > AppConstants.pdfmeMaxBodySize) {
      throw PayloadTooLargeException(
        message: 'The body may not be larger than 20 MB',
      );
    }
    Stopwatch watch = Stopwatch()..start();
    Uint8List pdf = await service.generatePdf(
      req.input('template'),
      req.input('inputs'),
    );
    return response(Stream<List<int>>.value(pdf))
        .contentType(ContentType('application', 'pdf'))
        .header('Content-Length', pdf.length)
        .header('X-Generate-Ms', watch.elapsedMilliseconds);
  }
}
