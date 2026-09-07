import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ArrearCalculatorApp());
}

class ArrearCalculatorApp extends StatelessWidget {
  const ArrearCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amin Arrear Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        textTheme: GoogleFonts.barlowSemiCondensedTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      home: const ArrearHomePage(),
    );
  }
}

class MonthRecord {
  final String monthName;
  final String remarks;

  double admBasic = 0, admDp = 0, admSp = 0, admDa = 0, admHra = 0, admMa = 300;
  double admCpf = 0, admPtax = 150, admGpf = 1500, admItax = 0;

  double drwBasic = 0, drwDp = 0, drwSp = 0, drwDa = 0, drwHra = 0, drwMa = 300;
  double drwCpf = 0, drwPtax = 150, drwGpf = 1500, drwItax = 0;

  MonthRecord({required this.monthName, this.remarks = ''});

  double get admGross => admBasic + admDp + admSp + admDa + admHra + admMa;
  double get admDeductions => admCpf + admPtax + admGpf + admItax;
  double get admNet => admGross - admDeductions;

  double get drwGross => drwBasic + drwDp + drwSp + drwDa + drwHra + drwMa;
  double get drwDeductions => drwCpf + drwPtax + drwGpf + drwItax;
  double get drwNet => drwGross - drwDeductions;

  double get dueBasic => admBasic - drwBasic;
  double get dueDp => admDp - drwDp;
  double get dueSp => admSp - drwSp;
  double get dueDa => admDa - drwDa;
  double get dueHra => admHra - drwHra;
  double get dueMa => admMa - drwMa;
  double get dueGross => admGross - drwGross;
  double get dueCpf => admCpf - drwCpf;
  double get duePtax => admPtax - drwPtax;
  double get dueGpf => admGpf - drwGpf;
  double get dueItax => admItax - drwItax;
  double get dueNet => admNet - drwNet;
}

class ArrearHomePage extends StatefulWidget {
  const ArrearHomePage({super.key});

  @override
  State<ArrearHomePage> createState() => _ArrearHomePageState();
}

class _ArrearHomePageState extends State<ArrearHomePage> {
  final instController = TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final indexController = TextEditingController(text: "B3-083");
  final hsCodeController = TextEditingController(text: "103280");
  final empNameController = TextEditingController(text: "SANDEEP SARKAR");
  final desigController = TextEditingController(text: "A.T.");
  final fromDateController = TextEditingController(text: "01.07.2013");
  final toDateController = TextEditingController(text: "30.06.2018");
  final empIdController = TextEditingController(text: "EYM08650");
  final orderNoController = TextEditingController(text: "118-SE/S/10M-29/16 Date: 06.02.2018.");
  final scaleController = TextEditingController();

  double balBasic = 0, balDa = 0, balHra = 0, balGross = 0, balNet = 0;
  double adHoc1 = 0, adHoc2 = 0, adHoc3 = 0, adHoc4 = 0;
  final passedForWordsController = TextEditingController(text: "ZERO ONLY");

  List<MonthRecord> records = [];

  @override
  void initState() {
    super.initState();
    _initRecords();
  }

  void _initRecords() {
    List<String> months = [
      "March,13", "April,13", "May,13", "June,13", "July,13", "August,13", "September,13",
      "October,13", "November,13", "December,13", "January,14", "February,14",
      "March,14", "April,14", "May,14", "June,14", "July,14", "August,14", "September,14",
      "October,14", "November,14", "December,14", "January,15", "February,15"
    ];

    records = months.map((m) {
      String rem = '';
      if (m == "July,13") rem = "52%";
      if (m == "January,14" || m == "July,14") rem = "58%";
      if (m == "January,15" || m == "July,15") rem = "65%";
      if (m == "January,16" || m == "July,16") rem = "75%";
      if (m == "January,17" || m == "July,17") rem = "85%";
      if (m == "January,18" || m == "July,18") rem = "100%";

      var r = MonthRecord(monthName: m, remarks: rem);
      r.admBasic = 15280;
      r.drwBasic = 15280;
      r.admDa = 8851;
      r.drwDa = 8851;
      r.admHra = 2289;
      r.drwHra = 2289;
      return r;
    }).toList();
  }

  double get totBasic => records.fold(0, (sum, r) => sum + r.dueBasic);
  double get totDa => records.fold(0, (sum, r) => sum + r.dueDa);
  double get totHra => records.fold(0, (sum, r) => sum + r.dueHra);
  double get totGross => records.fold(0, (sum, r) => sum + r.dueGross);
  double get totNet => records.fold(0, (sum, r) => sum + r.dueNet);

  double get grandBasic => totBasic - balBasic;
  double get grandDa => totDa - balDa;
  double get grandHra => totHra - balHra;
  double get grandGross => totGross - balGross;
  double get grandNet => totNet - balNet;

  double get totalAdHoc => adHoc1 + adHoc2 + adHoc3 + adHoc4;
  double get actualClaim => grandNet - totalAdHoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amin Arrear Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Calculation Sheet (Portrait A4)',
            onPressed: () => _printCalculationSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Final Sheet (Landscape A4)',
            onPressed: () => _printFinalSheet(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildHeaderTable(),
            const SizedBox(height: 12),
            _buildScaleRow(),
            const SizedBox(height: 12),
            _buildCalculationTable(),
            const SizedBox(height: 20),
            _buildFooterSignatures(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTable() {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1.2),
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(3.5),
        2: FlexColumnWidth(2.0),
        3: FlexColumnWidth(2.0),
      },
      children: [
        _buildTableRow("NAME OF THE INSTITUTION:", instController, "INDEX NO :", indexController),
        _buildTableRow("NAME OF THE EMPLOYEE:", empNameController, "DESIGNATION:", desigController),
        TableRow(
          children: [
            _headerCell("ARREAR FOR THE PERIOD:"),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(child: _centerTextField(fromDateController)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: _centerTextField(toDateController)),
                ],
              ),
            ),
            _headerCell("EMPLOYEE ID:"),
            Padding(
              padding: const EdgeInsets.all(4),
              child: _centerTextField(empIdController),
            ),
          ],
        ),
        TableRow(
          children: [
            _headerCell("IN TERMS OF ORDER NO.:"),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _centerTextField(orderNoController),
              ),
            ),
            _headerCell("H.S. CODE:"),
            Padding(
              padding: const EdgeInsets.all(4),
              child: _centerTextField(hsCodeController),
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label1, TextEditingController ctrl1, String label2, TextEditingController ctrl2) {
    return TableRow(
      children: [
        _headerCell(label1),
        Padding(padding: const EdgeInsets.all(4), child: _centerTextField(ctrl1)),
        _headerCell(label2),
        Padding(padding: const EdgeInsets.all(4), child: _centerTextField(ctrl2)),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.all(6),
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _centerTextField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0)),
      ),
    );
  }

  Widget _buildScaleRow() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.2)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey.shade300,
            child: const Text("SCALE ADMISSIBLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: scaleController,
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: Colors.black, width: 1.2),
        columnWidths: const {
          0: FixedColumnWidth(80),
          1: FixedColumnWidth(80),
          2: FixedColumnWidth(70),
          3: FixedColumnWidth(55),
          4: FixedColumnWidth(50),
          5: FixedColumnWidth(65),
          6: FixedColumnWidth(60),
          7: FixedColumnWidth(50),
          8: FixedColumnWidth(70),
          9: FixedColumnWidth(55),
          10: FixedColumnWidth(55),
          11: FixedColumnWidth(55),
          12: FixedColumnWidth(55),
          13: FixedColumnWidth(70),
          14: FixedColumnWidth(75),
        },
        children: [
          _buildColumnHeader(),
          for (var r in records) ..._buildMonthRows(r),
          _buildTotalRow("TOTAL:", totBasic, totDa, totHra, totGross, totNet),
          _buildBalanceRow(),
          _buildGrandTotalRow(),
        ],
      ),
    );
  }

  TableRow _buildColumnHeader() {
    final headers = [
      "MONTH", "Admissible/\nDrawn & Due", "BASIC PAY", "D.P/IR", "S.P",
      "D.A", "H.R.A", "M.A", "GROSS", "C.P.F", "P.TAX", "G.P.F", "I.TAX", "NET", "REMARKS"
    ];
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade400),
      children: headers.map((h) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        alignment: Alignment.center,
        child: Text(h, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
      )).toList(),
    );
  }

  List<TableRow> _buildMonthRows(MonthRecord r) {
    return [
      TableRow(
        children: [
          Container(alignment: Alignment.center, padding: const EdgeInsets.all(4), child: Text(r.monthName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          _cell("Admissible"),
          _numCell(r.admBasic), _numCell(r.admDp), _numCell(r.admSp), _numCell(r.admDa), _numCell(r.admHra), _numCell(r.admMa),
          _numCell(r.admGross), _numCell(r.admCpf), _numCell(r.admPtax), _numCell(r.admGpf), _numCell(r.admItax), _numCell(r.admNet),
          _cell(""),
        ],
      ),
      TableRow(
        children: [
          _cell(""),
          _cell("Drawn"),
          _numCell(r.drwBasic), _numCell(r.drwDp), _numCell(r.drwSp), _numCell(r.drwDa), _numCell(r.drwHra), _numCell(r.drwMa),
          _numCell(r.drwGross), _numCell(r.drwCpf), _numCell(r.drwPtax), _numCell(r.drwGpf), _numCell(r.drwItax), _numCell(r.drwNet),
          _cell(r.remarks, isBold: true),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        children: [
          _cell(""),
          _cell("Due", isBold: true),
          _numCell(r.dueBasic, isBold: true), _numCell(r.dueDp, isBold: true), _numCell(r.dueSp, isBold: true), _numCell(r.dueDa, isBold: true), _numCell(r.dueHra, isBold: true), _numCell(r.dueMa, isBold: true),
          _numCell(r.dueGross, isBold: true), _numCell(r.dueCpf, isBold: true), _numCell(r.duePtax, isBold: true), _numCell(r.dueGpf, isBold: true), _numCell(r.dueItax, isBold: true), _numCell(r.dueNet, isBold: true),
          _cell(""),
        ],
      ),
    ];
  }

  TableRow _buildTotalRow(String title, double b, double da, double hra, double gross, double net) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _cell(title, isBold: true),
        _cell(""),
        _numCell(b, isBold: true), _cell(""), _cell(""),
        _numCell(da, isBold: true), _numCell(hra, isBold: true), _cell(""),
        _numCell(gross, isBold: true), _cell(""), _cell(""), _cell(""), _cell(""),
        _numCell(net, isBold: true), _cell(""),
      ],
    );
  }

  TableRow _buildBalanceRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _cell("BALANCE:", isBold: true),
        _cell(""),
        _editableBalanceCell(balBasic, (v) => setState(() => balBasic = v)),
        _cell(""), _cell(""),
        _editableBalanceCell(balDa, (v) => setState(() => balDa = v)),
        _editableBalanceCell(balHra, (v) => setState(() => balHra = v)),
        _cell(""),
        _editableBalanceCell(balGross, (v) => setState(() => balGross = v)),
        _cell(""), _cell(""), _cell(""), _cell(""),
        _editableBalanceCell(balNet, (v) => setState(() => balNet = v)),
        _cell(""),
      ],
    );
  }

  TableRow _buildGrandTotalRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade400),
      children: [
        _cell("GRAND TOTAL:", isBold: true),
        _cell(""),
        _numCell(grandBasic, isBold: true), _cell(""), _cell(""),
        _numCell(grandDa, isBold: true), _numCell(grandHra, isBold: true), _cell(""),
        _numCell(grandGross, isBold: true), _cell(""), _cell(""), _cell(""), _cell(""),
        _numCell(grandNet, isBold: true), _cell(""),
      ],
    );
  }

  Widget _cell(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      alignment: Alignment.center,
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _numCell(double val, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      alignment: Alignment.center,
      child: Text(val.toInt().toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _editableBalanceCell(double val, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: TextFormField(
        initialValue: val.toInt().toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _buildFooterSignatures() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Center(
          child: Text("Verified and found correct.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Date: ....................", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  // PORTRAIT PDF (Calculation Sheet)
  Future<void> _printCalculationSheet() async {
    final doc = pw.Document();
    final customFont = await PdfGoogleFonts.barlowSemiCondensedSemiBold();
    final theme = pw.ThemeData.withFont(base: customFont, bold: customFont);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text("ANNEXURE - 1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          ),
          pw.SizedBox(height: 5),
          _buildPdfHeader(),
          pw.SizedBox(height: 5),
          _buildPdfScale(),
          pw.SizedBox(height: 5),
          _buildPdfTable(),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text("Verified and found correct.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Date: ....................", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
              pw.Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
            ],
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildPdfHeader() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(3.5),
        2: pw.FlexColumnWidth(2.0),
        3: pw.FlexColumnWidth(2.0),
      },
      children: [
        pw.TableRow(children: [
          _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValCell(instController.text),
          _pdfHCell("INDEX NO:"), _pdfValCell(indexController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValCell(empNameController.text),
          _pdfHCell("DESIGNATION:"), _pdfValCell(desigController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("ARREAR FOR THE PERIOD:"),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Center(child: pw.Text("${fromDateController.text}   TO   ${toDateController.text}", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
          ),
          _pdfHCell("EMPLOYEE ID:"), _pdfValCell(empIdController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValCell(orderNoController.text),
          _pdfHCell("H.S. CODE:"), _pdfValCell(hsCodeController.text),
        ]),
      ],
    );
  }

  pw.Widget _pdfHCell(String t) => pw.Container(
    color: PdfColors.grey300,
    padding: const pw.EdgeInsets.all(3),
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfValCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: pw.Center(child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
  );

  pw.Widget _buildPdfScale() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.0)),
      child: pw.Row(
        children: [
          pw.Container(
            color: PdfColors.grey300,
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: pw.Text("SCALE ADMISSIBLE", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 5),
              child: pw.Text(scaleController.text, style: const pw.TextStyle(fontSize: 7.5)),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable() {
    final headers = [
      "MONTH", "Admissible/\nDrawn & Due", "BASIC PAY", "D.P/IR", "S.P",
      "D.A", "H.R.A", "M.A", "GROSS", "C.P.F", "P.TAX", "G.P.F", "I.TAX", "NET", "REMARKS"
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey400),
          children: headers.map((h) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            alignment: pw.Alignment.center,
            child: pw.Text(h, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 6.2, fontWeight: pw.FontWeight.bold)),
          )).toList(),
        ),
        for (var r in records) ...[
          pw.TableRow(children: [
            _pCell(r.monthName, isBold: true), _pCell("Admissible"),
            _pNum(r.admBasic), _pNum(r.admDp), _pNum(r.admSp), _pNum(r.admDa), _pNum(r.admHra), _pNum(r.admMa),
            _pNum(r.admGross), _pNum(r.admCpf), _pNum(r.admPtax), _pNum(r.admGpf), _pNum(r.admItax), _pNum(r.admNet), _pCell(""),
          ]),
          pw.TableRow(children: [
            _pCell(""), _pCell("Drawn"),
            _pNum(r.drwBasic), _pNum(r.drwDp), _pNum(r.drwSp), _pNum(r.drwDa), _pNum(r.drwHra), _pNum(r.drwMa),
            _pNum(r.drwGross), _pNum(r.drwCpf), _pNum(r.drwPtax), _pNum(r.drwGpf), _pNum(r.drwItax), _pNum(r.drwNet), _pCell(r.remarks, isBold: true),
          ]),
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              _pCell(""), _pCell("Due", isBold: true),
              _pNum(r.dueBasic, isBold: true), _pNum(r.dueDp, isBold: true), _pNum(r.dueSp, isBold: true), _pNum(r.dueDa, isBold: true), _pNum(r.dueHra, isBold: true), _pNum(r.dueMa, isBold: true),
              _pNum(r.dueGross, isBold: true), _pNum(r.dueCpf, isBold: true), _pNum(r.duePtax, isBold: true), _pNum(r.dueGpf, isBold: true), _pNum(r.dueItax, isBold: true), _pNum(r.dueNet, isBold: true), _pCell(""),
            ],
          ),
        ],
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pCell("TOTAL:", isBold: true), _pCell(""),
            _pNum(totBasic, isBold: true), _pCell(""), _pCell(""), _pNum(totDa, isBold: true), _pNum(totHra, isBold: true), _pCell(""),
            _pNum(totGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(totNet, isBold: true), _pCell(""),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pCell("BALANCE:", isBold: true), _pCell(""),
            _pNum(balBasic, isBold: true), _pCell(""), _pCell(""), _pNum(balDa, isBold: true), _pNum(balHra, isBold: true), _pCell(""),
            _pNum(balGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(balNet, isBold: true), _pCell(""),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey400),
          children: [
            _pCell("GRAND TOTAL:", isBold: true), _pCell(""),
            _pNum(grandBasic, isBold: true), _pCell(""), _pCell(""), _pNum(grandDa, isBold: true), _pNum(grandHra, isBold: true), _pCell(""),
            _pNum(grandGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(grandNet, isBold: true), _pCell(""),
          ],
        ),
      ],
    );
  }

  pw.Widget _pCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    alignment: pw.Alignment.center,
    child: pw.Text(t, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 6.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pNum(double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    alignment: pw.Alignment.center,
    child: pw.Text(val.toInt().toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 6.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  // LANDSCAPE PDF (Final Sheet: ANNEXURE - 1 CONTINUED)
  Future<void> _printFinalSheet() async {
    final doc = pw.Document();
    final customFont = await PdfGoogleFonts.barlowSemiCondensedSemiBold();
    final theme = pw.ThemeData.withFont(base: customFont, bold: customFont);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: theme,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.SizedBox(width: 50),
                  pw.Text("ANNEXURE - 1 (CONTINUED)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.Text("Final Page", style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.0),
                  1: pw.FlexColumnWidth(3.5),
                  2: pw.FlexColumnWidth(1.2),
                  3: pw.FlexColumnWidth(1.2),
                  4: pw.FlexColumnWidth(1.2),
                  5: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(children: [
                    _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValCell(instController.text),
                    _pdfHCell("INDEX NO :"), _pdfValCell(indexController.text),
                    _pdfHCell("H.S. CODE :"), _pdfValCell(hsCodeController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValCell(empNameController.text),
                    _pdfHCell("DESIGNATION:"), _pdfValCell(desigController.text),
                    _pdfHCell("EMPLOYEE ID:"), _pdfValCell(empIdController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("ARREAR FOR THE PERIOD:"),
                    pw.Center(child: pw.Text("${fromDateController.text}   TO   ${toDateController.text}", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                    _pdfHCell(""), _pdfValCell(""),
                    _pdfHCell(""), _pdfValCell(""),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValCell(orderNoController.text),
                    _pdfHCell(""), _pdfValCell(""),
                    _pdfHCell(""), _pdfValCell(""),
                  ]),
                ],
              ),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                columnWidths: const {
                  0: pw.FlexColumnWidth(7.0),
                  1: pw.FlexColumnWidth(1.2),
                  2: pw.FlexColumnWidth(4.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Center(child: pw.Text("ARREAR DUE ON ACCOUNT OF:", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                      pw.Center(child: pw.Text("IN RS.", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                      pw.Center(child: pw.Text("TO BE CREDITED TO:", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                            children: [
                              _pCell("BASIC PAY", isBold: true),
                              _pCell("D.P/IR/S.P", isBold: true),
                              _pCell("D.A", isBold: true),
                              _pCell("H.R.A", isBold: true),
                              _pCell("M.A", isBold: true),
                              _pCell("Gross", isBold: true),
                              _pCell("C.P.F/G.P.F", isBold: true),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _pNum(grandBasic),
                              _pNum(0),
                              _pNum(grandDa),
                              _pNum(grandHra),
                              _pNum(0),
                              _pNum(grandGross),
                              _pNum(0),
                            ],
                          ),
                        ],
                      ),
                      pw.Container(),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                            children: [
                              _pCell("P.TAX", isBold: true),
                              _pCell("G.P.F/C.P.F", isBold: true),
                              _pCell("OTHERS", isBold: true),
                              _pCell("NET CLAIM", isBold: true),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _pNum(0),
                              _pNum(0),
                              _pNum(0),
                              _pNum(grandNet),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.0)),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("In respect of Ist Grant-in-Aid by the School:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                          pw.Text("Paid under salary deficit Scheme.", style: const pw.TextStyle(fontSize: 7)),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            children: [
                              pw.Text("ARREAR :", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(width: 40),
                              pw.Text("FOR LATE APPROVAL", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text("CERTIFICATE THAT :-", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                          pw.Text("1. The amount claimed in this bill was not drawn before.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("2. The Carbon copy agrees with the fair copy of the bill.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("3. The claim has been preferred with reference to Acquittance Roll & other office records.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("4. Necessary notes have been kept in the O/C of bills from which it was omitted in order to avoid double payment in future.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("5. The incumbent has not enjoyed any E.O.L. during the period of arrear claimed or has enjoyed E.O.L. in the months of as stated in the remark column.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("6. Income Tax, G.P.F. if any will be deducted and deposited through challan.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("7. The admissibility of the arrear claim has been checked with reference to Govt. Orders.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("8. All relevant records and found in order.", style: const pw.TextStyle(fontSize: 6.5)),
                        ],
                      ),
                    ),
                  ),

                  pw.Expanded(
                    flex: 5,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text("LESS ANY AD-HOC PAYMENT MADE:", style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)))),
                          ],
                        ),
                        pw.TableRow(children: [_adHocRow("1", adHoc1)]),
                        pw.TableRow(children: [_adHocRow("2", adHoc2)]),
                        pw.TableRow(children: [_adHocRow("3", adHoc3)]),
                        pw.TableRow(children: [_adHocRow("4", adHoc4)]),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text("ACTUAL CLAIM:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(actualClaim.toInt().toString(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Row(
                                children: [
                                  pw.Text("PASSED FOR RS.: ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(actualClaim.toInt().toString(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("IN WORDS: ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(child: pw.Text(passedForWordsController.text, style: const pw.TextStyle(fontSize: 6.5))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Signature of Secretary/Administrator/D.D.O.", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Signature of D.I./A.D.I. of Schools (S.E.)", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("A.D./D.O.(Accounts)", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _adHocRow(String no, double val) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(no, style: const pw.TextStyle(fontSize: 7)),
          pw.Text(val == 0 ? "" : val.toInt().toString(), style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }
}
