import 'dart:io';

import 'package:flutter/material.dart' as pw;
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'grahps.dart';
import 'package:path_provider/path_provider.dart';

class PdfParagraphApi {
  String dataType;
  List<dynamic> readings;
  String str = '';

  PdfParagraphApi(this.readings, this.dataType) {
    for (int i = 0; i < readings.length; i++) {
      str += (i + 1).toString() +
          '   ' +
          readings[i]['recored'].toString() +
          '   ' +
          readings[i]['date'].toString() +
          '\n';
    }
    startMethod();
  }

  Future<void> startMethod() async {
    final pdfFile = await generate();
    openFile(pdfFile);
  }

  Future<File> generate() async {
    final pdf = Document();

    final customFont =
        Font.ttf(await rootBundle.load('assets/OpenSans-Regular.ttf'));

    pdf.addPage(
      MultiPage(
        build: (context) => <Widget>[
          buildCustomHeader(),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
          Paragraph(
            text: 'History',
            style: TextStyle(font: customFont, fontSize: 20),
          ),
          //   buildCustomHeadline(),
          Header(child: Text('Records')),
          Paragraph(text: str),
        ],
        footer: (context) {
          final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

          return Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 1 * PdfPageFormat.cm),
            child: Text(
              text,
              style: TextStyle(color: PdfColors.black),
            ),
          );
        },
      ),
    );
    return saveDocument(name: 'RecordHistory.pdf', pdf: pdf);
  }

  Widget buildCustomHeader() => Container(
        padding: EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: PdfColors.blue)),
        ),
        child: Row(
          children: [
            SizedBox(width: 0.5 * PdfPageFormat.cm),
            Text(
              'Health Assasnt',
              style: TextStyle(fontSize: 20, color: PdfColors.blue),
            ),
          ],
        ),
      );

  Future<File> saveDocument({
    String name,
    Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
