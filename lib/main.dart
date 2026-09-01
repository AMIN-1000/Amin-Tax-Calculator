import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math';

void main() {
  runApp(const TaxCalculatorApp());
}

class TaxCalculatorApp extends StatelessWidget {
  const TaxCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Amin Tax Calculator",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
        )
      ),
      home: const TaxHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaxHomeScreen extends StatefulWidget {
  const TaxHomeScreen({super.key});

  @override
  State<TaxHomeScreen> createState() => _TaxHomeScreenState();
}

class _TaxHomeScreenState extends State<TaxHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _prevTabIndex = 0; 

  // Header Details 
  final nameCtrl = TextEditingController(text: "MD RUHUL AMIN MONDAL");
  final designationCtrl = TextEditingController(text: "A.T.");
  final institutionCtrl = TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final empCodeCtrl = TextEditingController(text: "BDFF2107");
  final panCtrl = TextEditingController(text: "AWUPM0023B");
  final finYearCtrl = TextEditingController(text: "2025-26");
  final assessYearCtrl = TextEditingController(text: "2026-27");

  // Inputs
  final i7GrossSalary = TextEditingController();
  final i8Arrear = TextEditingController();
  final i10HRA = TextEditingController();
  
  final i18GrossRent = TextEditingController();
  final i19TaxLocalAuth = TextEditingController();
  final i22HomeLoanInt = TextEditingController();
  
  final i25BankInt = TextEditingController();
  final i26FDInt = TextEditingController();
  final i27OtherSource = TextEditingController();
  
  final i32_43Total80C = TextEditingController(); 
  final i45_56TotalOtherDed = TextEditingController(); 
  
  final i68STCG = TextEditingController();
  final i69LTCG = TextEditingController();
  final i71TaxPaidJan = TextEditingController();
  final i72TaxPaidFeb = TextEditingController();

  // ReadOnly Output
  final totalSalCtrl = TextEditingController();
  final stdDedCtrl = TextEditingController();
  final pTaxCtrl = TextEditingController();
  final netSalCtrl = TextEditingController();
  final totalHousePropCtrl = TextEditingController();
  final totalOtherSrcCtrl = TextEditingController();
  final grossTotalCtrl = TextEditingController();
  
  final serial10Ctrl = TextEditingController(); 
  final totalDedCtrl = TextEditingController();
  
  final taxableIncomeCtrl = TextEditingController();
  final taxOnIncomeCtrl = TextEditingController();
  final rebateCtrl = TextEditingController();
  final cessCtrl = TextEditingController();
  final totalTaxCessCtrl = TextEditingController();
  final finalTaxPayableCtrl = TextEditingController();
  final statusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      if (_tabController.index != _prevTabIndex) {
        _prevTabIndex = _tabController.index;
        
        if (_tabController.index == 1) { 
          i32_43Total80C.clear();
          i45_56TotalOtherDed.clear();
        }
        i72TaxPaidFeb.clear();
        calculateTax(); 
      }
    });
  }

  double getVal(TextEditingController ctrl) {
    return double.tryParse(ctrl.text) ?? 0.0;
  }

  void calculateTax() {
    setState(() {
      bool isOld = _tabController.index == 0;
      
      double i7 = getVal(i7GrossSalary);
      double i8 = getVal(i8Arrear);
      double i10 = getVal(i10HRA);
      double i18 = getVal(i18GrossRent);
      double i19 = getVal(i19TaxLocalAuth);
      double i22 = getVal(i22HomeLoanInt);
      double i25 = getVal(i25BankInt); 
      double i26 = getVal(i26FDInt);
      double i27 = getVal(i27OtherSource);
      double total80C = getVal(i32_43Total80C);
      double totalOtherDed = getVal(i45_56TotalOtherDed); 
      double i68 = getVal(i68STCG);
      double i69 = getVal(i69LTCG);
      double i71 = getVal(i71TaxPaidJan);
      double i72 = getVal(i72TaxPaidFeb);

      double grossSal = i7 + i8;
      totalSalCtrl.text = grossSal.toStringAsFixed(0);
      
      double stdDed = isOld ? (grossSal > 50000 ? 50000 : grossSal) : (grossSal > 75000 ? 75000 : grossSal);
      stdDedCtrl.text = stdDed.toStringAsFixed(0);
      
      double pTax = 0;
      if (isOld) {
        if (grossSal <= 120000) pTax = 0;
        else if (grossSal <= 180000) pTax = 1320;
        else if (grossSal <= 300000) pTax = 1560;
        else if (grossSal <= 480000) pTax = 1800;
        else pTax = 2400;
      }
      pTaxCtrl.text = pTax.toStringAsFixed(0);

      double salIncome = grossSal - stdDed - pTax - i10;
      netSalCtrl.text = salIncome.toStringAsFixed(0);

      double houseIncome = (i18 - i19) - ((i18 - i19) * 0.3) - i22;
      totalHousePropCtrl.text = houseIncome.toStringAsFixed(0);

      double otherIncome = i25 + i26 + i27; 
      totalOtherSrcCtrl.text = otherIncome.toStringAsFixed(0);

      double gross = salIncome + houseIncome + otherIncome;
      grossTotalCtrl.text = gross.toStringAsFixed(0);

      double ded80C = total80C > 150000 ? 150000 : total80C;
      double ded80TTA = isOld ? min(i25, 10000.0) : 0.0; 
      
      double totalOther = isOld ? (totalOtherDed + ded80TTA) : 0.0;
      serial10Ctrl.text = totalOther.toStringAsFixed(0);

      double totalDed = isOld ? (ded80C + totalOther) : 0.0; 
      totalDedCtrl.text = totalDed.toStringAsFixed(0);

      double taxable = ((gross - totalDed) / 10).roundToDouble() * 10;
      if(taxable < 0) taxable = 0;
      taxableIncomeCtrl.text = taxable.toStringAsFixed(0);

      double tax = 0;
      if (isOld) {
        if (taxable > 1000000) tax = (taxable - 1000000) * 0.3 + 112500;
        else if (taxable > 500000) tax = (taxable - 500000) * 0.2 + 12500;
        else if (taxable > 250000) tax = (taxable - 250000) * 0.05;
      } else {
        if (taxable > 2400000) tax = (taxable - 2000000) * 0.3 + 200000;
        else if (taxable > 2000000) tax = (taxable - 2000000) * 0.25 + 200000;
        else if (taxable > 1600000) tax = (taxable - 1600000) * 0.2 + 120000;
        else if (taxable > 1200000) tax = (taxable - 1200000) * 0.15 + 60000;
        else if (taxable > 800000) tax = (taxable - 800000) * 0.1 + 20000;
        else if (taxable > 400000) tax = (taxable - 400000) * 0.05;
      }
      taxOnIncomeCtrl.text = tax.toStringAsFixed(0);

      double rebate = isOld ? (taxable <= 500000 ? min(tax, 12500) : 0) : (taxable <= 1200000 ? tax : 0);
      rebateCtrl.text = rebate.toStringAsFixed(0);
      
      double afterRebate = tax - rebate;
      double cess = (afterRebate * 0.04).roundToDouble();
      cessCtrl.text = cess.toStringAsFixed(0);
      
      double totalTax = ((afterRebate + cess) / 10).roundToDouble() * 10;
      totalTaxCessCtrl.text = totalTax.toStringAsFixed(0);

      double finalTax = totalTax + (i68 * 0.2) + (i69 > 125000 ? (i69 - 125000) * 0.125 : 0);
      finalTaxPayableCtrl.text = finalTax.toStringAsFixed(0);

      double totalPaid = i71 + i72;
      if (totalPaid > finalTax) statusCtrl.text = "REFUNDABLE: ${totalPaid - finalTax}";
      else if (totalPaid < finalTax) statusCtrl.text = "PAYABLE: ${finalTax - totalPaid}";
      else statusCtrl.text = "NIL";
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(_buildRegimePdfPage(true)); 
    pdf.addPage(_buildRegimePdfPage(false)); 
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Page _buildRegimePdfPage(bool isOld) {
    bool isActiveRegime = isOld == (_tabController.index == 0);

    double i7 = getVal(i7GrossSalary);
    double i8 = getVal(i8Arrear);
    double i10 = getVal(i10HRA);
    double i18 = getVal(i18GrossRent);
    double i19 = getVal(i19TaxLocalAuth);
    double i22 = getVal(i22HomeLoanInt);
    double i25 = getVal(i25BankInt);
    double i26 = getVal(i26FDInt);
    double i27 = getVal(i27OtherSource);
    double total80C = isOld ? getVal(i32_43Total80C) : 0.0;
    double totalOtherDed = isOld ? getVal(i45_56TotalOtherDed) : 0.0;
    double i68 = getVal(i68STCG);
    double i69 = getVal(i69LTCG);
    double i71 = getVal(i71TaxPaidJan);

    double grossSal = i7 + i8;
    double stdDed = isOld ? (grossSal > 50000 ? 50000 : grossSal) : (grossSal > 75000 ? 75000 : grossSal);
    
    double pTax = 0;
    if (isOld) {
      if (grossSal <= 120000) pTax = 0;
      else if (grossSal <= 180000) pTax = 1320;
      else if (grossSal <= 300000) pTax = 1560;
      else if (grossSal <= 480000) pTax = 1800;
      else pTax = 2400;
    }
    
    double salIncome = grossSal - stdDed - pTax - i10;
    
    double houseIncome30 = (i18 - i19) * 0.3;
    double houseIncome = (i18 - i19) - houseIncome30 - i22;
    double otherIncome = i25 + i26 + i27;
    double gross = salIncome + houseIncome + otherIncome;
    
    double ded80C = total80C > 150000 ? 150000 : total80C;
    double ded80TTA = isOld ? min(i25, 10000.0) : 0.0;
    double totalOther = isOld ? (totalOtherDed + ded80TTA) : 0.0;
    double totalDed = isOld ? (ded80C + totalOther) : 0.0; 
    
    double taxable = ((gross - totalDed) / 10).roundToDouble() * 10;
    if(taxable < 0) taxable = 0;
    
    double tax = 0;
    if (isOld) {
      if (taxable > 1000000) tax = (taxable - 1000000) * 0.3 + 112500;
      else if (taxable > 500000) tax = (taxable - 500000) * 0.2 + 12500;
      else if (taxable > 250000) tax = (taxable - 250000) * 0.05;
    } else {
      if (taxable > 2400000) tax = (taxable - 2000000) * 0.3 + 200000;
      else if (taxable > 2000000) tax = (taxable - 2000000) * 0.25 + 200000;
      else if (taxable > 1600000) tax = (taxable - 1600000) * 0.2 + 120000;
      else if (taxable > 1200000) tax = (taxable - 1200000) * 0.15 + 60000;
      else if (taxable > 800000) tax = (taxable - 800000) * 0.1 + 20000;
      else if (taxable > 400000) tax = (taxable - 400000) * 0.05;
    }
    
    double rebate = isOld ? (taxable <= 500000 ? min(tax, 12500) : 0) : (taxable <= 1200000 ? tax : 0);
    double afterRebate = tax - rebate;
    double cess = (afterRebate * 0.04).roundToDouble();
    double totalTax = ((afterRebate + cess) / 10).roundToDouble() * 10;
    
    double capitalGainTax = (i68 * 0.2) + (i69 > 125000 ? (i69 - 125000) * 0.125 : 0);
    double finalTax = totalTax + capitalGainTax;
    
    double i72 = 0;
    if (isActiveRegime) {
      i72 = getVal(i72TaxPaidFeb);
    } else {
      i72 = finalTax - i71;
      if (i72 < 0) i72 = 0;
    }

    double totalPaid = i71 + i72;
    String status = "";
    if (totalPaid > finalTax) status = "REFUNDABLE: ${totalPaid - finalTax}";
    else if (totalPaid < finalTax) status = "PAYABLE: ${finalTax - totalPaid}";
    else status = "NIL";

    String headerTxt = isOld 
      ? ':-: INCOME TAX COMPUTATION SHEET :-: [ UNDER OLD REGIME ]'
      : ':-: INCOME TAX COMPUTATION SHEET :-: [ UNDER NEW REGIME ]';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(left: 50, right: 50, top: 71, bottom: 50),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Center(child: pw.Text(headerTxt, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 15),
            
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5)),
              child: pw.Column(
                children: [
                  pw.Row(children: [_pdfHeaderBox("EMPLOYEE NAME", nameCtrl.text), _pdfHeaderBox("DESIGNATION", designationCtrl.text)]),
                  pw.Row(children: [_pdfHeaderBox("INSTITUTION NAME", institutionCtrl.text)]),
                  pw.Row(children: [_pdfHeaderBox("EMPLOYEE CODE", empCodeCtrl.text), _pdfHeaderBox("PAN", panCtrl.text)]),
                  pw.Row(children: [_pdfHeaderBox("FINANCIAL YEAR", finYearCtrl.text), _pdfHeaderBox("ASSESSMENT YEAR", assessYearCtrl.text)]),
                ]
              )
            ),
            pw.SizedBox(height: 10),
            
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(65),
              },
              children: [
                _buildPdfRow("Sl", "Description", "Amount", isHeader: true),
                _buildPdfRow("1", "Gross Salary (a)", i7.toStringAsFixed(0)),
                _buildPdfRow("", "Arrear (b)", i8.toStringAsFixed(0)),
                _buildPdfRow("", "Total (a+b)", grossSal.toStringAsFixed(0), isBold: true),
                _buildPdfRow("2", "Less: Standard Deduction u/s 16(1a)", stdDed.toStringAsFixed(0)),
                _buildPdfRow("", "Less: Professional Tax", pTax.toStringAsFixed(0)), 
                _buildPdfRow("", "Less: House Rent Allowance u/s 10(13A)", i10.toStringAsFixed(0)),
                _buildPdfRow("3", "Income chargeable under 'Salary'", salIncome.toStringAsFixed(0), isBold: true),
                
                _buildPdfRow("4", "Gross Rent Received (a)", i18.toStringAsFixed(0)),
                _buildPdfRow("", "Tax paid to local authorities (b)", i19.toStringAsFixed(0)),
                _buildPdfRow("", "30% Standard Deduction on Net Rent", houseIncome30.toStringAsFixed(0)),
                _buildPdfRow("", "Interest Payable on Borrowed Cap u/s 24(b)", i22.toStringAsFixed(0)),
                _buildPdfRow("5", "Income Chargeable Under House Property", houseIncome.toStringAsFixed(0), isBold: true), 
                
                _buildPdfRow("6", "Interest on Saving Bank / FD / Others", otherIncome.toStringAsFixed(0)),
                _buildPdfRow("7", "Gross total income (3+5+6)", gross.toStringAsFixed(0), isBold: true),
                
                _buildPdfRow("8", "Total Deduction u/s 80C", ded80C.toStringAsFixed(0)),
                _buildPdfRow("9", "Total Other Deductions (80D/80G/80TTA Etc.)", totalOther.toStringAsFixed(0)), 
                _buildPdfRow("10", "Total deduction allowed", totalDed.toStringAsFixed(0), isBold: true),
                
                _buildPdfRow("11", "Total taxable income (Rounded off)", taxable.toStringAsFixed(0), isBold: true),
                _buildPdfRow("12", "Tax on Taxable Income", tax.toStringAsFixed(0)),
                _buildPdfRow("13", "Tax Rebate u/s 87A", rebate.toStringAsFixed(0)),
                _buildPdfRow("14", "Health & Education Cess @ 4%", cess.toStringAsFixed(0)),
                _buildPdfRow("15", "Tax payable (Rounded off)", totalTax.toStringAsFixed(0)),
                _buildPdfRow("16", "Capital Gain Tax (Short/Long term)", capitalGainTax.toStringAsFixed(0)),
                _buildPdfRow("17", "Total Tax payable (incl. Capital Gain)", finalTax.toStringAsFixed(0), isBold: true),
                
                _buildPdfRow("18", "Tax paid upto January", i71.toStringAsFixed(0)),
                _buildPdfRow("19", "Tax to be paid in February", i72.toStringAsFixed(0)),
                _buildPdfRow("20", "Balance Tax Payable/Refundable", status, isBold: true),
              ],
            ),
            
            // --- Signature Section Updated ---
            pw.SizedBox(height: 50), 
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center, // অ্যালাইনমেন্ট Center করা হলো
                  children: [
                    pw.Text("Signature of the Head of the Institution", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("With Date & Seal.", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), // টেক্সট আপডেট করা হলো
                  ]
                ),
                pw.Text("Signature of the Employee", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ]
            ),
          ]
        );
      }
    );
  }

  pw.Widget _pdfHeaderBox(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 4),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
        child: pw.RichText(text: pw.TextSpan(children: [
          pw.TextSpan(text: "$title: "),
          pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 8)),
        ]))
      )
    );
  }

  pw.TableRow _buildPdfRow(String sl, String desc, String amt, {bool isHeader = false, bool isBold = false}) {
    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey300) : null,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4.5, horizontal: 4), child: pw.Text(sl, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: isHeader||isBold ? pw.FontWeight.bold : null, fontSize: 8.5))),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4.5, horizontal: 4), child: pw.Text(desc, style: pw.TextStyle(fontWeight: isHeader||isBold ? pw.FontWeight.bold : null, fontSize: 8.5))),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4.5, horizontal: 4), child: pw.Text(amt, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: isHeader||isBold ? pw.FontWeight.bold : null, fontSize: 8.5))),
      ]
    );
  }

  Widget _buildExcelRow(String slNo, String title, TextEditingController controller, {bool isReadOnly = false}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400), left: BorderSide(color: Colors.grey.shade400), right: BorderSide(color: Colors.grey.shade400))),
      child: Row(
        children: [
          Container(width: 35, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade400))), child: Text(slNo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(title, style: TextStyle(fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal, fontSize: 12)))),
          Container(
            width: 100,
            decoration: BoxDecoration(color: isReadOnly ? Colors.grey.shade200 : Colors.amber.shade100, border: Border(left: BorderSide(color: Colors.grey.shade400))),
            child: TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal, fontSize: 13),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10), isDense: true),
              onChanged: (val) => calculateTax(), 
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOld = _tabController.index == 0; 
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amin Tax Calculator"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amberAccent, 
          unselectedLabelColor: Colors.white, 
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          onTap: (index) {
            FocusScope.of(context).unfocus(); 
          },
          tabs: const [Tab(text: 'OLD REGIME'), Tab(text: 'NEW REGIME')],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.white), onPressed: _generatePdf, tooltip: "Download PDF")
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade600, width: 1.5)),
              child: Column(
                children: [
                  Row(children: [Expanded(flex: 2, child: _headerTextField('EMPLOYEE NAME:', nameCtrl)), Expanded(flex: 1, child: _headerTextField('DESIGNATION:', designationCtrl))]),
                  _headerTextField('INSTITUTION NAME:', institutionCtrl),
                  Row(children: [Expanded(child: _headerTextField('EMPLOYEE CODE:', empCodeCtrl)), Expanded(child: _headerTextField('PAN:', panCtrl))]),
                  Row(children: [Expanded(child: _headerTextField('FINANCIAL YEAR:', finYearCtrl)), Expanded(child: _headerTextField('ASSESSMENT YEAR:', assessYearCtrl))]), 
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.grey.shade600, width: 1.5)),
              child: Row(
                children: [
                  Container(width: 35, padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade600))), child: const Text("Sl", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  const Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                  Container(width: 100, padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade600))), child: const Text("Amount", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),

            _buildExcelRow("1", "Gross Salary (a)", i7GrossSalary),
            _buildExcelRow("", "Arrear (b)", i8Arrear),
            _buildExcelRow("", "Total (a+b)", totalSalCtrl, isReadOnly: true),
            _buildExcelRow("2", "Less: Standard Deduction", stdDedCtrl, isReadOnly: true),
            _buildExcelRow("", "Less: Professional Tax", pTaxCtrl, isReadOnly: true), 
            _buildExcelRow("3", "Income chargeable under 'Salary'", netSalCtrl, isReadOnly: true),
            
            _buildExcelRow("4", "Gross Rent Received (a)", i18GrossRent),
            _buildExcelRow("", "Tax paid to local authorities (b)", i19TaxLocalAuth),
            _buildExcelRow("", "Interest Payable on Borrowed Cap (c)", i22HomeLoanInt),
            _buildExcelRow("5", "Income Chargeable Under House Property", totalHousePropCtrl, isReadOnly: true), 
            
            _buildExcelRow("6", "Interest on Saving Bank (a)", i25BankInt),
            _buildExcelRow("", "Interest on Fixed Deposit (b)", i26FDInt),
            _buildExcelRow("", "Others (c)", i27OtherSource),
            _buildExcelRow("7", "Income Chargeable Under Head Other Sources", totalOtherSrcCtrl, isReadOnly: true), 
            
            _buildExcelRow("8", "Gross total income (3+5+7)", grossTotalCtrl, isReadOnly: true),
            
            _buildExcelRow("9", "Total Deduction u/s 80C", i32_43Total80C, isReadOnly: !isOld),
            _buildExcelRow("", "Add: 80D/80G etc. (Manual Input)", i45_56TotalOtherDed, isReadOnly: !isOld), 
            
            _buildExcelRow("10", "Total Other Deductions (80D/80G/80TTA Etc.)", serial10Ctrl, isReadOnly: true), 
            _buildExcelRow("11", "Total deduction", totalDedCtrl, isReadOnly: true),
            
            _buildExcelRow("12", "Total taxable income (Rounded off)", taxableIncomeCtrl, isReadOnly: true),
            _buildExcelRow("13", "Tax on Taxable Income", taxOnIncomeCtrl, isReadOnly: true),
            _buildExcelRow("14", "Tax Rebate u/s 87A", rebateCtrl, isReadOnly: true),
            _buildExcelRow("15", "Health & Education Cess @ 4%", cessCtrl, isReadOnly: true),
            _buildExcelRow("16", "Tax payable (Rounded off)", totalTaxCessCtrl, isReadOnly: true),
            
            _buildExcelRow("17", "Short Term Capital Gain", i68STCG),
            _buildExcelRow("18", "Long Term Capital Gain", i69LTCG),
            _buildExcelRow("19", "Total Tax payable (incl. Capital Gain)", finalTaxPayableCtrl, isReadOnly: true),
            
            _buildExcelRow("20", "Tax paid upto January", i71TaxPaidJan),
            _buildExcelRow("21", "Tax to be paid in February", i72TaxPaidFeb),
            _buildExcelRow("22", "Balance Tax Payable/Refundable", statusCtrl, isReadOnly: true),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _headerTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: TextField(controller: controller, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero))),
        ],
      ),
    );
  }
}
