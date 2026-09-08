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

  // Remarks controllers
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

  double get aBasic => _val(admBasic);
  double get aDp => _val(admDp);
  double get aSp => _val(admSp);
  double get aDa => hasAdm ? (aBasic + aDp) * daRate : 0;
  double get aHra => hasAdm ? ((aBasic + aDp) * 0.15).clamp(0, 6000) : 0;
  double get aMa => hasAdm ? 300 : 0;
  double get aGross => hasAdm ? (aBasic + aDp + aSp + aDa + aHra + aMa) : 0;
  double get aCpf => _val(admCpf);
  double get aPtax => hasAdm ? (aGross > 15000 ? 150 : 130) : 0;
  double get aGpf => _val(admGpf);
  double get aItax => _val(admItax);
  double get aNet => hasAdm ? (aGross - (aCpf + aPtax + aGpf + aItax)) : 0;

  double get dBasic => _val(drwBasic);
  double get dDp => _val(drwDp);
  double get dSp => _val(drwSp);
  double get dDa => hasDrw ? (dBasic + dDp) * daRate : 0;
  double get dHra => hasDrw ? ((dBasic + dDp) * 0.15).clamp(0, 6000) : 0;
  double get dMa => hasDrw ? 300 : 0;
  double get dGross => hasDrw ? (dBasic + dDp + dSp + dDa + dHra + dMa) : 0;
  double get dCpf => _val(drwCpf);
  double get dPtax => hasDrw ? (dGross > 15000 ? 150 : 130) : 0;
  double get dGpf => _val(drwGpf);
  double get dItax => _val(drwItax);
  double get dNet => hasDrw ? (dGross - (dCpf + dPtax + dGpf + dItax)) : 0;

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
  final wordsCtrl = TextEditingController(text: "ZERO ONLY");

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
          _unlockedTextCell(r.drwRemarks), // Unlocked for Drawn
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
          _unlockedTextCell(r.dueRemarks), // Unlocked for Due
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
        _condSummaryCell(sh.hasAnyInput, sh.grandDp, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandSp, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandDa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandHra, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandMa, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandGross, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandCpf, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandPtax, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandGpf, isBold: true),
        _condSummaryCell(sh.hasAnyInput, sh.grandItax, isBold: true),
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
            top: 34.0,    // 12mm
            left: 22.7,   // 8mm
            right: 22.7,  // 8mm
            bottom: 28.3, // 10mm
          ),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("ANNEXURE - 1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11.5)),
              ),
              pw.SizedBox(height: 3),
              _buildPdfHeader(sh.periodText),
              pw.SizedBox(height: 2),
              _buildPdfScale(),
              pw.SizedBox(height: 2),
              _buildPdfTable(sh),
              
              // Exact space of ~1.5mm between GRAND TOTAL and Verified
              pw.SizedBox(height: 4.5),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text("Date: ....................", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Verified and found correct.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      // Seal & Stamp space of ~14mm
                      pw.SizedBox(height: 40),
                      pw.Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
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
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
            child: pw.Center(child: pw.Text(periodText, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
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
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.8),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfValLeftCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.8),
    child: pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(t, style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold)),
    ),
  );

  pw.Widget _pdfValCenterCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1.8),
    child: pw.Center(
      child: pw.Text(t, style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold)),
    ),
  );

  pw.Widget _buildPdfScale() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            color: PdfColors.grey300,
            padding: const pw.EdgeInsets.symmetric(vertical: 2.2),
            alignment: pw.Alignment.center,
            child: pw.Text("SCALE ADMISSIBLE", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            child: pw.Center(child: pw.Text(scaleController.text, style: const pw.TextStyle(fontSize: 7))),
          ),
        ],
      ),
    );
  }

  // 100% Guaranteed Calculation Table with Perfectly Hidden Internal Horizontal Borders
  pw.Widget _buildPdfTable(YearSheet sh) {
    const colWidths = {
      0: pw.FlexColumnWidth(2.3),  // MONTH
      1: pw.FlexColumnWidth(2.4),  // Admissible/Drawn & Due
      2: pw.FlexColumnWidth(2.0),  // BASIC PAY
      3: pw.FlexColumnWidth(1.4),  // D.P/IR
      4: pw.FlexColumnWidth(1.3),  // S.P
      5: pw.FlexColumnWidth(1.8),  // D.A
      6: pw.FlexColumnWidth(1.7),  // H.R.A
      7: pw.FlexColumnWidth(1.3),  // M.A
      8: pw.FlexColumnWidth(2.0),  // GROSS
      9: pw.FlexColumnWidth(1.4),  // C.P.F
      10: pw.FlexColumnWidth(1.4), // P.TAX
      11: pw.FlexColumnWidth(1.6), // G.P.F
      12: pw.FlexColumnWidth(1.4), // I.TAX
      13: pw.FlexColumnWidth(2.0), // NET
      14: pw.FlexColumnWidth(2.5), // REMARKS
    };

    final headers = [
      "MONTH", "Admissible/\nDrawn & Due", "BASIC PAY", "D.P/IR", "S.P",
      "D.A", "H.R.A", "M.A", "GROSS", "C.P.F", "P.TAX", "G.P.F", "I.TAX", "NET", "REMARKS"
    ];

    List<pw.TableRow> rows = [];

    // Header Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey400),
        children: headers.map((h) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.2),
          alignment: pw.Alignment.center,
          child: pw.Text(h, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: pw.FontWeight.bold)),
        )).toList(),
      ),
    );

    // 12 Months * 3 Rows = 36 Rows
    for (var r in sh.records) {
      // 1. Admissible Row (Month name on Top-Left, Remarks on Top-Center)
      rows.add(
        pw.TableRow(
          children: [
            _pMonthPartCell(r.monthName, isTop: true),
            _pCell("Admissible"),
            _pCondNum(r.hasAdm, r.aBasic), _pCondNum(r.hasAdm, r.aDp), _pCondNum(r.hasAdm, r.aSp),
            _pCondNum(r.hasAdm, r.aDa), _pCondNum(r.hasAdm, r.aHra), _pCondNum(r.hasAdm, r.aMa),
            _pCondNum(r.hasAdm, r.aGross), _pCondNum(r.hasAdm, r.aCpf), _pCondNum(r.hasAdm, r.aPtax),
            _pCondNum(r.hasAdm, r.aGpf), _pCondNum(r.hasAdm, r.aItax), _pCondNum(r.hasAdm, r.aNet),
            _pRemarksPartCell(r.effectiveAdmRemarks, isTop: true),
          ],
        ),
      );

      // 2. Drawn Row (White space inside Month & Remarks cells)
      rows.add(
        pw.TableRow(
          children: [
            _pMonthPartCell("", isMiddle: true),
            _pCell("Drawn"),
            _pCondNum(r.hasDrw, r.dBasic), _pCondNum(r.hasDrw, r.dDp), _pCondNum(r.hasDrw, r.dSp),
            _pCondNum(r.hasDrw, r.dDa), _pCondNum(r.hasDrw, r.dHra), _pCondNum(r.hasDrw, r.dMa),
            _pCondNum(r.hasDrw, r.dGross), _pCondNum(r.hasDrw, r.dCpf), _pCondNum(r.hasDrw, r.dPtax),
            _pCondNum(r.hasDrw, r.dGpf), _pCondNum(r.hasDrw, r.dItax), _pCondNum(r.hasDrw, r.dNet),
            _pRemarksPartCell(r.effectiveDrwRemarks, isMiddle: true),
          ],
        ),
      );

      // 3. Due Row (Bottom of Month & Remarks block)
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _pMonthPartCell("", isBottom: true),
            _pCell("Due", isBold: true),
            _pCondNum(r.hasAny, r.dueBasic, isBold: true), _pCondNum(r.hasAny, r.dueDp, isBold: true), _pCondNum(r.hasAny, r.dueSp, isBold: true),
            _pCondNum(r.hasAny, r.dueDa, isBold: true), _pCondNum(r.hasAny, r.dueHra, isBold: true), _pCondNum(r.hasAny, r.dueMa, isBold: true),
            _pCondNum(r.hasAny, r.dueGross, isBold: true), _pCondNum(r.hasAny, r.dueCpf, isBold: true), _pCondNum(r.hasAny, r.duePtax, isBold: true),
            _pCondNum(r.hasAny, r.dueGpf, isBold: true), _pCondNum(r.hasAny, r.dueItax, isBold: true), _pCondNum(r.hasAny, r.dueNet, isBold: true),
            _pRemarksPartCell(r.effectiveDueRemarks, isBottom: true),
          ],
        ),
      );
    }

    // TOTAL ROW
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

    // BALANCE ROW
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

    // GRAND TOTAL ROW
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey400),
        children: [
          _pLeftSummaryCell("GRAND TOTAL:", isBold: true),
          _pCell(""),
          _pCondSummary(sh.hasAnyInput, sh.grandBasic, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandDp, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandSp, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandDa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandHra, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandMa, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandGross, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandCpf, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandPtax, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandGpf, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandItax, isBold: true),
          _pCondSummary(sh.hasAnyInput, sh.grandNet, isBold: true),
          _pCell(""),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      columnWidths: colWidths,
      children: rows,
    );
  }

  // Cell components that overwrite the middle horizontal borders with white
  pw.Widget _pMonthPartCell(String text, {bool isTop = false, bool isMiddle = false, bool isBottom = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border(
          bottom: isBottom ? const pw.BorderSide(color: PdfColors.black, width: 0.8) : const pw.BorderSide(color: PdfColors.white, width: 0.8),
          top: isTop ? const pw.BorderSide(color: PdfColors.black, width: 0.8) : const pw.BorderSide(color: PdfColors.white, width: 0.8),
        ),
      ),
      padding: const pw.EdgeInsets.only(left: 3, top: 1.5, bottom: 1.5),
      alignment: pw.Alignment.topLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 6.0, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pRemarksPartCell(String text, {bool isTop = false, bool isMiddle = false, bool isBottom = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border(
          bottom: isBottom ? const pw.BorderSide(color: PdfColors.black, width: 0.8) : const pw.BorderSide(color: PdfColors.white, width: 0.8),
          top: isTop ? const pw.BorderSide(color: PdfColors.black, width: 0.8) : const pw.BorderSide(color: PdfColors.white, width: 0.8),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
      alignment: pw.Alignment.topCenter,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        softWrap: true,
        style: pw.TextStyle(fontSize: 5.6, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.1),
    alignment: pw.Alignment.center,
    child: pw.Text(t, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pLeftSummaryCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.only(left: 3, top: 2.1, bottom: 2.1),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pCondNum(bool condition, double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.1),
    alignment: pw.Alignment.center,
    child: pw.Text(condition ? val.round().toString() : "", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 5.6, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pCondSummary(bool condition, double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.1),
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

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: theme,
        margin: const pw.EdgeInsets.only(
          top: 28.3, // 10mm
          left: 22.7, // 8mm
          right: 22.7, // 8mm
          bottom: 22.7, // 8mm
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

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
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
                    _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValLeftCell(instController.text),
                    _pdfHCell("INDEX NO :"), _pdfValCenterCell(indexController.text),
                    _pdfHCell("H.S. CODE :"), _pdfValCenterCell(hsCodeController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValLeftCell(empNameController.text),
                    _pdfHCell("DESIGNATION:"), _pdfValCenterCell(desigController.text),
                    _pdfHCell("EMPLOYEE ID:"), _pdfValCenterCell(empIdController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("ARREAR FOR THE PERIOD:"),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                      child: pw.Center(child: pw.Text("${fromDateController.text}   TO   ${toDateController.text}", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                    ),
                    _pdfHCell(""), _pdfValCenterCell(""),
                    _pdfHCell(""), _pdfValCenterCell(""),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValLeftCell(orderNoController.text),
                    _pdfHCell(""), _pdfValCenterCell(""),
                    _pdfHCell(""), _pdfValCenterCell(""),
                  ]),
                ],
              ),
              pw.SizedBox(height: 5),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
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
                              _pCell(allGrandBasic.round().toString()),
                              _pCell((allGrandDp + allGrandSp).round().toString()),
                              _pCell(allGrandDa.round().toString()),
                              _pCell(allGrandHra.round().toString()),
                              _pCell(allGrandMa.round().toString()),
                              _pCell(allGrandGross.round().toString()),
                              _pCell("0"),
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
                              _pCell("0"),
                              _pCell("0"),
                              _pCell("0"),
                              _pCell(allGrandNet.round().toString()),
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
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Date of receipt of 1st Grant-in-Aid by the School:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                          pw.Text("Lump Grant w.e.f under salary deficit Scheme.", style: const pw.TextStyle(fontSize: 6.8)),
                          pw.SizedBox(height: 3),
                          pw.Row(
                            children: [
                              pw.Text("REASON OF ARREAR :", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(width: 30),
                              pw.Text("FOR LATE APPROVAL", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text("CERTIFIED THAT :-", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                          pw.Text("1. The amount claimed in this bill was not drawn before.", style: const pw.TextStyle(fontSize: 6.5)),
                          pw.Text("2. The office copy agrees with the fair copy of the bill.", style: const pw.TextStyle(fontSize: 6.5)),
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
                      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text("LESS ANY AD-HOC PAYMENT MADE:", style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)))),
                          ],
                        ),
                        pw.TableRow(children: [_adHocRow("1", double.tryParse(adHoc1Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("2", double.tryParse(adHoc2Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("3", double.tryParse(adHoc3Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("4", double.tryParse(adHoc4Ctrl.text) ?? 0)]),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text("ACTUAL CLAIM:", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(actClaim.round().toString(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: pw.Row(
                                children: [
                                  pw.Text("PASSED FOR RS.: ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(actClaim.round().toString(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("IN WORDS: ", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(child: pw.Text(wordsCtrl.text, style: const pw.TextStyle(fontSize: 6.5))),
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
                  pw.Text("Signature of Secretary/Administrator/D.D.O.", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Signature of D.I./A.D.I. of Schools (S.E.)", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text("A.D./D.O.(Accounts)", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 6),
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
          pw.Text(val == 0 ? "" : val.round().toString(), style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }
}
