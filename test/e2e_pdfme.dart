import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;

/// POST /api/pdfme/generate: a pdfme template to a PDF with dox_pdf_me.
/// e2e_test.dart calls it, so it shares the server of that file.
void pdfmeTests(Api api) {
  group('dox_pdf_me: pdfme playground', () {
    test('a template gives a PDF and the time header', () async {
      http.Response res = await api.post(
        '/api/pdfme/generate',
        <String, dynamic>{
          'template': <String, dynamic>{
            'basePdf': <String, dynamic>{
              'width': 210,
              'height': 297,
              'padding': <int>[0, 0, 0, 0],
            },
            'schemas': <dynamic>[
              <dynamic>[
                <String, dynamic>{
                  'name': 'title',
                  'type': 'text',
                  'position': <String, num>{'x': 20, 'y': 20},
                  'width': 170,
                  'height': 15,
                },
                <String, dynamic>{
                  'name': 'link',
                  'type': 'qrcode',
                  'position': <String, num>{'x': 20, 'y': 40},
                  'width': 30,
                  'height': 30,
                },
              ],
            ],
          },
          'inputs': <dynamic>[
            <String, dynamic>{'title': 'Hello', 'link': 'https://pdfme.com'},
          ],
        },
      );
      expect(res.statusCode, 200);
      expect(res.headers['content-type'], 'application/pdf');
      expect(res.headers['x-generate-ms'], isNotNull);
      expect(ascii.decode(res.bodyBytes.sublist(0, 5)), '%PDF-');
    });

    test('a bad template gives 422 with a message', () async {
      http.Response res = await api.post(
        '/api/pdfme/generate',
        <String, dynamic>{
          'template': <String, dynamic>{'schemas': <dynamic>[]},
          'inputs': <dynamic>[<String, dynamic>{}],
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res)['message'], isNotEmpty);
    });

    test('inputs that are not a list give 422', () async {
      http.Response res = await api.post(
        '/api/pdfme/generate',
        <String, dynamic>{'template': <String, dynamic>{}, 'inputs': 'nope'},
      );
      expect(res.statusCode, 422);
    });
  });
}
