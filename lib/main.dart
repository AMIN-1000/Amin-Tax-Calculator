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

class MonthEntry {
  final String monthName;
  final String fixedRemarks;
  final double daRate;

  TextEditingController admBasic = TextEditingController();
  TextEditingController admDp = TextEditingController();
  TextEditingController admSp = TextEditingController();
  TextEditingController admCpf = TextEditingController();
  TextEditingController admGpf = TextEditingController();
  TextEditingController admItax = TextEditingController();

  TextEditingController drwBasic = TextEditingController();
  TextEditingController drwDp = TextEditingController();
  TextEditingController drwSp = TextEditingController();
  TextEditingController drwCpf = TextEditingController();
  TextEditingController drwGpf = TextEditingController();
  TextEditingController drwItax = TextEditingController();

  TextEditingController admRemarks = TextEditingController();
  TextEditingController drwRemarks = TextEditingController();
  TextEditingController dueRemarks = TextEditingController();

  MonthEntry({required this.monthName, this.fixedRemarks = '', this.daRate = 0.52});

  String get effectiveAdmRemarks => fixedRemarks.isNotEmpty ? fixedRemarks : admRemarks.text.trim();
  String get effectiveDrwRemarks => drwRemarks.text.trim();
  String get effectiveDueRemarks => dueRemarks.text.trim();

  double _val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  bool _hasInput(TextEditingController c) => c.text.trim().isNotEmpty && double.tryParse(c.text.trim()) != null;

  bool get hasAdm => _hasInput(admBasic);
  bool get hasDrw => _hasInput(drwBasic);
  bool get hasAny => hasAdm || hasDrw;

  // ---------------- ADMISSIBLE CALCULATIONS ----------------
  double get aBasic => _val(admBasic);
  double get aDp => _val(admDp);
  double get aSp => _val(admSp);
  double get aDa => hasAdm ? ((aBasic + aDp) * daRate).roundToDouble() : 0;
  double get aHra => hasAdm ? (((aBasic + aDp) * 0.15).clamp(0, 6000)).roundToDouble() : 0;
  double get aMa => hasAdm ? 300 : 0;
  double get aGross => hasAdm ? (aBasic + aDp + aSp + aDa + aHra + aMa) : 0;
  double get aCpf => _val(admCpf);
  double get aPtax => hasAdm ? (aGross > 15000 ? 150 : 130) : 0;
  double get aGpf => _val(admGpf);
  double get aItax => _val(admItax);
  double get aNet => hasAdm ? (aGross - (aCpf + aPtax + aGpf + aItax)) : 0;

  // ---------------- DRAWN CALCULATIONS ----------------
  double get dBasic => _val(drwBasic);
  double get dDp => _val(drwDp);
  double get dSp => _val(drwSp);
  double get dDa => hasDrw ? ((dBasic + dDp) * daRate).roundToDouble() : 0;
  double get dHra => hasDrw ? (((dBasic + dDp) * 0.15).clamp(0, 6000)).roundToDouble() : 0;
  double get dMa => hasDrw ? 300 : 0;
  double get dGross => hasDrw ? (dBasic + dDp + dSp + dDa + dHra + dMa) : 0;
  double get dCpf => _val(drwCpf);
  double get dPtax => hasDrw ? (dGross > 15000 ? 150 : 130) : 0;
  double get dGpf => _val(drwGpf);
  double get dItax => _val(drwItax);
  double get dNet => hasDrw ? (dGross - (dCpf + dPtax + dGpf + dItax)) : 0;

  // ---------------- DUE CALCULATIONS ----------------
  double get dueBasic => hasAny ? (aBasic - dBasic) : 0;
  double get dueDp => hasAny ? (aDp - dDp) : 0;
  double get dueSp => hasAny ? (aSp - dSp) : 0;
  double get dueDa => hasAny ? (aDa - dDa) : 0;
  double get dueHra => hasAny ? (aHra - dHra) : 0;
  double get dueMa => hasAny ? (aMa - dMa) : 0;
  double get dueGross => hasAny ? (aGross - dGross) : 0;
  double get dueCpf => hasAny ? (aCpf - dCpf) : 0;
  double get duePtax => hasAny ? (aPtax - dPtax) : 0;
  double get dueGpf => hasAny ? (aGpf - dGpf) : 0;
  double get dueItax => hasAny ? (aItax - dItax) : 0;
  double get dueNet => hasAny ? (aNet - dNet) : 0;
}

class YearSheet {
  final int startYear;
  final int endYear;
  final String sheetTitle;
  final String periodText;
  final List<MonthEntry> records;

  final balBasicCtrl = TextEditingController();
  final balDpCtrl = TextEditingController();
  final balSpCtrl = TextEditingController();
  final balDaCtrl = TextEditingController();
  final balHraCtrl = TextEditingController();
  final balMaCtrl = TextEditingController();
  final balGrossCtrl = TextEditingController();
  final balCpfCtrl = TextEditingController();
  final balPtaxCtrl = TextEditingController();
  final balGpfCtrl = TextEditingController();
  final balItaxCtrl = TextEditingController();
  final balNetCtrl = TextEditingController();

  YearSheet({
    required this.startYear,
    required this.endYear,
    required this.sheetTitle,
    required this.periodText,
    required this.records,
  });

  bool get hasAnyInput => records.any((r) => r.hasAny);

  double _bVal(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  double get balBasic => _bVal(balBasicCtrl);
  double get balDp => _bVal(balDpCtrl);
  double get balSp => _bVal(balSpCtrl);
  double get balDa => _bVal(balDaCtrl);
  double get balHra => _bVal(balHraCtrl);
  double get balMa => _bVal(balMaCtrl);
  double get balGross => _bVal(balGrossCtrl);
  double get balCpf => _bVal(balCpfCtrl);
  double get balPtax => _bVal(balPtaxCtrl);
  double get balGpf => _bVal(balGpfCtrl);
  double get balItax => _bVal(balItaxCtrl);
  double get balNet => _bVal(balNetCtrl);

  double get totBasic => records.fold(0, (s, r) => s + r.dueBasic);
  double get totDp => records.fold(0, (s, r) => s + r.dueDp);
  double get totSp => records.fold(0, (s, r) => s + r.dueSp);
  double get totDa => records.fold(0, (s, r) => s + r.dueDa);
  double get totHra => records.fold(0, (s, r) => s + r.dueHra);
  double get totMa => records.fold(0, (s, r) => s + r.dueMa);
  double get totGross => records.fold(0, (s, r) => s + r.dueGross);
  double get totCpf => records.fold(0, (s, r) => s + r.dueCpf);
  double get totPtax => records.fold(0, (s, r) => s + r.duePtax);
  double get totGpf => records.fold(0, (s, r) => s + r.dueGpf);
  double get totItax => records.fold(0, (s, r) => s + r.dueItax);
  double get totNet => records.fold(0, (s, r) => s + r.dueNet);

  double get grandBasic => totBasic - balBasic;
  double get grandDp => totDp - balDp;
  double get grandSp => totSp - balSp;
  double get grandDa => totDa - balDa;
  double get grandHra => totHra - balHra;
  double get grandMa => totMa - balMa;
  double get grandGross => totGross - balGross;
  double get grandCpf => totCpf - balCpf;
  double get grandPtax => totPtax - balPtax;
  double get grandGpf => totGpf - balGpf;
  double get grandItax => totItax - balItax;
  double get grandNet => totNet - balNet;
}

class ArrearHomePage extends StatefulWidget {
  const ArrearHomePage({super.key});

  @override
  State<ArrearHomePage> createState() => _ArrearHomePageState();
}

class _ArrearHomePageState extends State<ArrearHomePage> with TickerProviderStateMixin {
  final instController = TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final indexController = TextEditingController(text: "B3-083");
  final hsCodeController = TextEditingController(text: "103280");
  final empNameController = TextEditingController(text: "SANJOY SAHA");
  final desigController = TextEditingController(text: "A.T.");
  final fromDateController = TextEditingController(text: "01.03.2013");
  final toDateController = TextEditingController(text: "28.02.2018");
  final empIdController = TextEditingController(text: "EYM08650");
  final orderNoController = TextEditingController(text: "118-SE/S/10M-29/16 Date: 06.02.2018.");
  final scaleController = TextEditingController();

  final adHoc1Ctrl = TextEditingController();
  final adHoc2Ctrl = TextEditingController();
  final adHoc3Ctrl = TextEditingController();
  final adHoc4Ctrl = TextEditingController();

  late TabController _tabController;
  List<YearSheet> sheets = [];

  @override
  void initState() {
    super.initState();
    for (int yr = 2013; yr <= 2017; yr++) {
      sheets.add(_createYearSheet(yr, yr + 1));
    }
    _tabController = TabController(length: sheets.length, vsync: this);
  }

  YearSheet _createYearSheet(int startY, int endY) {
    int s2 = startY % 100;
    int e2 = endY % 100;
    String s2Str = s2.toString().padLeft(2, '0');
    String e2Str = e2.toString().padLeft(2, '0');

    final mNames = ["March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February"];
    List<MonthEntry> mList = [];

    for (int i = 0; i < 12; i++) {
      int y = i < 10 ? s2 : e2;
      String mStr = "${mNames[i]},$y";
      String rem = '';
      double da = 0.52;

      if (y == 13) {
        da = 0.52;
        if (mStr == "July,13") rem = "52%";
      } else if (y == 14) {
        da = 0.58;
        if (mStr == "January,14" || mStr == "July,14") rem = "58%";
      } else if (y == 15) {
        da = 0.65;
        if (mStr == "January,15" || mStr == "July,15") rem = "65%";
      } else if (y == 16) {
        da = 0.75;
        if (mStr == "January,16" || mStr == "July,16") rem = "75%";
      } else if (y == 17) {
        da = 0.85;
        if (mStr == "January,17" || mStr == "July,17") rem = "85%";
      } else if (y >= 18) {
        da = 1.00;
        if (mStr == "January,18" || mStr == "July,18") rem = "100%";
      }

      mList.add(MonthEntry(monthName: mStr, fixedRemarks: rem, daRate: da));
    }

    return YearSheet(
      startYear: startY,
      endYear: endY,
      sheetTitle: "Sheet ($startY-$e2Str)",
      periodText: "01.03.$startY TO 28.02.$endY",
      records: mList,
    );
  }

  void _addNewSheet() {
    int nextStart = sheets.isEmpty ? 2013 : sheets.last.endYear;
    int nextEnd = nextStart + 1;
    setState(() {
      sheets.add(_createYearSheet(nextStart, nextEnd));
      _tabController.dispose();
      _tabController = TabController(length: sheets.length, vsync: this, initialIndex: sheets.length - 1);
    });
  }

  void _removeLastSheet() {
    if (sheets.length <= 1) return;
    setState(() {
      sheets.removeLast();
      _tabController.dispose();
      _tabController = TabController(length: sheets.length, vsync: this, initialIndex: sheets.length - 1);
    });
  }

  double get allGrandBasic => sheets.fold(0, (s, sh) => s + sh.grandBasic);
  double get allGrandDp => sheets.fold(0, (s, sh) => s + sh.grandDp);
  double get allGrandSp => sheets.fold(0, (s, sh) => s + sh.grandSp);
  double get allGrandDa => sheets.fold(0, (s, sh) => s + sh.grandDa);
  double get allGrandHra => sheets.fold(0, (s, sh) => s + sh.grandHra);
  double get allGrandMa => sheets.fold(0, (s, sh) => s + sh.grandMa);
  double get allGrandGross => sheets.fold(0, (s, sh) => s + sh.grandGross);
  double get allGrandNet => sheets.fold(0, (s, sh) => s + sh.grandNet);

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');
      setState(() {
        controller.text = "$day.$month.${picked.year}";
      });
    }
  }

  static String numberToWordsIndian(int number) {
    if (number <= 0) return "";

    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    String convertLessThanThousand(int n) {
      List<String> res = [];
      if (n >= 100) {
        res.add("${units[n ~/ 100]} Hundred");
        n %= 100;
      }
      if (n >= 20) {
        res.add(tens[n ~/ 10]);
        n %= 10;
      }
      if (n > 0) {
        res.add(units[n]);
      }
      return res.join(" ");
    }

    List<String> result = [];
    int crores = number ~/ 10000000;
    number %= 10000000;
    int lakhs = number ~/ 100000;
    number %= 100000;
    int thousands = number ~/ 1000;
    number %= 1000;

    if (crores > 0) {
      result.add("${convertLessThanThousand(crores)} Crore");
    }
    if (lakhs > 0) {
      result.add("${convertLessThanThousand(lakhs)} Lakh");
    }
    if (thousands > 0) {
      result.add("${convertLessThanThousand(thousands)} Thousand");
    }
    if (number > 0) {
      result.add(convertLessThanThousand(number));
    }

    return "Rupees ${result.join(" ")} Only.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amin Arrear Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add_chart), tooltip: 'Add Sheet', onPressed: _addNewSheet),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Remove Sheet', onPressed: _removeLastSheet),
          IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'PDF (Portrait)', onPressed: () => _printCalculationSheets()),
          IconButton(icon: const Icon(Icons.print), tooltip: 'Final Sheet (Landscape)', onPressed: () => _printFinalSheet()),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: sheets.map((s) => Tab(text: s.sheetTitle)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: sheets.map((sh) => _buildSheetBody(sh)).toList(),
      ),
    );
  }

  Widget _buildSheetBody(YearSheet sh) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildHeaderTable(),
          const SizedBox(height: 10),
          _buildScaleRow(),
          const SizedBox(height: 10),
          _buildCalculationTable(sh),
          const SizedBox(height: 12),
          _buildFooterSignatures(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeaderTable() {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1.2),
      columnWidths: const {
        0: FlexColumnWidth(2.3),
        1: FlexColumnWidth(3.7),
        2: FlexColumnWidth(1.8),
        3: FlexColumnWidth(2.2),
      },
      children: [
        TableRow(
          children: [
            _headerCell("NAME OF THE INSTITUTION:"),
            Padding(padding: const EdgeInsets.all(4), child: _leftTextField(instController)),
            _headerCell("INDEX NO :"),
            Padding(padding: const EdgeInsets.all(4), child: _centerTextField(indexController)),
          ],
        ),
        TableRow(
          children: [
            _headerCell("NAME OF THE EMPLOYEE:"),
            Padding(padding: const EdgeInsets.all(4), child: _leftTextField(empNameController)),
            _headerCell("DESIGNATION:"),
            Padding(padding: const EdgeInsets.all(4), child: _centerTextField(desigController)),
          ],
        ),
        TableRow(
          children: [
            _headerCell("ARREAR FOR THE PERIOD:"),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(fromDateController),
                      child: IgnorePointer(child: _centerTextField(fromDateController)),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("TO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(toDateController),
                      child: IgnorePointer(child: _centerTextField(toDateController)),
                    ),
                  ),
                ],
              ),
            ),
            _headerCell("EMPLOYEE ID:"),
            Padding(padding: const EdgeInsets.all(4), child: _centerTextField(empIdController)),
          ],
        ),
        TableRow(
          children: [
            _headerCell("IN TERMS OF ORDER NO.:"),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(padding: const EdgeInsets.all(4), child: _leftTextField(orderNoController)),
            ),
            _headerCell("H.S. CODE:"),
            Padding(padding: const EdgeInsets.all(4), child: _centerTextField(hsCodeController)),
          ],
        ),
      ],
    );
  }

  Widget _headerCell(String t) => Container(
    color: Colors.grey.shade300,
    padding: const EdgeInsets.all(6),
    alignment: Alignment.centerLeft,
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
  );

  Widget _leftTextField(TextEditingController ctrl) => TextField(
    controller: ctrl,
    textAlign: TextAlign.left,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0)),
    ),
  );

  Widget _centerTextField(TextEditingController ctrl) => TextField(
    controller: ctrl,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0)),
    ),
  );

  Widget _buildScaleRow() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.2)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Text(
              "SCALE ADMISSIBLE",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: TextField(
              controller: scaleController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Enter Scale Here",
                hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationTable(YearSheet sh) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: Colors.black, width: 1.2),
        columnWidths: const {
          0: FixedColumnWidth(85),
          1: FixedColumnWidth(85),
          2: FixedColumnWidth(75),
          3: FixedColumnWidth(55),
          4: FixedColumnWidth(50),
          5: FixedColumnWidth(65),
          6: FixedColumnWidth(60),
          7: FixedColumnWidth(50),
          8: FixedColumnWidth(70),
          9: FixedColumnWidth(55),
          10: FixedColumnWidth(55),
          11: FixedColumnWidth(60),
          12: FixedColumnWidth(55),
          13: FixedColumnWidth(70),
          14: FixedColumnWidth(85),
        },
        children: [
          _buildColumnHeader(),
          for (var r in sh.records) ..._buildMonthRows(r),
          _buildTotalRow(sh),
          _buildBalanceRow(sh),
          _buildGrandTotalRow(sh),
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        child: Text(h, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
      )).toList(),
    );
  }

  List<TableRow> _buildMonthRows(MonthEntry r) {
    return [
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6, top: 4),
            alignment: Alignment.topLeft,
            child: Text(r.monthName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          _labelCell("Admissible"),
          _unlockedCell(r.admBasic),
          _unlockedCell(r.admDp),
          _unlockedCell(r.admSp),
          _conditionalCalcCell(r.hasAdm, r.aDa),
          _conditionalCalcCell(r.hasAdm, r.aHra),
          _conditionalCalcCell(r.hasAdm, r.aMa),
          _conditionalCalcCell(r.hasAdm, r.aGross, isBold: true),
          _unlockedCell(r.admCpf),
          _conditionalCalcCell(r.hasAdm, r.aPtax),
          _unlockedCell(r.admGpf),
          _unlockedCell(r.admItax),
          _conditionalCalcCell(r.hasAdm, r.aNet, isBold: true),
          r.fixedRemarks.isNotEmpty
              ? _labelCell(r.fixedRemarks, isBold: true)
              : _unlockedTextCell(r.admRemarks),
        ],
      ),
      TableRow(
        children: [
          _labelCell(""),
          _labelCell("Drawn"),
          _unlockedCell(r.drwBasic),
          _unlockedCell(r.drwDp),
          _unlockedCell(r.drwSp),
          _conditionalCalcCell(r.hasDrw, r.dDa),
          _conditionalCalcCell(r.hasDrw, r.dHra),
          _conditionalCalcCell(r.hasDrw, r.dMa),
          _conditionalCalcCell(r.hasDrw, r.dGross, isBold: true),
          _unlockedCell(r.drwCpf),
          _conditionalCalcCell(r.hasDrw, r.dPtax),
          _unlockedCell(r.drwGpf),
          _unlockedCell(r.drwItax),
          _conditionalCalcCell(r.hasDrw, r.dNet, isBold: true),
          _unlockedTextCell(r.drwRemarks),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        children: [
          _labelCell(""),
          _labelCell("Due", isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueBasic, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueDp, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueSp, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueDa, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueHra, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueMa, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueGross, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueCpf, isBold: true),
          _conditionalCalcCell(r.hasAny, r.duePtax, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueGpf, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueItax, isBold: true),
          _conditionalCalcCell(r.hasAny, r.dueNet, isBold: true),
          _unlockedTextCell(r.dueRemarks),
        ],
      ),
    ];
  }

  Widget _unlockedCell(TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5),
          border: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _unlockedTextCell(TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5),
          border: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _conditionalCalcCell(bool condition, double val, {bool isBold = false}) {
    return Container(
      color: isBold ? Colors.transparent : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      child: Text(
        condition ? val.round().toString() : "",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _labelCell(String t, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      alignment: Alignment.center,
      child: Text(
        t,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _leftLabelCell(String t, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.only(left: 6, top: 5, bottom: 5),
      alignment: Alignment.centerLeft,
      child: Text(t, textAlign: TextAlign.left, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _condSummaryCell(bool hasInput, double val, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: Text(
        hasInput ? val.round().toString() : "",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  TableRow _buildTotalRow(YearSheet sh) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _leftLabelCell("TOTAL:", isBold: true),
        _labelCell(""),
        _condSummaryCell(sh.hasAnyInput, sh.totBasic, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totDp, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totSp, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totDa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totHra, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totMa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totGross, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totCpf, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totPtax, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totGpf, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totItax, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.totNet, isBold: true),
        _labelCell(""),
      ],
    );
  }

  TableRow _buildBalanceRow(YearSheet sh) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _leftLabelCell("BALANCE:", isBold: true),
        _labelCell(""),
        _unlockedCell(sh.balBasicCtrl),
        _unlockedCell(sh.balDpCtrl),
        _unlockedCell(sh.balSpCtrl),
        _unlockedCell(sh.balDaCtrl),
        _unlockedCell(sh.balHraCtrl),
        _unlockedCell(sh.balMaCtrl),
        _unlockedCell(sh.balGrossCtrl),
        _unlockedCell(sh.balCpfCtrl),
        _unlockedCell(sh.balPtaxCtrl),
        _unlockedCell(sh.balGpfCtrl),
        _unlockedCell(sh.balItaxCtrl),
        _unlockedCell(sh.balNetCtrl),
        _labelCell(""),
      ],
    );
  }

  TableRow _buildGrandTotalRow(YearSheet sh) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade400),
      children: [
        _leftLabelCell("GRAND TOTAL:", isBold: true),
        _labelCell(""),
        _condSummaryCell(sh.hasAnyInput, sh.grandBasic, isBold: true),
        _condSummaryCell(sh.grandDp != 0, sh.grandDp, isBold: true),
        _condSummaryCell(sh.grandSp != 0, sh.grandSp, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandDa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandHra, isBold: true),
        _condSummaryCell(sh.grandMa != 0, sh.grandMa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandGross, isBold: true),
        _condSummaryCell(sh.grandCpf != 0, sh.grandCpf, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandPtax, isBold: true),
        _condSummaryCell(sh.grandGpf != 0, sh.grandGpf, isBold: true),
        _condSummaryCell(sh.grandItax != 0, sh.grandItax, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandNet, isBold: true),
        _labelCell(""),
      ],
    );
  }

  Widget _buildFooterSignatures() {
    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text("Date: ....................", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text("Verified and found correct.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 25),
                Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- PORTRAIT CALCULATION SHEETS PDF ----------------
  Future<void> _printCalculationSheets() async {
    final doc = pw.Document();
    final customFont = await PdfGoogleFonts.barlowSemiCondensedSemiBold();
    final theme = pw.ThemeData.withFont(base: customFont, bold: customFont);

    for (var sh in sheets) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.only(
            top: 45.4,
            left: 22.7,
            right: 22.7,
            bottom: 28.3,
          ),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("ANNEXURE - 1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12.0)),
              ),
              pw.SizedBox(height: 4),
              _buildPdfHeader(sh.periodText),
              pw.SizedBox(height: 3),
              _buildPdfScale(),
              pw.SizedBox(height: 3),
              _buildPdfTable(sh),
              pw.SizedBox(height: 5.0),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text("Date: ....................", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Verified and found correct.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      pw.SizedBox(height: 48.0),
                      pw.Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Calculation_Sheet.pdf',
    );
  }

  pw.Widget _buildPdfHeader(String periodText) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(3.5),
        2: pw.FlexColumnWidth(2.0),
        3: pw.FlexColumnWidth(2.0),
      },
      children: [
        pw.TableRow(children: [
          _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValLeftCell(instController.text),
          _pdfHCell("INDEX NO:"), _pdfValCenterCell(indexController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValLeftCell(empNameController.text),
          _pdfHCell("DESIGNATION:"), _pdfValCenterCell(desigController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("ARREAR FOR THE PERIOD:"),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
            child: pw.Center(child: pw.Text(periodText, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold))),
          ),
          _pdfHCell("EMPLOYEE ID:"), _pdfValCenterCell(empIdController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValLeftCell(orderNoController.text),
          _pdfHCell("H.S. CODE:"), _pdfValCenterCell(hsCodeController.text),
        ]),
      ],
    );
  }

  pw.Widget _pdfHCell(String t) => pw.Container(
    color: PdfColors.grey300,
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfValLeftCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
    child: pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold)),
    ),
  );

  pw.Widget _pdfValCenterCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3.5),
    child: pw.Center(
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold)),
    ),
  );

  pw.Widget _buildPdfScale() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      children: [
        pw.TableRow(
          children: [
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4.5),
              alignment: pw.Alignment.center,
              child: pw.Text("SCALE ADMISSIBLE", style: pw.TextStyle(fontSize: 8.0, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Container(
              height: 22.0,
              alignment: pw.Alignment.center,
              child: pw.Text(scaleController.text, style: const pw.TextStyle(fontSize: 7.2)),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfTable(YearSheet sh) {
    const colWidths = {
      0: pw.FlexColumnWidth(2.3),
      1: pw.FlexColumnWidth(2.4),
      2: pw.FlexColumnWidth(2.0),
      3: pw.FlexColumnWidth(1.4),
      4: pw.FlexColumnWidth(1.3),
      5: pw.FlexColumnWidth(1.8),
      6: pw.FlexColumnWidth(1.7),
      7: pw.FlexColumnWidth(1.3),
      8: pw.FlexColumnWidth(2.0),
      9: pw.FlexColumnWidth(1.4),
      10: pw.FlexColumnWidth(1.4),
      11: pw.FlexColumnWidth(1.6),
      12: pw.FlexColumnWidth(1.4),
      13: pw.FlexColumnWidth(2.0),
      14: pw.FlexColumnWidth(2.5),
    };

    final headers = [
      "MONTH", "Admissible/\nDrawn & Due", "BASIC PAY", "D.P/IR", "S.P",
      "D.A", "H.R.A", "M.A", "GROSS", "C.P.F", "P.TAX", "G.P.F", "I.TAX", "NET", "REMARKS"
    ];

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey400),
        children: headers.map((h) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
          alignment: pw.Alignment.center,
          child: pw.Text(h, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: pw.FontWeight.bold)),
        )).toList(),
      ),
    );

    for (var r in sh.records) {
      rows.add(
        pw.TableRow(
          children: [
            _pCleanCell(r.monthName, alignLeft: true),
            _pCell("Admissible"),
            _pCondNum(r.hasAdm, r.aBasic), _pCondNum(r.hasAdm, r.aDp), _pCondNum(r.hasAdm, r.aSp),
            _pCondNum(r.hasAdm, r.aDa), _pCondNum(r.hasAdm, r.aHra), _pCondNum(r.hasAdm, r.aMa),
            _pCondNum(r.hasAdm, r.aGross), _pCondNum(r.hasAdm, r.aCpf), _pCondNum(r.hasAdm, r.aPtax),
            _pCondNum(r.hasAdm, r.aGpf), _pCondNum(r.hasAdm, r.aItax), _pCondNum(r.hasAdm, r.aNet),
            _pCleanCell(r.effectiveAdmRemarks),
          ],
        ),
      );

      rows.add(
        pw.TableRow(
          children: [
            _pCleanCell(""),
            _pCell("Drawn"),
            _pCondNum(r.hasDrw, r.dBasic), _pCondNum(r.hasDrw, r.dDp), _pCondNum(r.hasDrw, r.dSp),
            _pCondNum(r.hasDrw, r.dDa), _pCondNum(r.hasDrw, r.dHra), _pCondNum(r.hasDrw, r.dMa),
            _pCondNum(r.hasDrw, r.dGross), _pCondNum(r.hasDrw, r.dCpf), _pCondNum(r.hasDrw, r.dPtax),
            _pCondNum(r.hasDrw, r.dGpf), _pCondNum(r.hasDrw, r.dItax), _pCondNum(r.hasDrw, r.dNet),
            _pCleanCell(r.effectiveDrwRemarks),
          ],
        ),
      );

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _pCleanCell(""),
            _pCell("Due", isBold: true),
            _pCondNum(r.hasAny, r.dueBasic, isBold: true), _pCondNum(r.hasAny, r.dueDp, isBold: true), _pCondNum(r.hasAny, r.dueSp, isBold: true),
            _pCondNum(r.hasAny, r.dueDa, isBold: true), _pCondNum(r.hasAny, r.dueHra, isBold: true), _pCondNum(r.hasAny, r.dueMa, isBold: true),
            _pCondNum(r.hasAny, r.dueGross, isBold: true), _pCondNum(r.hasAny, r.dueCpf, isBold: true), _pCondNum(r.hasAny, r.duePtax, isBold: true),
            _pCondNum(r.hasAny, r.dueGpf, isBold: true), _pCondNum(r.hasAny, r.dueItax, isBold: true), _pCondNum(r.hasAny, r.dueNet, isBold: true),
            _pCleanCell(r.effectiveDueRemarks),
          ],
        ),
      );
    }

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _pLeftSummaryCell("TOTAL:", isBold: true),
          _pCell(""),
          _pCondSummary(sh.hasAnyInput, sh.totBasic, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totDp, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totSp, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totDa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totHra, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totMa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totGross, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totCpf, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totPtax, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totGpf, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totItax, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.totNet, isBold: true),
          _pCell(""),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _pLeftSummaryCell("BALANCE:", isBold: true),
          _pCell(""),
          _pCondSummary(sh.balBasic != 0, sh.balBasic, isBold: true),
          _pCondSummary(sh.balDp != 0, sh.balDp, isBold: true),
          _pCondSummary(sh.balSp != 0, sh.balSp, isBold: true),
          _pCondSummary(sh.balDa != 0, sh.balDa, isBold: true),
          _pCondSummary(sh.balHra != 0, sh.balHra, isBold: true),
          _pCondSummary(sh.balMa != 0, sh.balMa, isBold: true),
          _pCondSummary(sh.balGross != 0, sh.balGross, isBold: true),
          _pCondSummary(sh.balCpf != 0, sh.balCpf, isBold: true),
          _pCondSummary(sh.balPtax != 0, sh.balPtax, isBold: true),
          _pCondSummary(sh.balGpf != 0, sh.balGpf, isBold: true),
          _pCondSummary(sh.balItax != 0, sh.balItax, isBold: true),
          _pCondSummary(sh.balNet != 0, sh.balNet, isBold: true),
          _pCell(""),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey400),
        children: [
          _pLeftSummaryCell("GRAND TOTAL:", isBold: true),
          _pCell(""),
          _pCondSummary(sh.hasAnyInput, sh.grandBasic, isBold: true),
          _pCondSummary(sh.grandDp != 0, sh.grandDp, isBold: true),
          _pCondSummary(sh.grandSp != 0, sh.grandSp, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandDa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandHra, isBold: true),
          _pCondSummary(sh.grandMa != 0, sh.grandMa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandGross, isBold: true),
          _pCondSummary(sh.grandCpf != 0, sh.grandCpf, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandPtax, isBold: true),
          _pCondSummary(sh.grandGpf != 0, sh.grandGpf, isBold: true),
          _pCondSummary(sh.grandItax != 0, sh.grandItax, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandNet, isBold: true),
          _pCell(""),
        ],
      ),
    );

    return pw.Table(
      border: const pw.TableBorder(
        top: pw.BorderSide(color: PdfColors.black, width: 0.8),
        bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
        left: pw.BorderSide(color: PdfColors.black, width: 0.8),
        right: pw.BorderSide(color: PdfColors.black, width: 0.8),
        horizontalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
        verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
      ),
      columnWidths: colWidths,
      children: rows,
    );
  }

  pw.Widget _pCleanCell(String text, {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 3.4),
      alignment: alignLeft ? pw.Alignment.topLeft : pw.Alignment.topCenter,
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        softWrap: true,
        style: pw.TextStyle(
          fontSize: alignLeft ? 6.0 : 5.6,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _pCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 3.4),
    alignment: pw.Alignment.center,
    child: pw.Text(t, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pLeftSummaryCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.only(left: 3, top: 3.4, bottom: 3.4),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pCondNum(bool condition, double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 3.4),
    alignment: pw.Alignment.center,
    child: pw.Text(condition ? val.round().toString() : "", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pCondSummary(bool condition, double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 3.4),
    alignment: pw.Alignment.center,
    child: pw.Text(condition ? val.round().toString() : "", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  // ---------------- LANDSCAPE FINAL SHEET PDF ----------------
  Future<void> _printFinalSheet() async {
    final doc = pw.Document();
    final customFont = await PdfGoogleFonts.barlowSemiCondensedSemiBold();
    final theme = pw.ThemeData.withFont(base: customFont, bold: customFont);

    final adHocTotal = (double.tryParse(adHoc1Ctrl.text) ?? 0) + (double.tryParse(adHoc2Ctrl.text) ?? 0) + (double.tryParse(adHoc3Ctrl.text) ?? 0) + (double.tryParse(adHoc4Ctrl.text) ?? 0);
    final actClaim = allGrandNet - adHocTotal;

    final inWordsText = actClaim > 0 ? numberToWordsIndian(actClaim.round()) : "";

    const double rowH = 14.25; 

    // বামদিকের কলামের মাপ
    const double wBasic = 67.5;
    const double wDp = 67.5;
    const double wDa = 73.0;
    const double wHra = 73.0;
    const double wMa = 73.0;
    const double wGross = 73.0;
    const double wCpf = 73.0;
    
    const double wInRs = 46.0;

    // ডানদিকের ৪টি কলামের সুনির্দিষ্ট মাপ
    const double wPtax = 63.0;
    const double wGpf = 60.0;
    const double wOthers = 60.0;
    const double wNet = 67.0;

    const double rightTotalWidth = wPtax + wGpf + wOthers + wNet; // 250.0 pt
    const double leftBoxWidth = wBasic + wDp + wDa + wHra + wMa + wGross + wCpf; // 500.0 pt
    const double bottomSectionWidth = wInRs + rightTotalWidth; // 296.0 pt
    const double totalSheetWidth = leftBoxWidth + bottomSectionWidth; // 796.0 pt

    const double headerLeftWidth = wBasic + wDp + wDa + wHra + wMa + wGross + wCpf + wInRs; // 546.0 pt
    const double headerRightWidth = rightTotalWidth; // 250.0 pt

    const headerLeftColWidths = {
      0: pw.FixedColumnWidth(wBasic + wDp), // 135.0 pt
      1: pw.FixedColumnWidth(headerLeftWidth - (wBasic + wDp)), // 411.0 pt
    };

    const headerRight4Cols = {
      0: pw.FixedColumnWidth(wPtax),
      1: pw.FixedColumnWidth(wGpf),
      2: pw.FixedColumnWidth(wOthers),
      3: pw.FixedColumnWidth(wNet),
    };

    const dateRowColWidths = {
      0: pw.FixedColumnWidth(wDa + wHra),          // 146.0 pt
      1: pw.FixedColumnWidth(wMa + wGross),        // 146.0 pt
      2: pw.FixedColumnWidth(wCpf + wInRs),        // 119.0 pt
    };

    const table2LeftCols = {
      0: pw.FixedColumnWidth(wBasic),
      1: pw.FixedColumnWidth(wDp),
      2: pw.FixedColumnWidth(wDa),
      3: pw.FixedColumnWidth(wHra),
      4: pw.FixedColumnWidth(wMa),
      5: pw.FixedColumnWidth(wGross),
      6: pw.FixedColumnWidth(wCpf),
    };

    const right4ColWidths = {
      0: pw.FixedColumnWidth(wPtax),
      1: pw.FixedColumnWidth(wGpf),
      2: pw.FixedColumnWidth(wOthers),
      3: pw.FixedColumnWidth(wNet),
    };

    const actualClaimRowWidths = {
      0: pw.FixedColumnWidth(wPtax + wGpf), // 123.0 pt
      1: pw.FixedColumnWidth(wOthers),      // 60.0 pt
      2: pw.FixedColumnWidth(wNet),         // 67.0 pt
    };

    const double receiptBoxHeight = 49.5; 
    const double reasonBoxHeight = 35.2;  
    const double inRsTallBoxHeight = rowH * 6; // 85.5 pt
    const double certificateBoxHeight = 165.0;
    const double inWordsBoxHeight = 47.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: theme,
        margin: const pw.EdgeInsets.only(
          top: 56.7,   
          left: 22.7,  
          right: 22.7, 
          bottom: 34.0 
        ),
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
              pw.SizedBox(height: 5),

              // 1. Header Table
              pw.Container(
                width: totalSheetWidth,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 0.8),
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                    left: pw.BorderSide(color: PdfColors.black, width: 0.8),
                    right: pw.BorderSide(color: PdfColors.black, width: 0.8),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // বামদিকের টেবিল সেকশন
                    pw.Container(
                      width: headerLeftWidth,
                      child: pw.Table(
                        border: const pw.TableBorder(
                          top: pw.BorderSide(color: PdfColors.black, width: 0.8),
                          bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                          left: pw.BorderSide(color: PdfColors.black, width: 0.8),
                          right: pw.BorderSide(color: PdfColors.black, width: 0.8),
                          horizontalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                          verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                        ),
                        columnWidths: headerLeftColWidths,
                        children: [
                          pw.TableRow(children: [
                            _finalHCell("NAME OF THE INSTITUTION:", height: rowH),
                            _finalValCell(instController.text, height: rowH, alignLeft: true),
                          ]),
                          pw.TableRow(children: [
                            _finalHCell("NAME OF THE EMPLOYEE:", height: rowH),
                            _finalValCell(empNameController.text, height: rowH, alignLeft: true),
                          ]),
                          pw.TableRow(children: [
                            _finalHCell("ARREAR FOR THE PERIOD:", height: rowH),
                            pw.Container(
                              height: rowH,
                              child: pw.Table(
                                border: const pw.TableBorder(
                                  verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                                columnWidths: dateRowColWidths,
                                children: [
                                  pw.TableRow(children: [
                                    pw.Container(
                                      height: rowH,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(fromDateController.text, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Container(
                                      height: rowH,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text("TO", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                    ),
                                    pw.Container(
                                      height: rowH,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(toDateController.text, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ]),
                          pw.TableRow(children: [
                            _finalHCell("IN TERMS OF ORDER NO.:", height: rowH),
                            _finalValCell(orderNoController.text, height: rowH, alignLeft: true),
                          ]),
                        ],
                      ),
                    ),

                    // ডানদিকের টেবিল সেকশন
                    pw.Container(
                      width: headerRightWidth,
                      child: pw.Column(
                        children: [
                          pw.Table(
                            border: const pw.TableBorder(
                              top: pw.BorderSide(color: PdfColors.black, width: 0.8),
                              bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                              left: pw.BorderSide(color: PdfColors.black, width: 0.8),
                              right: pw.BorderSide(color: PdfColors.black, width: 0.8),
                              horizontalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                              verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                            ),
                            columnWidths: headerRight4Cols,
                            children: [
                              pw.TableRow(children: [
                                _finalHCell("INDEX NO.:", height: rowH),
                                _finalValCell(indexController.text, height: rowH),
                                _finalHCell("H.S. CODE:", height: rowH),
                                _finalValCell(hsCodeController.text, height: rowH),
                              ]),
                              pw.TableRow(children: [
                                _finalHCell("DESIGNATION:", height: rowH),
                                _finalValCell(desigController.text, height: rowH),
                                _finalHCell("EMPLOYEE ID:", height: rowH),
                                _finalValCell(empIdController.text, height: rowH),
                              ]),
                            ],
                          ),
                          pw.Container(
                            height: rowH * 2,
                            width: headerRightWidth,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // মাঝের ফাঁকা রো
              pw.Container(
                height: rowH,
                width: totalSheetWidth,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.black, width: 0.8),
                    right: pw.BorderSide(color: PdfColors.black, width: 0.8),
                  ),
                ),
              ),

              // 2. Middle & Lower Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: leftBoxWidth,
                    child: pw.Column(
                      children: [
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                              children: [
                                pw.Container(
                                  height: rowH,
                                  width: leftBoxWidth,
                                  alignment: pw.Alignment.center,
                                  child: pw.Text("ARREAR DUE ON ACCOUNT OF:", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Table(
                                  border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                  columnWidths: table2LeftCols,
                                  children: [
                                    pw.TableRow(
                                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                                      children: [
                                        _finalValCell("BASIC PAY", height: rowH, isBold: true),
                                        _finalValCell("D.P/IR/S.P", height: rowH, isBold: true),
                                        _finalValCell("D.A", height: rowH, isBold: true),
                                        _finalValCell("H.R.A", height: rowH, isBold: true),
                                        _finalValCell("M.A", height: rowH, isBold: true),
                                        _finalValCell("Gross", height: rowH, isBold: true),
                                        _finalValCell("C.P.F/G.P.F", height: rowH, isBold: true),
                                      ],
                                    ),
                                    pw.TableRow(
                                      children: List.generate(7, (_) => _finalValCell("", height: rowH)),
                                    ),
                                    pw.TableRow(
                                      children: [
                                        _finalValCell(allGrandBasic.round().toString(), height: rowH),
                                        _finalValCell((allGrandDp + allGrandSp).round().toString(), height: rowH),
                                        _finalValCell(allGrandDa.round().toString(), height: rowH),
                                        _finalValCell(allGrandHra.round().toString(), height: rowH),
                                        _finalValCell(allGrandMa.round().toString(), height: rowH),
                                        _finalValCell(allGrandGross.round().toString(), height: rowH),
                                        _finalValCell("0", height: rowH),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        pw.Container(
                          width: leftBoxWidth,
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                height: receiptBoxHeight,
                                padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  mainAxisAlignment: pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Text("Date of receipt of 1st Grant-in-Aid by the School:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 2),
                                    pw.Text("Lump Grant w.e.f under salary deficit Scheme.", style: const pw.TextStyle(fontSize: 6.8)),
                                  ],
                                ),
                              ),
                              pw.Divider(color: PdfColors.black, thickness: 0.8, height: 0.8),
                              
                              // REASON OF ARREAR Row
                              pw.Table(
                                border: const pw.TableBorder(
                                  verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                                columnWidths: {
                                  0: const pw.FixedColumnWidth(wBasic + wDp), // 135.0 pt
                                  1: const pw.FixedColumnWidth(leftBoxWidth - (wBasic + wDp)), // 365.0 pt
                                },
                                children: [
                                  pw.TableRow(
                                    children: [
                                      pw.Container(
                                        height: reasonBoxHeight,
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                          "REASON OF ARREAR :",
                                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                                        ),
                                      ),
                                      pw.Container(
                                        height: reasonBoxHeight,
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          "FOR LATE APPROVAL",
                                          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              pw.Divider(color: PdfColors.black, thickness: 0.8, height: 0.8),
                              pw.Container(
                                height: certificateBoxHeight,
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    pw.Text("CERTIFIED THAT :-", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                    pw.Text("1. The amount claimed in this bill was not drawn before.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("2. The office copy agrees with the fair copy of the bill.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("3. The claim has been preferred with reference to Acquittance Roll & other office records.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("4. Necessary notes have been kept in the O/C of bills from which it was omitted in order to avoid double payment in future.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("5. The incumbent has not enjoyed any E.O.L. during the period of arrear claimed or has enjoyed E.O.L. in the months of as stated in the remark column.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("6. Income Tax, G.P.F. if any will be deducted and deposited through challan.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("7. The admissibility of the arrear claim has been checked with reference to Govt. Orders.", style: const pw.TextStyle(fontSize: 6.7)),
                                    pw.Text("8. All relevant records and found in order.", style: const pw.TextStyle(fontSize: 6.7)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Container(
                    width: bottomSectionWidth,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: wInRs,
                              height: (rowH * 4) + inRsTallBoxHeight,
                              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    height: rowH,
                                    width: wInRs,
                                    color: PdfColors.grey300,
                                    alignment: pw.Alignment.center,
                                    decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                      ),
                                    ),
                                    child: pw.Text("IN RS.", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Container(
                                    height: (rowH * 3) + inRsTallBoxHeight - 0.8,
                                    width: wInRs,
                                  ),
                                ],
                              ),
                            ),

                            pw.Container(
                              width: rightTotalWidth,
                              child: pw.Column(
                                children: [
                                  pw.Table(
                                    border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                    children: [
                                      pw.TableRow(
                                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                                        children: [
                                          pw.Container(
                                            height: rowH,
                                            width: rightTotalWidth,
                                            alignment: pw.Alignment.center,
                                            child: pw.Text("TO BE CREDITED TO:", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      pw.TableRow(
                                        children: [
                                          pw.Table(
                                            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                            columnWidths: right4ColWidths,
                                            children: [
                                              pw.TableRow(
                                                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                                                children: [
                                                  _finalValCell("P.TAX", height: rowH, isBold: true),
                                                  _finalValCell("G.P.F/C.P.F", height: rowH, isBold: true),
                                                  _finalValCell("OTHERS", height: rowH, isBold: true),
                                                  _finalValCell("NET CLAIM", height: rowH, isBold: true),
                                                ],
                                              ),
                                              pw.TableRow(
                                                children: List.generate(4, (_) => _finalValCell("", height: rowH)),
                                              ),
                                              pw.TableRow(
                                                children: [
                                                  _finalValCell("0", height: rowH),
                                                  _finalValCell("0", height: rowH),
                                                  _finalValCell("0", height: rowH),
                                                  _finalValCell(allGrandNet.round().toString(), height: rowH),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  pw.Table(
                                    border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                    children: [
                                      pw.TableRow(
                                        children: [
                                          pw.Container(
                                            height: rowH,
                                            width: rightTotalWidth,
                                            alignment: pw.Alignment.center,
                                            child: pw.Text("LESS ANY AD-HOC PAYMENT MODE:", style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      pw.TableRow(
                                        children: [
                                          pw.Table(
                                            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                            columnWidths: right4ColWidths,
                                            children: [
                                              pw.TableRow(children: [
                                                _finalValCell("1", height: rowH),
                                                _finalValCell(double.tryParse(adHoc1Ctrl.text) != null && double.parse(adHoc1Ctrl.text) > 0 ? adHoc1Ctrl.text : "", height: rowH),
                                                _finalValCell("", height: rowH),
                                                _finalValCell("", height: rowH),
                                              ]),
                                              pw.TableRow(children: [
                                                _finalValCell("2", height: rowH),
                                                _finalValCell(double.tryParse(adHoc2Ctrl.text) != null && double.parse(adHoc2Ctrl.text) > 0 ? adHoc2Ctrl.text : "", height: rowH),
                                                _finalValCell("", height: rowH),
                                                _finalValCell("", height: rowH),
                                              ]),
                                              pw.TableRow(children: [
                                                _finalValCell("3", height: rowH),
                                                _finalValCell(double.tryParse(adHoc3Ctrl.text) != null && double.parse(adHoc3Ctrl.text) > 0 ? adHoc3Ctrl.text : "", height: rowH),
                                                _finalValCell("", height: rowH),
                                                _finalValCell("", height: rowH),
                                              ]),
                                              pw.TableRow(children: [
                                                _finalValCell("4", height: rowH),
                                                _finalValCell(double.tryParse(adHoc4Ctrl.text) != null && double.parse(adHoc4Ctrl.text) > 0 ? adHoc4Ctrl.text : "", height: rowH),
                                                _finalValCell("", height: rowH),
                                                _finalValCell("", height: rowH),
                                              ]),
                                            ],
                                          ),
                                        ],
                                      ),
                                      pw.TableRow(
                                        children: [
                                          pw.Table(
                                            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                                            columnWidths: actualClaimRowWidths,
                                            children: [
                                              pw.TableRow(children: [
                                                pw.Container(
                                                  height: rowH,
                                                  padding: const pw.EdgeInsets.only(left: 4),
                                                  alignment: pw.Alignment.centerLeft,
                                                  child: pw.Text("ACTUAL CLAIM:", style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold)),
                                                ),
                                                _finalValCell(adHocTotal > 0 ? adHocTotal.round().toString() : "0", height: rowH),
                                                _finalValCell(actClaim.round().toString(), height: rowH, isBold: true),
                                              ]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        pw.Container(
                          height: rowH,
                          width: bottomSectionWidth,
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                        ),

                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                          columnWidths: {
                            0: pw.FixedColumnWidth(wInRs + wPtax + wGpf + wOthers), 
                            1: const pw.FixedColumnWidth(wNet),                     
                          },
                          children: [
                            pw.TableRow(children: [
                              pw.Container(
                                height: rowH + 2,
                                padding: const pw.EdgeInsets.only(left: 4),
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text("PASSED FOR RS.:", style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold)),
                              ),
                              _finalValCell(actClaim.round().toString(), height: rowH + 2, isBold: true),
                            ]),
                          ],
                        ),

                        pw.Container(
                          height: rowH,
                          width: bottomSectionWidth,
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                        ),

                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                          columnWidths: {
                            0: const pw.FixedColumnWidth(wInRs),         
                            1: pw.FixedColumnWidth(rightTotalWidth),      
                          },
                          children: [
                            pw.TableRow(children: [
                              pw.Container(
                                height: inWordsBoxHeight,
                                alignment: pw.Alignment.center,
                                child: pw.Text(
                                  "IN WORDS:",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Container(
                                height: inWordsBoxHeight,
                                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text(
                                  inWordsText,
                                  softWrap: true,
                                  style: const pw.TextStyle(fontSize: 6.8),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20.0 * PdfPageFormat.mm),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Signature of Secretary/Administrator/D.D.O.", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Signature of D.I./A.D.I. of Schools (S.E.)", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text("A.D./D.O.(Accounts)", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Final_Sheet.pdf',
      format: PdfPageFormat.a4.landscape,
    );
  }

  static pw.Widget _finalHCell(String t, {required double height}) => pw.Container(
    height: height,
    color: PdfColors.grey300,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _finalValCell(String t, {required double height, bool isBold = false, bool alignLeft = false}) => pw.Container(
    height: height,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
    alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );
}
