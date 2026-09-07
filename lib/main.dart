import 'package:flutter/material.dart';

void main() {
  runApp(const ArrearSalaryApp());
}

class ArrearSalaryApp extends StatelessWidget {
  const ArrearSalaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrear Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ArrearMainScreen(),
    );
  }
}

// মাসের হিসাবের ক্লাস (সব ফর্মুলা সহ)
class MonthRecord {
  final String monthName; // e.g. "March"
  final int year;         // e.g. 2015

  double basicAdm = 0;
  double basicDrn = 0;
  double dpIrRate = 0.0;
  double spRate = 0.0;

  // অতিরিক্ত কর্তন (Optional)
  double itaxAmount = 0;
  double gpfAmount = 0;

  MonthRecord({required this.monthName, required this.year});

  String get fullLabel => "$monthName,${year.toString().substring(2)}";

  // --- FORMULA 1: D.A. Rate ---
  double get daPercentage {
    if (year <= 2014) return 0.58;
    if (year == 2015) return 0.65;
    if (year == 2016) return 0.75;
    if (year == 2017) return 0.85;
    if (year >= 2018) return 1.00;
    return 0.58;
  }

  // --- FORMULA 2: H.R.A. Rate ---
  double get hraPercentage {
    if (year >= 2020) return 0.12; // ROPA 2019
    return 0.15;                  // ROPA 2009
  }

  // --- FORMULA 3: Medical Allowance (M.A.) ---
  double get maAdm => basicAdm > 0 ? (year >= 2020 ? 500 : 300) : 0;
  double get maDrn => basicDrn > 0 ? (year >= 2020 ? 500 : 300) : 0;

  // D.A. Amount (ROUND to nearest integer)
  double get daAdm => (basicAdm * daPercentage).roundToDouble();
  double get daDrn => (basicDrn * daPercentage).roundToDouble();

  // H.R.A. Amount (ROUND to nearest integer)
  double get hraAdm => (basicAdm * hraPercentage).roundToDouble();
  double get hraDrn => (basicDrn * hraPercentage).roundToDouble();

  // Gross Pay
  double get grossAdm => basicAdm + (basicAdm * dpIrRate).round() + (basicAdm * spRate).round() + daAdm + hraAdm + maAdm;
  double get grossDrn => basicDrn + (basicDrn * dpIrRate).round() + (basicDrn * spRate).round() + daDrn + hraDrn + maDrn;

  // --- FORMULA 4: P.TAX Slab ---
  double calculatePTax(double gross) {
    if (gross > 40000) return 200;
    if (gross > 25000) return 150;
    if (gross > 15000) return 130;
    if (gross > 10000) return 110;
    return 0;
  }

  double get ptaxAdm => calculatePTax(grossAdm);
  double get ptaxDrn => calculatePTax(grossDrn);

  // Net Pay
  double get netAdm => grossAdm > 0 ? (grossAdm - ptaxAdm - itaxAmount - gpfAmount) : 0;
  double get netDrn => grossDrn > 0 ? (grossDrn - ptaxDrn - itaxAmount - gpfAmount) : 0;

  // --- DUE ROW (Admissible - Drawn) ---
  double get basicDue => basicAdm - basicDrn;
  double get daDue => daAdm - daDrn;
  double get hraDue => hraAdm - hraDrn;
  double get maDue => maAdm - maDrn;
  double get grossDue => grossAdm - grossDrn;
  double get ptaxDue => ptaxAdm - ptaxDrn;
  double get netDue => netAdm - netDrn;
}

// প্রতি শিটের মডেল (March to Feb)
class ArrearAnnexure1Sheet {
  final String title;
  final int startYear;
  final List<MonthRecord> months;

  ArrearAnnexure1Sheet({
    required this.title,
    required this.startYear,
    required this.months,
  });

  // কলাম অনুযায়ী মোট যোগফল (Total Row)
  double get totalBasicDue => months.fold(0, (s, m) => s + m.basicDue);
  double get totalDaDue => months.fold(0, (s, m) => s + m.daDue);
  double get totalHraDue => months.fold(0, (s, m) => s + m.hraDue);
  double get totalMaDue => months.fold(0, (s, m) => s + m.maDue);
  double get totalGrossDue => months.fold(0, (s, m) => s + m.grossDue);
  double get totalPtaxDue => months.fold(0, (s, m) => s + m.ptaxDue);
  double get totalNetDue => months.fold(0, (s, m) => s + m.netDue);
}

class ArrearMainScreen extends StatefulWidget {
  const ArrearMainScreen({super.key});

  @override
  State<ArrearMainScreen> createState() => _ArrearMainScreenState();
}

class _ArrearMainScreenState extends State<ArrearMainScreen> {
  int startYear = 2015;
  List<ArrearAnnexure1Sheet> sheets = [];

  @override
  void initState() {
    super.initState();
    _generateSheetForYear(startYear);
  }

  void _generateSheetForYear(int yr) {
    List<MonthRecord> monthList = [];
    const monthsOrder = [
      "March", "April", "May", "June", "July", "August",
      "September", "October", "November", "December", "January", "February"
    ];

    for (int i = 0; i < 12; i++) {
      int y = (i >= 10) ? yr + 1 : yr; // Jan & Feb পরের বছর হয়
      monthList.add(MonthRecord(monthName: monthsOrder[i], year: y));
    }

    sheets.add(ArrearAnnexure1Sheet(
      title: "ANNEXURE - 1 (Sheet ${sheets.length + 1})",
      startYear: yr,
      months: monthList,
    ));
  }

  void _addNewYearSheet() {
    setState(() {
      int nextYear = startYear + sheets.length;
      _generateSheetForYear(nextYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ANNEXURE CONTINUED (Grand Total from all sheets)
    double grandBasicDue = sheets.fold(0, (s, sh) => s + sh.totalBasicDue);
    double grandDaDue = sheets.fold(0, (s, sh) => s + sh.totalDaDue);
    double grandHraDue = sheets.fold(0, (s, sh) => s + sh.totalHraDue);
    double grandMaDue = sheets.fold(0, (s, sh) => s + sh.totalMaDue);
    double grandGrossDue = sheets.fold(0, (s, sh) => s + sh.totalGrossDue);
    double grandPtaxDue = sheets.fold(0, (s, sh) => s + sh.totalPtaxDue);
    double grandNetClaim = sheets.fold(0, (s, sh) => s + sh.totalNetDue);

    return DefaultTabController(
      length: sheets.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Arrear Salary Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          actions: [
            TextButton.icon(
              onPressed: _addNewYearSheet,
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text("Next Year", style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.amberAccent,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              ...sheets.map((s) => Tab(text: s.title)),
              const Tab(text: "ANNEXURE (CONTINUED)"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...sheets.map((sheet) => buildAnnexure1TableView(sheet)),
            buildAnnexureContinuedView(
              grandBasicDue, grandDaDue, grandHraDue, grandMaDue,
              grandGrossDue, grandPtaxDue, grandNetClaim,
            ),
          ],
        ),
      ),
    );
  }

  // --- ANNEXURE-1 VIEW ---
  Widget buildAnnexure1TableView(ArrearAnnexure1Sheet sheet) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
          dataRowMinHeight: 38,
          dataRowMaxHeight: 48,
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('MONTH', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('SCALE', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('BASIC PAY', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('D.A.', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('H.R.A.', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('M.A.', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('GROSS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('P.TAX', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('NET', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            ...sheet.months.expand((m) => [
              // 1. Admissible Row
              DataRow(cells: [
                DataCell(Text(m.fullLabel, style: const TextStyle(fontWeight: FontWeight.bold))),
                const DataCell(Text('Admissible', style: TextStyle(fontSize: 12))),
                DataCell(buildNumberInput((val) => setState(() => m.basicAdm = val))),
                DataCell(Text(m.daAdm > 0 ? m.daAdm.toStringAsFixed(0) : '-')),
                DataCell(Text(m.hraAdm > 0 ? m.hraAdm.toStringAsFixed(0) : '-')),
                DataCell(Text(m.maAdm > 0 ? m.maAdm.toStringAsFixed(0) : '-')),
                DataCell(Text(m.grossAdm > 0 ? m.grossAdm.toStringAsFixed(0) : '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(m.ptaxAdm > 0 ? m.ptaxAdm.toStringAsFixed(0) : '-')),
                DataCell(Text(m.netAdm > 0 ? m.netAdm.toStringAsFixed(0) : '-', style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
              // 2. Drawn Row
              DataRow(cells: [
                const DataCell(Text('')),
                const DataCell(Text('Drawn', style: TextStyle(fontSize: 12))),
                DataCell(buildNumberInput((val) => setState(() => m.basicDrn = val))),
                DataCell(Text(m.daDrn > 0 ? m.daDrn.toStringAsFixed(0) : '-')),
                DataCell(Text(m.hraDrn > 0 ? m.hraDrn.toStringAsFixed(0) : '-')),
                DataCell(Text(m.maDrn > 0 ? m.maDrn.toStringAsFixed(0) : '-')),
                DataCell(Text(m.grossDrn > 0 ? m.grossDrn.toStringAsFixed(0) : '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(m.ptaxDrn > 0 ? m.ptaxDrn.toStringAsFixed(0) : '-')),
                DataCell(Text(m.netDrn > 0 ? m.netDrn.toStringAsFixed(0) : '-', style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
              // 3. Due Row
              DataRow(
                color: MaterialStateProperty.all(Colors.amber.shade50),
                cells: [
                  const DataCell(Text('')),
                  const DataCell(Text('Due', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                  DataCell(Text(m.basicDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.daDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.hraDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.maDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.grossDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                  DataCell(Text(m.ptaxDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.netDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                ],
              ),
            ]),
            // TOTAL ROW
            DataRow(
              color: MaterialStateProperty.all(Colors.teal.shade200),
              cells: [
                const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataCell(Text('')),
                DataCell(Text(sheet.totalBasicDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalDaDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalHraDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalMaDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalGrossDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalPtaxDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(sheet.totalNetDue.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNumberInput(Function(double) onChanged) {
    return SizedBox(
      width: 75,
      child: TextFormField(
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          hintText: '0',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  // --- ANNEXURE (CONTINUED) VIEW (স্বয়ংক্রিয় ফাইনাল সামারি) ---
  Widget buildAnnexureContinuedView(
    double basic, double da, double hra, double ma,
    double gross, double ptax, double net,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'ANNEXURE - 1 (CONTINUED)\n(Final Page Claim Summary)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
              const Text("ARREAR DUE ON ACCOUNT OF:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.underline)),
              const SizedBox(height: 12),
              buildSummaryLine('1. Total Basic Pay Due:', basic),
              buildSummaryLine('2. Total D.A. Due:', da),
              buildSummaryLine('3. Total H.R.A. Due:', hra),
              buildSummaryLine('4. Total M.A. Due:', ma),
              const Divider(thickness: 1.5, height: 24),
              buildSummaryLine('TOTAL GROSS CLAIM:', gross, isBold: true),
              const SizedBox(height: 12),
              const Text("DEDUCTIONS / ADJUSTMENTS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              buildSummaryLine('Professional Tax (P.Tax) Due:', ptax),
              const Divider(thickness: 2, height: 24),
              buildSummaryLine('FINAL NET CLAIM (Passed for Rs.):', net, isBold: true, highlightColor: Colors.teal.shade900),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Signature of D.D.O.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text("Signature of D.I. of Schools", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryLine(String title, double amount, {bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "₹ ${amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: highlightColor ?? (isBold ? Colors.indigo : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
