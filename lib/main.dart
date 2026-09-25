import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
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
  final designationCtrl = TextEditingController(text: "Assistant Teacher");
  final schoolCtrl =
      TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final empCodeCtrl = TextEditingController(text: "WBED202401");
  final dojCtrl = TextEditingController(text: "01/04/2000");
  final dorCtrl = TextEditingController(text: "31/03/2026");

  // Service Inputs
  final grossYearsCtrl = TextEditingController(text: "26");
  final grossMonthsCtrl = TextEditingController(text: "0");
  final eolYearsCtrl = TextEditingController(text: "0");
  final eolMonthsCtrl = TextEditingController(text: "0");

  // Emoluments Inputs
  final basicPayCtrl = TextEditingController(text: "55000");
  final dpCtrl = TextEditingController(text: "0");
  final daCtrl = TextEditingController(text: "7700");

  // Computed Outputs
  final netServiceCtrl = TextEditingController();
  final unitsCtrl = TextEditingController();
  final totalEmolumentsCtrl = TextEditingController();
  final calculatedGratuityCtrl = TextEditingController();
  final payableGratuityCtrl = TextEditingController();
  final eligibilityCtrl = TextEditingController();

  static const double maxCeiling = 1200000.0; // West Bengal Gratuity Ceiling

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        calculateGratuity();
      }
    });
    calculateGratuity();
  }

  double getVal(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.trim()) ?? 0.0;
  }

  int getIntVal(TextEditingController ctrl) {
    return int.tryParse(ctrl.text.trim()) ?? 0;
  }

  void calculateGratuity() {
    setState(() {
      bool isRetiring = _tabController.index == 0;

      int grossY = getIntVal(grossYearsCtrl);
      int grossM = getIntVal(grossMonthsCtrl);
      int eolY = getIntVal(eolYearsCtrl);
      int eolM = getIntVal(eolMonthsCtrl);

      int totalGrossMonths = (grossY * 12) + grossM;
      int totalEolMonths = (eolY * 12) + eolM;
      int netTotalMonths = totalGrossMonths - totalEolMonths;
      if (netTotalMonths < 0) netTotalMonths = 0;

      int netYears = netTotalMonths ~/ 12;
      int remMonths = netTotalMonths % 12;

      netServiceCtrl.text = "$netYears Yrs $remMonths Mos";

      // Cap at 33 years
      int cappedYears = netYears;
      int cappedMonths = remMonths;
      if (cappedYears >= 33) {
        cappedYears = 33;
        cappedMonths = 0;
      }

      // Calculate Units of Service:
      // 3-8 months = 1 unit, 9-12 months = 2 units
      int units = cappedYears * 2;
      if (cappedYears < 33) {
        if (cappedMonths >= 3 && cappedMonths <= 8) {
          units += 1;
        } else if (cappedMonths >= 9) {
          units += 2;
        }
      }
      if (units > 66) units = 66; // Max 66 units for 33 years
      unitsCtrl.text = units.toString();

      // Emoluments
      double basic = getVal(basicPayCtrl);
      double dp = getVal(dpCtrl);
      double da = getVal(daCtrl);
      double emoluments = basic + dp + da;
      totalEmolumentsCtrl.text = emoluments.toStringAsFixed(0);

      double calcGratuity = 0.0;

      if (isRetiring) {
        // Retiring Gratuity Eligibility: Minimum 1 year
        if (netYears < 1 && units == 0) {
          eligibilityCtrl.text = "NOT ELIGIBLE (Min 1 Year Service Required)";
          calcGratuity = 0.0;
        } else {
          eligibilityCtrl.text = "ELIGIBLE FOR RETIRING GRATUITY";
          if (netYears < 10) {
            // Less than 10 years: Emoluments * Units / 2
            calcGratuity = (emoluments * units) / 2.0;
          } else {
            // 10 years or more: Emoluments * Units / 4
            calcGratuity = (emoluments * units) / 4.0;
          }
        }
      } else {
        // Death Gratuity Eligibility: 1 day service
        eligibilityCtrl.text = "ELIGIBLE FOR DEATH GRATUITY";

        if (netYears < 1) {
          calcGratuity = emoluments * 2.0;
        } else if (netYears < 5) {
          calcGratuity = emoluments * 6.0;
        } else if (netYears < 11) {
          calcGratuity = emoluments * 12.0;
        } else if (netYears < 20) {
          calcGratuity = emoluments * 20.0;
        } else {
          // 20 years or more: Half of Emoluments * Units
          calcGratuity = (emoluments / 2.0) * units;
        }
      }

      calculatedGratuityCtrl.text = calcGratuity.toStringAsFixed(0);

      // Max ceiling cap
      double finalPayable = calcGratuity > maxCeiling ? maxCeiling : calcGratuity;
      payableGratuityCtrl.text = finalPayable.toStringAsFixed(0);
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(_buildPdfPage(_tabController.index == 0));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Page _buildPdfPage(bool isRetiring) {
    String gratuityType = isRetiring ? "RETIRING GRATUITY" : "DEATH GRATUITY";
    String formulaText = "";

    int netY = getIntVal(grossYearsCtrl) - getIntVal(eolYearsCtrl);
    int units = int.tryParse(unitsCtrl.text) ?? 0;
    double emols = getVal(totalEmolumentsCtrl);

    if (isRetiring) {
      if (netY < 10) {
        formulaText = "Emoluments x Units / 2 (Below 10 Yrs)";
      } else {
        formulaText = "Emoluments x Units / 4 (10 Yrs & Above)";
      }
    } else {
      if (netY < 1) formulaText = "Emoluments x 2 (Less than 1 Yr)";
      else if (netY < 5) formulaText = "Emoluments x 6 (1 to <5 Yrs)";
      else if (netY < 11) formulaText = "Emoluments x 12 (5 to <11 Yrs)";
      else if (netY < 20) formulaText = "Emoluments x 20 (11 to <20 Yrs)";
      else formulaText = "(Emoluments / 2) x Units (20 Yrs & Above)";
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                ":-: GRATUITY COMPUTATION SHEET :-:",
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                "[ $gratuityType UNDER DCRB RULES ]",
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 12),

            // Employee Information Card
            pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.6)),
              child: pw.Column(
                children: [
                  pw.Row(children: [
                    _pdfHeaderBox("EMPLOYEE NAME", nameCtrl.text),
                    _pdfHeaderBox("DESIGNATION", designationCtrl.text)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("INSTITUTION NAME", schoolCtrl.text)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("EMPLOYEE CODE", empCodeCtrl.text),
                    _pdfHeaderBox("ELIGIBILITY", eligibilityCtrl.text)
                  ]),
                  pw.Row(children: [
                    _pdfHeaderBox("DATE OF JOINING", dojCtrl.text),
                    _pdfHeaderBox(isRetiring ? "DATE OF RETIREMENT" : "DATE OF DEATH", dorCtrl.text)
                  ]),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Computation Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(110),
              },
              children: [
                _buildPdfRow("Sl", "Particulars & Description", "Amount / Value", isHeader: true),
                _buildPdfRow("1", "Gross Total Service (Yrs & Months)", "${grossYearsCtrl.text} Yrs ${grossMonthsCtrl.text} Mos"),
                _buildPdfRow("2", "Less: Extra Ordinary Leave (EOL / LWP)", "${eolYearsCtrl.text} Yrs ${eolMonthsCtrl.text} Mos"),
                _buildPdfRow("3", "Net Qualifying Service", netServiceCtrl.text, isBold: true),
                _buildPdfRow("4", "Total Six-Monthly Units of Service (Max 66)", "${unitsCtrl.text} Units", isBold: true),
                _buildPdfRow("5", "Last Basic Pay", "Rs. ${getVal(basicPayCtrl).toStringAsFixed(0)}"),
                _buildPdfRow("6", "Dearness Pay (DP)", "Rs. ${getVal(dpCtrl).toStringAsFixed(0)}"),
                _buildPdfRow("7", "Dearness Allowance (DA)", "Rs. ${getVal(daCtrl).toStringAsFixed(0)}"),
                _buildPdfRow("8", "Total Emoluments (Basic + DP + DA)", "Rs. ${totalEmolumentsCtrl.text}", isBold: true),
                _buildPdfRow("9", "Applicable Rule / Formula", formulaText),
                _buildPdfRow("10", "Gross Calculated Gratuity", "Rs. ${calculatedGratuityCtrl.text}", isBold: true),
                _buildPdfRow("11", "Statutory Upper Ceiling Limit", "Rs. ${maxCeiling.toStringAsFixed(0)}"),
                _buildPdfRow("12", "Net Admissible Gratuity Payable", "Rs. ${payableGratuityCtrl.text}", isBold: true),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
              ),
              child: pw.Text(
                "Verified and found correct according to West Bengal Recognized Non-Government Aided Educational Institution Employees (DCRB) Rules.",
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.Spacer(),
            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Signature of Head of the Institution",
                      style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "With Date & Seal",
                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      isRetiring ? "Signature of the Employee" : "Signature of the Nominee / Claimant",
                      style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 14),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
        );
      },
    );
  }

  pw.Widget _pdfHeaderBox(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 5),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text: "$title: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
              pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 8)),
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
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          child: pw.Text(sl,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 8.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
          child: pw.Text(desc,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 8.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
          child: pw.Text(amt,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
                  fontSize: 8.5)),
        ),
      ],
    );
  }

  Widget _buildInputRow(
      String slNo, String title, TextEditingController controller,
      {bool isReadOnly = false, String hint = ""}) {
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade400))),
            child: Text(slNo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title,
                  style: TextStyle(
                      fontWeight:
                          isReadOnly ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12)),
            ),
          ),
          Container(
            width: 130,
            decoration: BoxDecoration(
              color: isReadOnly ? Colors.grey.shade200 : Colors.teal.shade50,
              border: Border(left: BorderSide(color: Colors.grey.shade400)),
            ),
            child: TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) => calculateGratuity(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
            // Employee Header Information Table
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
                        child: _headerTextField('DESIGNATION:', designationCtrl)),
                  ]),
                  _headerTextField('INSTITUTION NAME:', schoolCtrl),
                  Row(children: [
                    Expanded(
                        child: _headerTextField('EMPLOYEE CODE:', empCodeCtrl)),
                    Expanded(
                        child: _headerTextField('STATUS:', eligibilityCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _headerTextField('JOINING DATE:', dojCtrl)),
                    Expanded(
                        child: _headerTextField(
                            isRetiring ? 'RETIREMENT DATE:' : 'DEATH DATE:',
                            dorCtrl)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table Header Bar
            Container(
              decoration: BoxDecoration(
                  color: Colors.teal.shade700,
                  border: Border.all(color: Colors.grey.shade700, width: 1.2)),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.white38))),
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
                        border: Border(left: BorderSide(color: Colors.white38))),
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

            // Service rows
            _buildInputRow("1", "Gross Service (Years)", grossYearsCtrl),
            _buildInputRow("2", "Gross Service (Months)", grossMonthsCtrl),
            _buildInputRow("3", "Less: EOL / LWP (Years)", eolYearsCtrl),
            _buildInputRow("4", "Less: EOL / LWP (Months)", eolMonthsCtrl),
            _buildInputRow("5", "Net Qualifying Service", netServiceCtrl,
                isReadOnly: true),
            _buildInputRow("6", "Calculated Units of Service (Max 66)",
                unitsCtrl,
                isReadOnly: true),

            // Emoluments rows
            _buildInputRow("7", "Last Basic Pay (Rs.)", basicPayCtrl),
            _buildInputRow("8", "Dearness Pay - DP (Rs.)", dpCtrl),
            _buildInputRow("9", "Dearness Allowance - DA (Rs.)", daCtrl),
            _buildInputRow("10", "Total Emoluments (Basic+DP+DA)",
                totalEmolumentsCtrl,
                isReadOnly: true),

            // Final Outputs
            _buildInputRow("11", "Calculated Gratuity (Formula Basis)",
                calculatedGratuityCtrl,
                isReadOnly: true),
            _buildInputRow("12", "Payable Gratuity (Capped at 12 Lakhs)",
                payableGratuityCtrl,
                isReadOnly: true),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
