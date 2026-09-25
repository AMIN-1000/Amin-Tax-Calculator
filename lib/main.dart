import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GratuityCalculatorApp());
}

class GratuityCalculatorApp extends StatelessWidget {
  const GratuityCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WB School Gratuity Calculator",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D40),
          foregroundColor: Colors.white,
        ),
      ),
      home: const GratuityHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GratuityHomeScreen extends StatefulWidget {
  const GratuityHomeScreen({super.key});

  @override
  State<GratuityHomeScreen> createState() => _GratuityHomeScreenState();
}

class _GratuityHomeScreenState extends State<GratuityHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Header Details
  final nameCtrl = TextEditingController(text: "MD RUHUL AMIN MONDAL");
  final schoolCtrl =
      TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final empCodeCtrl = TextEditingController(text: "BDFF2107");
  final dojCtrl = TextEditingController(text: "19.05.2005");
  final dorCtrl = TextEditingController(text: "31.07.2039");

  // Designation Dropdown
  final List<String> designationList = [
    "H.M",
    "T.I.C",
    "A.H.M",
    "A.T",
    "CLERK",
    "Gr-D (Peon)",
    "Gr-D"
  ];
  late String selectedDesignation;

  // Inputs
  final eolYearsCtrl = TextEditingController(text: "0");
  final eolMonthsCtrl = TextEditingController(text: "0");
  final basicPayCtrl = TextEditingController(text: "55000");
  final dpCtrl = TextEditingController(text: "0");

  // Dynamic Display Outputs
  String grossYearsText = "0";
  String grossMonthsText = "0";
  String netServiceText = "0 Yrs 0 Mos";
  String unitsText = "0";
  double daPercent = 0.0;
  String daAmountText = "0";
  String totalEmolumentsText = "0";
  String calculatedGratuityText = "0";
  String payableGratuityText = "0";
  String eligibilityText = "ELIGIBLE FOR RETIRING GRATUITY";

  static const double maxCeiling = 1200000.0;

  @override
  void initState() {
    super.initState();
    selectedDesignation = "A.T";
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        calculateAll();
      }
    });

    calculateAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameCtrl.dispose();
    schoolCtrl.dispose();
    empCodeCtrl.dispose();
    dojCtrl.dispose();
    dorCtrl.dispose();
    eolYearsCtrl.dispose();
    eolMonthsCtrl.dispose();
    basicPayCtrl.dispose();
    dpCtrl.dispose();
    super.dispose();
  }

  double _getVal(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.trim()) ?? 0.0;
  }

  int _getIntVal(TextEditingController ctrl) {
    return int.tryParse(ctrl.text.trim()) ?? 0;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      String clean = dateStr.trim().replaceAll('/', '.').replaceAll('-', '.');
      List<String> parts = clean.split('.');
      if (parts.length == 3) {
        int d = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        int y = int.parse(parts[2]);
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  // ROPA 2019 পরবর্তী সঠিক DA স্ল্যাব নির্ধারণ
  double _getDaPercentage(DateTime? dor) {
    if (dor == null) return 0.0;

    // ১ অক্টোবর ২০২৬ থেকে: ৩৮%
    if (!dor.isBefore(DateTime(2026, 10, 1))) {
      return 38.0;
    }
    // ১ এপ্রিল ২০২৫ থেকে ৩০ সেপ্টেম্বর ২০২৬ পর্যন্ত: ১৮%
    else if (!dor.isBefore(DateTime(2025, 4, 1))) {
      return 18.0;
    }
    // ১ এপ্রিল ২০২৪ থেকে ৩১ মার্চ ২০২৫ পর্যন্ত: ১৪%
    else if (!dor.isBefore(DateTime(2024, 4, 1))) {
      return 14.0;
    }
    // ১ জানুয়ারি ২০২৪ থেকে ৩১ মার্চ ২০২৪ পর্যন্ত: ১০%
    else if (!dor.isBefore(DateTime(2024, 1, 1))) {
      return 10.0;
    }
    // ১ মার্চ ২০২৩ থেকে ৩১ ডিসেম্বর ২০২৩ পর্যন্ত: ৬%
    else if (!dor.isBefore(DateTime(2023, 3, 1))) {
      return 6.0;
    }
    // ১ জানুয়ারি ২০২১ থেকে ২৮ ফেব্রুয়ারি ২০২৩ পর্যন্ত: ৩%
    else if (!dor.isBefore(DateTime(2021, 1, 1))) {
      return 3.0;
    }
    // ১ জানুয়ারি ২০২০ থেকে ৩১ ডিসেম্বর ২০২০ পর্যন্ত: ০%
    else if (!dor.isBefore(DateTime(2020, 1, 1))) {
      return 0.0;
    }

    return 0.0;
  }

  void calculateAll() {
    bool isRetiring = _tabController.index == 0;

    // ১. Joining Date থেকে Retirement/Death Date পর্যন্ত বছর ও মাস স্বয়ংক্রিয় গণনা
    DateTime? dJoin = _parseDate(dojCtrl.text);
    DateTime? dEnd = _parseDate(dorCtrl.text);

    int grossY = 0;
    int grossM = 0;

    if (dJoin != null && dEnd != null && dEnd.isAfter(dJoin)) {
      int yDiff = dEnd.year - dJoin.year;
      int mDiff = dEnd.month - dJoin.month;
      int dayDiff = dEnd.day - dJoin.day;

      if (dayDiff < 0) {
        mDiff -= 1;
      }
      if (mDiff < 0) {
        yDiff -= 1;
        mDiff += 12;
      }
      grossY = yDiff >= 0 ? yDiff : 0;
      grossM = mDiff >= 0 ? mDiff : 0;
    }

    // ২. EOL বিয়োগ
    int eolY = _getIntVal(eolYearsCtrl);
    int eolM = _getIntVal(eolMonthsCtrl);

    int totalGrossMonths = (grossY * 12) + grossM;
    int totalEolMonths = (eolY * 12) + eolM;
    int netTotalMonths = totalGrossMonths - totalEolMonths;
    if (netTotalMonths < 0) netTotalMonths = 0;

    int netYears = netTotalMonths ~/ 12;
    int remMonths = netTotalMonths % 12;

    // ৩. সর্বোচ্চ ৩৩ বছর বা ৬৬ ইউনিট সিলিং
    int cappedYears = netYears;
    int cappedMonths = remMonths;
    if (cappedYears >= 33) {
      cappedYears = 33;
      cappedMonths = 0;
    }

    // ৪. Units of Service গণনা (৩-৮ মাস = ১ ইউনিট, ৯-১২ মাস = ২ ইউনিট)
    int units = cappedYears * 2;
    if (cappedYears < 33) {
      if (cappedMonths >= 3 && cappedMonths <= 8) {
        units += 1;
      } else if (cappedMonths >= 9) {
        units += 2;
      }
    }
    if (units > 66) units = 66;

    // ৫. তারিখ অনুসারে DA হার এবং Emoluments নির্ধারণ
    double currentDaRate = _getDaPercentage(dEnd);
    double basic = _getVal(basicPayCtrl);
    double dp = _getVal(dpCtrl);
    double da = ((basic * currentDaRate) / 100.0).roundToDouble();
    double emoluments = basic + dp + da;

    // ৬. Gratuity ফর্মুলা হিসাব
    double calcGratuity = 0.0;
    String status = "";

    if (isRetiring) {
      if (netYears < 1 && units == 0) {
        status = "NOT ELIGIBLE (Min 1 Year Req.)";
        calcGratuity = 0.0;
      } else {
        status = "ELIGIBLE FOR RETIRING GRATUITY";
        if (netYears < 10) {
          calcGratuity = (emoluments * units) / 2.0;
        } else {
          calcGratuity = (emoluments * units) / 4.0;
        }
      }
    } else {
      status = "ELIGIBLE FOR DEATH GRATUITY";
      if (netYears < 1) {
        calcGratuity = emoluments * 2.0;
      } else if (netYears < 5) {
        calcGratuity = emoluments * 6.0;
      } else if (netYears < 11) {
        calcGratuity = emoluments * 12.0;
      } else if (netYears < 20) {
        calcGratuity = emoluments * 20.0;
      } else {
        calcGratuity = (emoluments / 2.0) * units;
      }
    }

    // ৭. সর্বোচ্চ সিলিং ১২,০০,০০০ টাকা
    double finalPayable = calcGratuity > maxCeiling ? maxCeiling : calcGratuity;

    setState(() {
      grossYearsText = grossY.toString();
      grossMonthsText = grossM.toString();
      netServiceText = "$netYears Yrs $remMonths Mos";
      unitsText = units.toString();
      daPercent = currentDaRate;
      daAmountText = da.toStringAsFixed(0);
      totalEmolumentsText = emoluments.toStringAsFixed(0);
      calculatedGratuityText = calcGratuity.toStringAsFixed(0);
      payableGratuityText = finalPayable.toStringAsFixed(0);
      eligibilityText = status;
    });
  }

  Future<void> _generatePdf() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(_buildPdfPage(_tabController.index == 0));
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating PDF: $e")),
        );
      }
    }
  }

  pw.Page _buildPdfPage(bool isRetiring) {
    String gratuityType = isRetiring ? "RETIRING GRATUITY" : "DEATH GRATUITY";
    String formulaText = "";

    int netY = int.tryParse(grossYearsText) ?? 0;
    netY -= _getIntVal(eolYearsCtrl);

    if (isRetiring) {
      if (netY < 10) {
        formulaText = "Emoluments x Units / 2 (Below 10 Yrs)";
      } else {
        formulaText = "Emoluments x Units / 4 (10 Yrs & Above)";
      }
    } else {
      if (netY < 1) {
        formulaText = "Emoluments x 2 (Less than 1 Yr)";
      } else if (netY < 5) {
        formulaText = "Emoluments x 6 (1 to <5 Yrs)";
      } else if (netY < 11) {
        formulaText = "Emoluments x 12 (5 to <11 Yrs)";
      } else if (netY < 20) {
        formulaText = "Emoluments x 20 (11 to <20 Yrs)";
      } else {
        formulaText = "(Emoluments / 2) x Units (20 Yrs & Above)";
      }
    }

    String daHeader = "Dearness Allowance (DA @ ${daPercent.toStringAsFixed(0)}%)";

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(left: 36, right: 36, top: 240, bottom: 25),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                ":-: GRATUITY COMPUTATION SHEET :-:",
                style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                "[ $gratuityType UNDER DCRB RULES ]",
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 8),

            // Employee Information
            pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.6)),
              child: pw.Column(
                children: [
                  pw.Row(children: [
                    _pdfHeaderBox("EMPLOYEE NAME", nameCtrl.text),
                    _pdfHeaderBox("DESIGNATION", selectedDesignation)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("INSTITUTION NAME", schoolCtrl.text)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("EMPLOYEE CODE", empCodeCtrl.text),
                    _pdfHeaderBox("STATUS", eligibilityText)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("DATE OF JOINING", dojCtrl.text),
                    _pdfHeaderBox(
                        isRetiring ? "DATE OF RETIREMENT" : "DATE OF DEATH",
                        dorCtrl.text)
                  ]),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Computation Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
              columnWidths: {
                0: const pw.FixedColumnWidth(26),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(105),
              },
              children: [
                _buildPdfRow("Sl", "Particulars & Description", "Amount / Value",
                    isHeader: true),
                _buildPdfRow("1", "Gross Service (Years)", "$grossYearsText Yrs"),
                _buildPdfRow("2", "Gross Service (Months)", "$grossMonthsText Mos"),
                _buildPdfRow("3", "Less: Extra Ordinary Leave (EOL Years)",
                    "${eolYearsCtrl.text} Yrs"),
                _buildPdfRow("4", "Less: Extra Ordinary Leave (EOL Months)",
                    "${eolMonthsCtrl.text} Mos"),
                _buildPdfRow("5", "Net Qualifying Service", netServiceText,
                    isBold: true),
                _buildPdfRow("6", "Total Six-Monthly Units (Max 66)",
                    "$unitsText Units",
                    isBold: true),
                _buildPdfRow("7", "Last Basic Pay",
                    "Rs. ${_getVal(basicPayCtrl).toStringAsFixed(0)}"),
                _buildPdfRow("8", "Dearness Pay (DP)",
                    "Rs. ${_getVal(dpCtrl).toStringAsFixed(0)}"),
                _buildPdfRow("9", daHeader, "Rs. $daAmountText"),
                _buildPdfRow(
                    "10",
                    "Total Emoluments (Basic+DP+DA)",
                    "Rs. $totalEmolumentsText",
                    isBold: true),
                _buildPdfRow("11", "Applicable Formula", formulaText),
                _buildPdfRow("12", "Gross Calculated Gratuity",
                    "Rs. $calculatedGratuityText",
                    isBold: true),
                _buildPdfRow("13", "Statutory Upper Ceiling Limit",
                    "Rs. ${maxCeiling.toStringAsFixed(0)}"),
                _buildPdfRow("14", "Net Admissible Gratuity Payable",
                    "Rs. $payableGratuityText",
                    isBold: true),
              ],
            ),

            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
              ),
              child: pw.Text(
                "Verified and found correct according to West Bengal Government Aided Educational Institution Employees (DCRB) Rules.",
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.Spacer(),

            // Signature Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Signature of Head of the Institution",
                      style: pw.TextStyle(
                          fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      "With Date & Seal",
                      style: pw.TextStyle(
                          fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      isRetiring
                          ? "Signature of the Employee"
                          : "Signature of the Nominee / Claimant",
                      style: pw.TextStyle(
                          fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 12),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
          ],
        );
      },
    );
  }

  pw.Widget _pdfHeaderBox(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text: "$title: ",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
              pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 7.5)),
            ],
          ),
        ),
      ),
    );
  }

  pw.TableRow _buildPdfRow(String sl, String desc, String amt,
      {bool isHeader = false, bool isBold = false}) {
    return pw.TableRow(
      decoration:
          isHeader ? const pw.BoxDecoration(color: PdfColors.grey300) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.2, horizontal: 4),
          child: pw.Text(sl,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 7.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.2, horizontal: 5),
          child: pw.Text(desc,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 7.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3.2, horizontal: 5),
          child: pw.Text(amt,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 7.5)),
        ),
      ],
    );
  }

  Widget _buildDisplayRow(String slNo, String title, String value,
      {bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight ? Colors.amber.shade100 : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.grey.shade400),
          right: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade400))),
            child: Text(slNo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title,
                  style: TextStyle(
                      fontWeight:
                          isHighlight ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12)),
            ),
          ),
          Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade400)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isHighlight ? Colors.red.shade900 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(
      String slNo, String title, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
          left: BorderSide(color: Colors.grey.shade400),
          right: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade400))),
            child: Text(slNo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title, style: const TextStyle(fontSize: 12)),
            ),
          ),
          Container(
            width: 130,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: Border(left: BorderSide(color: Colors.grey.shade400)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) => calculateAll(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerTextField(String label, TextEditingController controller,
      {bool triggerDateCalc = false}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: triggerDateCalc ? (val) => calculateAll() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDropdownField(String label) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDesignation,
                isDense: true,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                items: designationList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedDesignation = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRetiring = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("WB School Gratuity Calculator"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 4,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          onTap: (index) {
            FocusScope.of(context).unfocus();
          },
          tabs: const [
            Tab(text: 'RETIRING GRATUITY'),
            Tab(text: 'DEATH GRATUITY'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _generatePdf,
            tooltip: "Download PDF Calculation Sheet",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            // Employee Information Header
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade600, width: 1.2)),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        flex: 2,
                        child: _headerTextField('EMPLOYEE NAME:', nameCtrl)),
                    Expanded(
                        flex: 1,
                        child: _headerDropdownField('DESIGNATION:')),
                  ]),
                  _headerTextField('INSTITUTION NAME:', schoolCtrl),
                  Row(children: [
                    Expanded(
                        child: _headerTextField('EMPLOYEE CODE:', empCodeCtrl)),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      child: Text('STATUS: $eligibilityText',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    )),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _headerTextField('JOINING DATE:', dojCtrl,
                            triggerDateCalc: true)),
                    Expanded(
                        child: _headerTextField(
                            isRetiring ? 'RETIREMENT DATE:' : 'DEATH DATE:',
                            dorCtrl,
                            triggerDateCalc: true)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table Header Bar
            Container(
              decoration: BoxDecoration(
                  color: Colors.teal.shade700,
                  border:
                      Border.all(color: Colors.grey.shade700, width: 1.2)),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: const BoxDecoration(
                        border:
                            Border(right: BorderSide(color: Colors.white38))),
                    child: const Text("Sl",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white)),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Particulars / Component",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white)),
                    ),
                  ),
                  Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: const BoxDecoration(
                        border:
                            Border(left: BorderSide(color: Colors.white38))),
                    child: const Text("Value / Amount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),

            // Serial 1 & 2: তারিখ থেকে স্বয়ংক্রিয় মোট সার্ভিস
            _buildDisplayRow("1", "Gross Service (Years)", grossYearsText),
            _buildDisplayRow("2", "Gross Service (Months)", grossMonthsText),

            // Serial 3 & 4: ম্যানুয়াল EOL ইনপুট
            _buildInputRow("3", "Less: EOL / LWP (Years)", eolYearsCtrl),
            _buildInputRow("4", "Less: EOL / LWP (Months)", eolMonthsCtrl),

            // Serial 5 & 6: স্বয়ংক্রিয় Net Service & Units
            _buildDisplayRow("5", "Net Qualifying Service", netServiceText),
            _buildDisplayRow("6", "Calculated Units of Service", unitsText),

            // Serial 7 & 8: ম্যানুয়াল Basic ও DP ইনপুট
            _buildInputRow("7", "Last Basic Pay (Rs.)", basicPayCtrl),
            _buildInputRow("8", "Dearness Pay - DP (Rs.)", dpCtrl),

            // Serial 9: তারিখ অনুসারে স্বয়ংক্রিয় DA
            _buildDisplayRow(
                "9",
                "Dearness Allowance - DA (${daPercent.toStringAsFixed(0)}%)",
                daAmountText),

            // Serial 10: 7+8+9 এর স্বয়ংক্রিয় যোগফল
            _buildDisplayRow("10", "Total Emoluments (Basic+DP+DA)",
                "Rs. $totalEmolumentsText"),

            // Serial 11: সূত্রানুসারে Gratuity
            _buildDisplayRow("11", "Calculated Gratuity (Formula)",
                "Rs. $calculatedGratuityText"),

            // Serial 12: সর্বোচ্চ ১২ লাখ টাকা সিলিং
            _buildDisplayRow("12", "Payable Gratuity (Max 12 Lakhs)",
                "Rs. $payableGratuityText",
                isHighlight: true),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
