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
  final String remarks;
  final double daRate;

  TextEditingController admBasic = TextEditingController(text: "15280");
  TextEditingController admDp = TextEditingController(text: "0");
  TextEditingController admSp = TextEditingController(text: "0");
  TextEditingController admCpf = TextEditingController(text: "0");
  TextEditingController admGpf = TextEditingController(text: "1500");
  TextEditingController admItax = TextEditingController(text: "0");

  TextEditingController drwBasic = TextEditingController(text: "15280");
  TextEditingController drwDp = TextEditingController(text: "0");
  TextEditingController drwSp = TextEditingController(text: "0");
  TextEditingController drwCpf = TextEditingController(text: "0");
  TextEditingController drwGpf = TextEditingController(text: "1500");
  TextEditingController drwItax = TextEditingController(text: "0");

  MonthEntry({required this.monthName, this.remarks = '', this.daRate = 0.52});

  double _val(TextEditingController c) => double.tryParse(c.text) ?? 0;

  double get aBasic => _val(admBasic);
  double get aDp => _val(admDp);
  double get aSp => _val(admSp);
  double get aDa => (aBasic + aDp) * daRate;
  double get aHra => ((aBasic + aDp) * 0.15).clamp(0, 6000);
  double get aMa => 300;
  double get aGross => aBasic + aDp + aSp + aDa + aHra + aMa;
  double get aCpf => _val(admCpf);
  double get aPtax => aGross > 15000 ? 150 : 130;
  double get aGpf => _val(admGpf);
  double get aItax => _val(admItax);
  double get aNet => aGross - (aCpf + aPtax + aGpf + aItax);

  double get dBasic => _val(drwBasic);
  double get dDp => _val(drwDp);
  double get dSp => _val(drwSp);
  double get dDa => (dBasic + dDp) * daRate;
  double get dHra => ((dBasic + dDp) * 0.15).clamp(0, 6000);
  double get dMa => 300;
  double get dGross => dBasic + dDp + dSp + dDa + dHra + dMa;
  double get dCpf => _val(drwCpf);
  double get dPtax => dGross > 15000 ? 150 : 130;
  double get dGpf => _val(drwGpf);
  double get dItax => _val(drwItax);
  double get dNet => dGross - (dCpf + dPtax + dGpf + dItax);

  double get dueBasic => aBasic - dBasic;
  double get dueDp => aDp - dDp;
  double get dueSp => aSp - dSp;
  double get dueDa => aDa - dDa;
  double get dueHra => aHra - dHra;
  double get dueMa => aMa - dMa;
  double get dueGross => aGross - dGross;
  double get dueCpf => aCpf - dCpf;
  double get duePtax => aPtax - dPtax;
  double get dueGpf => aGpf - dGpf;
  double get dueItax => aItax - dItax;
  double get dueNet => aNet - dNet;
}

class YearSheet {
  final int startYear;
  final int endYear;
  final String sheetTitle;
  final String periodText;
  final List<MonthEntry> records;

  final TextEditingController balBasicCtrl = TextEditingController(text: "0");
  final TextEditingController balDaCtrl = TextEditingController(text: "0");
  final TextEditingController balHraCtrl = TextEditingController(text: "0");
  final TextEditingController balGrossCtrl = TextEditingController(text: "0");
  final TextEditingController balNetCtrl = TextEditingController(text: "0");

  YearSheet({
    required this.startYear,
    required this.endYear,
    required this.sheetTitle,
    required this.periodText,
    required this.records,
  });

  double get balBasic => double.tryParse(balBasicCtrl.text) ?? 0;
  double get balDa => double.tryParse(balDaCtrl.text) ?? 0;
  double get balHra => double.tryParse(balHraCtrl.text) ?? 0;
  double get balGross => double.tryParse(balGrossCtrl.text) ?? 0;
  double get balNet => double.tryParse(balNetCtrl.text) ?? 0;

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

  final adHoc1Ctrl = TextEditingController(text: "0");
  final adHoc2Ctrl = TextEditingController(text: "0");
  final adHoc3Ctrl = TextEditingController(text: "0");
  final adHoc4Ctrl = TextEditingController(text: "0");
  final wordsCtrl = TextEditingController(text: "ZERO ONLY");

  late TabController _tabController;
  List<YearSheet> sheets = [];

  @override
  void initState() {
    super.initState();
    // ডিফল্টভাবে ২০১৩ থেকে ২০১৮ (৫ বছর) দিয়ে শুরু হবে
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

      mList.add(MonthEntry(monthName: mStr, remarks: rem, daRate: da));
    }

    return YearSheet(
      startYear: startY,
      endYear: endY,
      sheetTitle: "Sheet ($startY-$e2Str)",
      periodText: "01.03.$startY TO 28.02.$endY",
      records: mList,
    );
  }

  // ডায়নামিকভাবে নতুন শিট যোগ করার মেথড
  void _addNewSheet() {
    int nextStart = sheets.isEmpty ? 2013 : sheets.last.endYear;
    int nextEnd = nextStart + 1;
    setState(() {
      sheets.add(_createYearSheet(nextStart, nextEnd));
      _tabController.dispose();
      _tabController = TabController(length: sheets.length, vsync: this, initialIndex: sheets.length - 1);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("New Sheet (${nextStart}-${nextEnd % 100}) added!")),
    );
  }

  // শেষ শিট ডিলিট করার মেথড
  void _removeLastSheet() {
    if (sheets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least one sheet is required!")),
      );
      return;
    }
    setState(() {
      sheets.removeLast();
      _tabController.dispose();
      _tabController = TabController(length: sheets.length, vsync: this, initialIndex: sheets.length - 1);
    });
  }

  // সবকটি শিটের সম্মিলিত Grand Total (Final Sheet-এর জন্য)
  double get allGrandBasic => sheets.fold(0, (s, sh) => s + sh.grandBasic);
  double get allGrandDa => sheets.fold(0, (s, sh) => s + sh.grandDa);
  double get allGrandHra => sheets.fold(0, (s, sh) => s + sh.grandHra);
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
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: 'Add Next Year Sheet',
            onPressed: _addNewSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove Last Sheet',
            onPressed: _removeLastSheet,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Calculation Sheets (Portrait A4)',
            onPressed: () => _printCalculationSheets(),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Final Sheet (Landscape A4)',
            onPressed: () => _printFinalSheet(),
          ),
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
          const SizedBox(height: 20),
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
        _buildTableRow("NAME OF THE INSTITUTION:", instController, "INDEX NO :", indexController),
        _buildTableRow("NAME OF THE EMPLOYEE:", empNameController, "DESIGNATION:", desigController),
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
                      child: IgnorePointer(child: _leftTextField(fromDateController)),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("TO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(toDateController),
                      child: IgnorePointer(child: _leftTextField(toDateController)),
                    ),
                  ),
                ],
              ),
            ),
            _headerCell("EMPLOYEE ID:"),
            Padding(padding: const EdgeInsets.all(4), child: _leftTextField(empIdController)),
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
            Padding(padding: const EdgeInsets.all(4), child: _leftTextField(hsCodeController)),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String l1, TextEditingController c1, String l2, TextEditingController c2) {
    return TableRow(
      children: [
        _headerCell(l1),
        Padding(padding: const EdgeInsets.all(4), child: _leftTextField(c1)),
        _headerCell(l2),
        Padding(padding: const EdgeInsets.all(4), child: _leftTextField(c2)),
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

  Widget _buildScaleRow() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.2)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Text("SCALE ADMISSIBLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: TextField(
              controller: scaleController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Enter Scale Here",
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
          14: FixedColumnWidth(70),
        },
        children: [
          _buildColumnHeader(),
          for (var r in sh.records) ..._buildMonthRows(r),
          _buildTotalRow("TOTAL:", sh.totBasic, sh.totDa, sh.totHra, sh.totGross, sh.totNet),
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
            padding: const EdgeInsets.only(left: 6),
            alignment: Alignment.centerLeft,
            child: Text(r.monthName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          _labelCell("Admissible"),
          _unlockedCell(r.admBasic),
          _unlockedCell(r.admDp),
          _unlockedCell(r.admSp),
          _lockedCalcCell(r.aDa),
          _lockedCalcCell(r.aHra),
          _lockedCalcCell(r.aMa),
          _lockedCalcCell(r.aGross, isBold: true),
          _unlockedCell(r.admCpf),
          _lockedCalcCell(r.aPtax),
          _unlockedCell(r.admGpf),
          _unlockedCell(r.admItax),
          _lockedCalcCell(r.aNet, isBold: true),
          _labelCell(""),
        ],
      ),
      TableRow(
        children: [
          _labelCell(""),
          _labelCell("Drawn"),
          _unlockedCell(r.drwBasic),
          _unlockedCell(r.drwDp),
          _unlockedCell(r.drwSp),
          _lockedCalcCell(r.dDa),
          _lockedCalcCell(r.dHra),
          _lockedCalcCell(r.dMa),
          _lockedCalcCell(r.dGross, isBold: true),
          _unlockedCell(r.drwCpf),
          _lockedCalcCell(r.dPtax),
          _unlockedCell(r.drwGpf),
          _unlockedCell(r.drwItax),
          _lockedCalcCell(r.dNet, isBold: true),
          _labelCell(r.remarks, isBold: true),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        children: [
          _labelCell(""),
          _labelCell("Due", isBold: true),
          _lockedCalcCell(r.dueBasic, isBold: true),
          _lockedCalcCell(r.dueDp, isBold: true),
          _lockedCalcCell(r.dueSp, isBold: true),
          _lockedCalcCell(r.dueDa, isBold: true),
          _lockedCalcCell(r.dueHra, isBold: true),
          _lockedCalcCell(r.dueMa, isBold: true),
          _lockedCalcCell(r.dueGross, isBold: true),
          _lockedCalcCell(r.dueCpf, isBold: true),
          _lockedCalcCell(r.duePtax, isBold: true),
          _lockedCalcCell(r.dueGpf, isBold: true),
          _lockedCalcCell(r.dueItax, isBold: true),
          _lockedCalcCell(r.dueNet, isBold: true),
          _labelCell(""),
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

  Widget _lockedCalcCell(double val, {bool isBold = false}) {
    return Container(
      color: isBold ? Colors.transparent : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      child: Text(
        val.round().toString(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _labelCell(String t, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: Text(t, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _leftLabelCell(String t, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.only(left: 6, top: 5, bottom: 5),
      alignment: Alignment.centerLeft,
      child: Text(t, textAlign: TextAlign.left, style: TextStyle(fontSize: 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  TableRow _buildTotalRow(String title, double b, double da, double hra, double gross, double net) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _leftLabelCell(title, isBold: true),
        _labelCell(""),
        _lockedCalcCell(b, isBold: true), _labelCell(""), _labelCell(""),
        _lockedCalcCell(da, isBold: true), _lockedCalcCell(hra, isBold: true), _labelCell(""),
        _lockedCalcCell(gross, isBold: true), _labelCell(""), _labelCell(""), _labelCell(""), _labelCell(""),
        _lockedCalcCell(net, isBold: true), _labelCell(""),
      ],
    );
  }

  TableRow _buildBalanceRow(YearSheet sh) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _leftLabelCell("BALANCE:", isBold: true),
        _labelCell(""),
        _unlockedCell(sh.balBasicCtrl), _labelCell(""), _labelCell(""),
        _unlockedCell(sh.balDaCtrl), _unlockedCell(sh.balHraCtrl), _labelCell(""),
        _unlockedCell(sh.balGrossCtrl), _labelCell(""), _labelCell(""), _labelCell(""), _labelCell(""),
        _unlockedCell(sh.balNetCtrl), _labelCell(""),
      ],
    );
  }

  TableRow _buildGrandTotalRow(YearSheet sh) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade400),
      children: [
        _leftLabelCell("GRAND TOTAL:", isBold: true),
        _labelCell(""),
        _lockedCalcCell(sh.grandBasic, isBold: true), _labelCell(""), _labelCell(""),
        _lockedCalcCell(sh.grandDa, isBold: true), _lockedCalcCell(sh.grandHra, isBold: true), _labelCell(""),
        _lockedCalcCell(sh.grandGross, isBold: true), _labelCell(""), _labelCell(""), _labelCell(""), _labelCell(""),
        _lockedCalcCell(sh.grandNet, isBold: true), _labelCell(""),
      ],
    );
  }

  Widget _buildFooterSignatures() {
    return Column(
      children: [
        const SizedBox(height: 15),
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
                SizedBox(height: 18),
                Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- PORTRAIT CALCULATION SHEETS PDF (যতগুলো শিট থাকবে সব পেজ আসবে) ----------------
  Future<void> _printCalculationSheets() async {
    final doc = pw.Document();
    final customFont = await PdfGoogleFonts.barlowSemiCondensedSemiBold();
    final theme = pw.ThemeData.withFont(base: customFont, bold: customFont);

    for (var sh in sheets) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: const pw.EdgeInsets.all(14),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("ANNEXURE - 1", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13))),
              pw.SizedBox(height: 5),
              _buildPdfHeader(sh.periodText),
              pw.SizedBox(height: 5),
              _buildPdfScale(),
              pw.SizedBox(height: 5),
              _buildPdfTable(sh),
              pw.Spacer(),
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
                      pw.Text("Verified and found correct.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      pw.SizedBox(height: 16),
                      pw.Text("Signature of Secretary/Administrator/D.D.O. with Seal.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Widget _buildPdfHeader(String periodText) {
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
          _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValLeftCell(instController.text),
          _pdfHCell("INDEX NO:"), _pdfValLeftCell(indexController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValLeftCell(empNameController.text),
          _pdfHCell("DESIGNATION:"), _pdfValLeftCell(desigController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("ARREAR FOR THE PERIOD:"),
          pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text(periodText, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          ),
          _pdfHCell("EMPLOYEE ID:"), _pdfValLeftCell(empIdController.text),
        ]),
        pw.TableRow(children: [
          _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValLeftCell(orderNoController.text),
          _pdfHCell("H.S. CODE:"), _pdfValLeftCell(hsCodeController.text),
        ]),
      ],
    );
  }

  pw.Widget _pdfHCell(String t) => pw.Container(
    color: PdfColors.grey300,
    padding: const pw.EdgeInsets.all(3),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfValLeftCell(String t) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(t, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
    ),
  );

  pw.Widget _buildPdfScale() {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.0)),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            color: PdfColors.grey300,
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            alignment: pw.Alignment.center,
            child: pw.Text("SCALE ADMISSIBLE", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: pw.Center(child: pw.Text(scaleController.text, style: const pw.TextStyle(fontSize: 7.5))),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTable(YearSheet sh) {
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
        for (var r in sh.records) ...[
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 3),
              child: pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(r.monthName, style: pw.TextStyle(fontSize: 6.2, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            _pCell("Admissible"),
            _pNum(r.aBasic), _pNum(r.aDp), _pNum(r.aSp), _pNum(r.aDa), _pNum(r.aHra), _pNum(r.aMa),
            _pNum(r.aGross), _pNum(r.aCpf), _pNum(r.aPtax), _pNum(r.aGpf), _pNum(r.aItax), _pNum(r.aNet), _pCell(""),
          ]),
          pw.TableRow(children: [
            _pCell(""), _pCell("Drawn"),
            _pNum(r.dBasic), _pNum(r.dDp), _pNum(r.dSp), _pNum(r.dDa), _pNum(r.dHra), _pNum(r.dMa),
            _pNum(r.dGross), _pNum(r.dCpf), _pNum(r.dPtax), _pNum(r.dGpf), _pNum(r.dItax), _pNum(r.dNet), _pCell(r.remarks, isBold: true),
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
            _pLeftCell("TOTAL:", isBold: true), _pCell(""),
            _pNum(sh.totBasic, isBold: true), _pCell(""), _pCell(""), _pNum(sh.totDa, isBold: true), _pNum(sh.totHra, isBold: true), _pCell(""),
            _pNum(sh.totGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(sh.totNet, isBold: true), _pCell(""),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pLeftCell("BALANCE:", isBold: true), _pCell(""),
            _pNum(sh.balBasic, isBold: true), _pCell(""), _pCell(""), _pNum(sh.balDa, isBold: true), _pNum(sh.balHra, isBold: true), _pCell(""),
            _pNum(sh.balGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(sh.balNet, isBold: true), _pCell(""),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey400),
          children: [
            _pLeftCell("GRAND TOTAL:", isBold: true), _pCell(""),
            _pNum(sh.grandBasic, isBold: true), _pCell(""), _pCell(""), _pNum(sh.grandDa, isBold: true), _pNum(sh.grandHra, isBold: true), _pCell(""),
            _pNum(sh.grandGross, isBold: true), _pCell(""), _pCell(""), _pCell(""), _pCell(""), _pNum(sh.grandNet, isBold: true), _pCell(""),
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

  pw.Widget _pLeftCell(String t, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.only(left: 3, top: 1.5, bottom: 1.5),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(t, textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 6.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  pw.Widget _pNum(double val, {bool isBold = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    alignment: pw.Alignment.center,
    child: pw.Text(val.round().toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 6.2, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  // ---------------- LANDSCAPE FINAL SHEET PDF (সমস্ত শিটের সমষ্টিগত GRAND TOTAL) ----------------
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
                    _pdfHCell("NAME OF THE INSTITUTION:"), _pdfValLeftCell(instController.text),
                    _pdfHCell("INDEX NO :"), _pdfValLeftCell(indexController.text),
                    _pdfHCell("H.S. CODE :"), _pdfValLeftCell(hsCodeController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("NAME OF THE EMPLOYEE:"), _pdfValLeftCell(empNameController.text),
                    _pdfHCell("DESIGNATION:"), _pdfValLeftCell(desigController.text),
                    _pdfHCell("EMPLOYEE ID:"), _pdfValLeftCell(empIdController.text),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("ARREAR FOR THE PERIOD:"),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: pw.Text("${fromDateController.text}   TO   ${toDateController.text}", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ),
                    _pdfHCell(""), _pdfValLeftCell(""),
                    _pdfHCell(""), _pdfValLeftCell(""),
                  ]),
                  pw.TableRow(children: [
                    _pdfHCell("IN TERMS OF ORDER NO.:"), _pdfValLeftCell(orderNoController.text),
                    _pdfHCell(""), _pdfValLeftCell(""),
                    _pdfHCell(""), _pdfValLeftCell(""),
                  ]),
                ],
              ),
              pw.SizedBox(height: 6),

              // Due & Credit Table - ALL SHEETS COMBINED GRAND TOTAL
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
                              _pNum(allGrandBasic),
                              _pNum(0),
                              _pNum(allGrandDa),
                              _pNum(allGrandHra),
                              _pNum(0),
                              _pNum(allGrandGross),
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
                              _pNum(allGrandNet),
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
                        pw.TableRow(children: [_adHocRow("1", double.tryParse(adHoc1Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("2", double.tryParse(adHoc2Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("3", double.tryParse(adHoc3Ctrl.text) ?? 0)]),
                        pw.TableRow(children: [_adHocRow("4", double.tryParse(adHoc4Ctrl.text) ?? 0)]),
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2),
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
                              padding: const pw.EdgeInsets.all(2),
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
                              padding: const pw.EdgeInsets.all(2),
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
          pw.Text(val == 0 ? "" : val.round().toString(), style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }
}
