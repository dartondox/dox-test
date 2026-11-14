/// Fonts of the pdfme playground: font name to file on disk.
/// The server loads them by name. The browser gets them from `/fonts/FILE`.
/// Roboto is not here: dox_pdf_me has it built in (the fallback font).
const Map<String, String> pdfmeFonts = <String, String>{
  'NotoSansMyanmar': 'public/fonts/NotoSansMyanmar-Regular.ttf',
};
