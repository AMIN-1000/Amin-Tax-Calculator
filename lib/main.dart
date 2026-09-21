import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EighteenYearsBenefitApp());
}

class EighteenYearsBenefitApp extends StatelessWidget {
  const EighteenYearsBenefitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '18 Years Benefit Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const EighteenYearsHomePage(),
    );
  }
}

// ---------------- ROPA-19 PAY MATRIX DATABASE ----------------
class Ropa19Data {
  static final List<int> gradePays = [
    1700, 1800, 1900, 2100, 2300, 2600, 2900, 3200, 3600, 3900, 4100, 4400, 4600, 4700, 4800, 5400
  ];

  static final List<List<int>> matrix = [
    // L-1 (GP 1700)
    [17000, 17500, 18000, 18500, 19100, 19700, 20300, 20900, 21500, 22100, 22800, 23500, 24200, 24900, 25600, 26400, 27200, 28000, 28800, 29700, 30600, 31500, 32400, 33400, 34400, 35400, 36500, 37600, 38700, 39900, 41100, 42300, 43600],
    // L-2 (GP 1800)
    [17600, 18100, 18600, 19200, 19800, 20400, 21000, 21600, 22200, 22900, 23600, 24300, 25000, 25800, 26600, 27400, 28200, 29000, 29900, 30800, 31700, 32700, 33700, 34700, 35700, 36800, 37900, 39000, 40200, 41400, 42600, 43900, 45200],
    // L-3 (GP 1900)
    [18800, 19400, 20000, 20600, 21200, 21800, 22500, 23200, 23900, 24600, 25300, 26100, 26900, 27700, 28500, 29400, 30300, 31200, 32100, 33100, 34100, 35100, 36200, 37300, 38400, 39600, 40800, 42000, 43300, 44600, 45900, 47300, 48700],
    // L-4 (GP 2100)
    [19700, 20300, 20900, 21500, 22100, 22800, 23500, 24200, 24900, 25600, 26400, 27200, 28000, 28800, 29700, 30600, 31500, 32400, 33400, 34400, 35400, 36500, 37600, 38700, 39900, 41100, 42300, 43600, 44900, 46200, 47600, 49000, 50500],
    // L-5 (GP 2300)
    [21000, 21600, 22200, 22900, 23600, 24300, 25000, 25800, 26600, 27400, 28200, 29000, 29900, 30800, 31700, 32700, 33700, 34700, 35700, 36800, 37900, 39000, 40200, 41400, 42600, 43900, 45200, 46600, 48000, 49400, 50900, 52400, 54000],
    // L-6 (GP 2600)
    [22700, 23400, 24100, 24800, 25500, 26300, 27100, 27900, 28700, 29600, 30500, 31400, 32300, 33300, 34300, 35300, 36400, 37500, 38600, 39800, 41000, 42200, 43500, 44800, 46100, 47500, 48900, 50400, 51900, 53500, 55100, 56800, 58500],
    // L-7 (GP 2900)
    [24700, 25400, 26200, 27000, 27800, 28600, 29500, 30400, 31300, 32200, 33200, 34200, 35200, 36300, 37400, 38500, 39700, 40900, 42100, 43400, 44700, 46000, 47400, 48800, 50300, 51800, 53400, 55000, 56700, 58400, 60200, 62000, 63900],
    // L-8 (GP 3200)
    [27000, 27800, 28600, 29500, 30400, 31300, 32200, 33200, 34200, 35200, 36300, 37400, 38500, 39700, 40900, 42100, 43400, 44700, 46000, 47400, 48800, 50300, 51800, 53400, 55000, 56700, 58400, 60200, 62000, 63900, 65800, 67800, 69800],
    // L-9 (GP 3600)
    [28900, 29800, 30700, 31600, 32500, 33500, 34500, 35500, 36600, 37700, 38800, 40000, 41200, 42400, 43700, 45000, 46400, 47800, 49200, 50700, 52200, 53800, 55400, 57100, 58800, 60600, 62400, 64300, 66200, 68200, 70200, 72300, 74500],
    // L-10 (GP 3900)
    [32100, 33100, 34100, 35100, 36200, 37300, 38400, 39600, 40800, 42000, 43300, 44600, 45900, 47300, 48700, 50200, 51700, 53300, 54900, 56500, 58200, 59900, 61700, 63600, 65500, 67500, 69500, 71600, 73700, 75900, 78200, 80500, 82900],
    // L-11 (GP 4100)
    [33400, 34400, 35400, 36500, 37600, 38700, 39900, 41100, 42300, 43600, 44900, 46200, 47600, 49000, 50500, 52000, 53600, 55200, 56900, 58600, 60400, 62200, 64100, 66000, 68000, 70000, 72100, 74300, 76500, 78800, 81200, 83600, 86100],
    // L-12 (GP 4400)
    [35800, 36900, 38000, 39100, 40300, 41500, 42700, 44000, 45300, 46700, 48100, 49500, 51000, 52500, 54100, 55700, 57400, 59100, 60900, 62700, 64600, 66500, 68500, 70600, 72700, 74900, 77100, 79400, 81800, 84300, 86800, 89400, 92100],
    // L-13 (GP 4600)
    [37100, 38200, 39300, 40500, 41700, 43000, 44300, 45600, 47000, 48400, 49900, 51400, 52900, 54500, 56100, 57800, 59500, 61300, 63100, 65000, 67000, 69000, 71100, 73200, 75400, 77700, 80000, 82400, 84900, 87400, 90000, 92700, 95500],
    // L-14 (GP 4700)
    [39900, 41100, 42300, 43600, 44900, 46200, 47600, 49000, 50500, 52000, 53600, 55200, 56900, 58600, 60400, 62200, 64100, 66000, 68000, 70000, 72100, 74300, 76500, 78800, 81200, 83600, 86100, 88700, 91400, 94100, 96900, 99800, 102800],
    // L-15 (GP 4800)
    [42600, 43900, 45200, 46600, 48000, 49400, 50900, 52400, 54000, 55600, 57300, 59000, 60800, 62600, 64500, 66400, 68400, 70500, 72600, 74800, 77000, 79300, 81700, 84200, 86700, 89300, 92000, 94800, 97600, 100500, 103500, 106600, 109800],
    // L-16 (GP 5400)
    [56100, 57800, 59500, 61300, 63100, 65000, 67000, 69000, 71100, 73200, 75400, 77700, 80000, 82400, 84900, 87400, 90000, 92700, 95500, 98400, 101400, 104400, 107500, 110700, 114000, 117400, 120900, 124500, 128200, 132000, 136000, 140100, 144300],
  ];

  static Map<String, dynamic>? calculate18YearsFixation(int currentBasic) {
    int curLevel = -1;
    int curCell = -1;

    for (int l = 0; l < matrix.length; l++) {
      for (int c = 0; c < matrix[l].length; c++) {
        if (matrix[l][c] == currentBasic) {
          curLevel = l + 1;
          curCell = c + 1;
          break;
        }
      }
      if (curLevel != -1) break;
    }

    if (curLevel == -1) return null;

    int nextCellInLevel = curCell + 1;
    int afterIncrBasic = (nextCellInLevel <= matrix[curLevel - 1].length)
        ? matrix[curLevel - 1][nextCellInLevel - 1]
        : currentBasic;

    int nextLevel = curLevel + 1;
    int revisedBasic = afterIncrBasic;
    int nextLvlCell = 1;

    if (nextLevel <= matrix.length) {
      for (int c = 0; c < matrix[nextLevel - 1].length; c++) {
        if (matrix[nextLevel - 1][c] >= afterIncrBasic) {
          revisedBasic = matrix[nextLevel - 1][c];
          nextLvlCell = c + 1;
          break;
        }
      }
    }

    return {
      'curLevel': curLevel,
      'curCell': curCell,
      'afterIncrBasic': afterIncrBasic,
      'afterIncrCell': nextCellInLevel,
      'nextLevel': nextLevel,
      'nextLvlCell': nextLvlCell,
      'revisedBasic': revisedBasic,
    };
  }
}

// ---------------- MAIN HOME PAGE ----------------
class EighteenYearsHomePage extends StatefulWidget {
  const EighteenYearsHomePage({super.key});

  @override
  State<EighteenYearsHomePage> createState() => _EighteenYearsHomePageState();
}

class _EighteenYearsHomePageState extends State<EighteenYearsHomePage> {
  // প্রতিষ্ঠানের তথ্য
  final instNameCtrl = TextEditingController(text: "KUMARPUKUR HIGH SCHOOL (H.S.)");
  final instAddressCtrl = TextEditingController(text: "P.O.: MAKHALGACHHA, P.S.: HASNABAD,\nDIST. NORTH 24 PARGANAS, PIN.743422");

  // কর্মচারীর তথ্য
  final empNameCtrl = TextEditingController(text: "MD RUHUL AMIN MONDAL");

  String selectedDesignation = "A.T";
  final List<String> designationList = [
    "H.M",
    "T.I.C",
    "A.H.M",
    "A.T",
    "CLERK",
    "Gr-D (Peon)",
    "Gr-D (Matron)",
    "Gr-D"
  ];

  // WBBSE ও WBCHSE-এর বিশেষ বিষয়গুলোর তালিকা
  String selectedSubject = "Arabic";
  final List<String> subjectList = [
    "Bengali",
    "English",
    "Mathematics",
    "Physical Science",
    "Life Science",
    "History",
    "Geography",
    "Sanskrit",
    "Arabic",
    "Urdu",
    "Hindi",
    "Physics",
    "Chemistry",
    "Biology",
    "Economics",
    "Political Science",
    "Philosophy",
    "Education",
    "Sociology",
    "Accountancy",
    "Business Studies",
    "Commercial Law",
    "Computer Science",
    "Computer Application",
    "Nutrition",
    "Work Education",
    "Physical Education",
    "Music",
    "Visual Arts"
  ];

  String selectedCategory = "Pass";
  final List<String> categoryList = [
    "P.G",
    "Hons.",
    "Pass",
    "H.S",
    "M.P",
    "S.F"
  ];

  String selectedJoiningType = "1st Joining Date";
  final List<String> joiningTypeList = ["1st Joining Date", "Current Joining Date"];

  final joinDateCtrl = TextEditingController(text: "19.05.2005");
  final firstJoiningApprovalCtrl = TextEditingController(text: "Vide D.I. of Nadia's Approval\nMemo No. 608/Gen/SE, Date: 22.07.2005");
  final currentApprovalCtrl = TextEditingController(text: "Memo No. 120/SE, Date: 10.08.2015");

  final completionDateCtrl = TextEditingController(text: "18.05.2023");
  final optionDateCtrl = TextEditingController(text: "01.07.2023");
  final effectDateCtrl = TextEditingController(text: "01.07.2023");
  final nextIncrDateCtrl = TextEditingController(text: "01.07.2024");

  final diOfficeNameCtrl = TextEditingController(text: "North 24 Parganas");
  final toOfficerCtrl = TextEditingController(text: "The A.D.I of Schools (S.E.), Basirhat Sub-division,\nBasirhat, North 24 Parganas.");

  final basicPayCtrl = TextEditingController(text: "58600");

  int curLevel = 11;
  int curCell = 20;
  int afterIncrBasic = 60400;
  int afterIncrCell = 21;
  int nextLevel = 12;
  int nextLvlCell = 19;
  int revisedBasic = 60900;

  @override
  void initState() {
    super.initState();
    _performCalculation(basicPayCtrl.text);
    _calculateAllDates(joinDateCtrl.text);
  }

  void _calculateAllDates(String joinDateStr) {
    try {
      final parts = joinDateStr.trim().split('.');
      if (parts.length == 3) {
        int d = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        int y = int.parse(parts[2]);

        DateTime completionDate = DateTime(y + 18, m, d).subtract(const Duration(days: 1));

        String compStr = "${completionDate.day.toString().padLeft(2, '0')}.${completionDate.month.toString().padLeft(2, '0')}.${completionDate.year}";
        completionDateCtrl.text = compStr;

        String optEffectStr = "";
        DateTime nextIncrDate;

        bool isBetweenJulyAndJan = (m >= 7 && m <= 12) || (m == 1 && d == 1);

        if (isBetweenJulyAndJan) {
          int optYear = y + 18;
          optEffectStr = "${d.toString().padLeft(2, '0')}.${m.toString().padLeft(2, '0')}.$optYear";
          nextIncrDate = DateTime(optYear + 1, 7, 1);
        } else {
          int optYear = (m < 7) ? (y + 18) : (y + 19);
          optEffectStr = "01.07.$optYear";
          nextIncrDate = DateTime(optYear + 1, 7, 1);
        }

        optionDateCtrl.text = optEffectStr;
        effectDateCtrl.text = optEffectStr;
        nextIncrDateCtrl.text = "01.07.${nextIncrDate.year}";
        setState(() {});
      }
    } catch (_) {}
  }

  void _performCalculation(String val) {
    int? basic = int.tryParse(val.trim());
    if (basic != null) {
      final res = Ropa19Data.calculate18YearsFixation(basic);
      if (res != null) {
        setState(() {
          curLevel = res['curLevel'];
          curCell = res['curCell'];
          afterIncrBasic = res['afterIncrBasic'];
          afterIncrCell = res['afterIncrCell'];
          nextLevel = res['nextLevel'];
          nextLvlCell = res['nextLvlCell'];
          revisedBasic = res['revisedBasic'];
        });
      }
    }
  }

  Future<void> _selectDateDialog(TextEditingController ctrl, {bool isJoining = false}) async {
    DateTime initial = DateTime.now();
    try {
      final parts = ctrl.text.trim().split('.');
      if (parts.length == 3) {
        initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1980),
      lastDate: DateTime(2045),
    );
    if (picked != null) {
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');
      String formatted = "$day.$month.${picked.year}";
      setState(() {
        ctrl.text = formatted;
        if (isJoining) {
          _calculateAllDates(formatted);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMultipleSchools = (selectedJoiningType == "1st Joining Date");

    return Scaffold(
      appBar: AppBar(
        title: const Text('18 Years Benefit Fixation & Forwarding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download Fixation Statement PDF',
            onPressed: () => _printFixationPdf(),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Download Forwarding Letter PDF',
            onPressed: () => _printForwardingPdf(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard("School Information", [
              _buildInput("Name of Institution", instNameCtrl),
              _buildInput("Institution Address", instAddressCtrl, maxLines: 2),
            ]),
            const SizedBox(height: 10),
            _buildCard("Employee & Designation Details", [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildInput("Employee Name", empNameCtrl),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedDesignation,
                      decoration: const InputDecoration(
                        labelText: "Designation",
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: designationList.map((String d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedDesignation = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Subject Dropdown
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Subject",
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: subjectList.map((String s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedSubject = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Category/Scale",
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: categoryList.map((String c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedCategory = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: selectedJoiningType,
                decoration: const InputDecoration(
                  labelText: "Joining Service Type",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                items: joiningTypeList.map((String t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedJoiningType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: () => _selectDateDialog(joinDateCtrl, isJoining: true),
                child: IgnorePointer(
                  child: _buildInput(
                    isMultipleSchools ? "1st Joining Date (Auto-calculates 18 Yrs & Option)" : "Current Joining Date (Auto-calculates 18 Yrs & Option)",
                    joinDateCtrl,
                  ),
                ),
              ),

              if (isMultipleSchools) ...[
                _buildInput("1st Joining Approval Memo No. & Date", firstJoiningApprovalCtrl, maxLines: 2),
                _buildInput("Current Approval Memo No. & Date", currentApprovalCtrl, maxLines: 2),
              ] else ...[
                _buildInput("Current Approval Memo No. & Date", currentApprovalCtrl, maxLines: 2),
              ],
            ]),
            const SizedBox(height: 10),
            _buildCard("18 Years Benefit Dates (Automatically Populated)", [
              _buildInput("Date of Completion of 18 Yrs", completionDateCtrl),
              _buildInput("Date of Option for 18 Yrs Benefit", optionDateCtrl),
              _buildInput("Date of Effect", effectDateCtrl),
              _buildInput("Date of Next Increment", nextIncrDateCtrl),
              _buildInput("Submission to District (Name of District)", diOfficeNameCtrl),
              _buildInput("Forwarding To Address", toOfficerCtrl, maxLines: 2),
            ]),
            const SizedBox(height: 10),
            _buildCard("Fixation Calculator (ROPA-19)", [
              Row(
                children: [
                  const Text("Existing Basic Pay: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: basicPayCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                        hintText: "Enter Basic",
                      ),
                      onChanged: _performCalculation,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildSummaryRow("1. Existing Pay Band / Level & Cell:", "Level-$curLevel, Cell-$curCell"),
              _buildSummaryRow("2. Adding One Increment in Same Level:", "Rs. $afterIncrBasic/- (Level-$curLevel, Cell-$afterIncrCell)"),
              _buildSummaryRow("3. Fixed at Next Higher Level:", "Rs. $revisedBasic/- (Level-$nextLevel, Cell-$nextLvlCell)"),
              _buildSummaryRow("4. Revised Basic Pay:", "Rs. $revisedBasic/-"),
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("1. Fixation PDF"),
                    onPressed: _printFixationPdf,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.print),
                    label: const Text("2. Forwarding PDF"),
                    onPressed: _printForwardingPdf,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // =========================================================================
  // ১. FIXATION STATEMENT PDF
  // =========================================================================
  Future<void> _printFixationPdf() async {
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    final bool isMultiple = (selectedJoiningType == "1st Joining Date");
    final fullEmpNameDesig = "${empNameCtrl.text}, ($selectedDesignation.)";

    final String sl3Label = isMultiple
        ? "3. Date of First Joining with Approval No. & Date"
        : "3. Date of Joining with Approval No. & Date";

    final String sl3Value = isMultiple
        ? "${joinDateCtrl.text}, ${firstJoiningApprovalCtrl.text}"
        : "${joinDateCtrl.text}, ${currentApprovalCtrl.text}";

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.only(
          top: 245.0, // ২ লাইন কমানো হয়েছে (275 -> 245 pt)
          left: 40.0,
          right: 40.0,
          bottom: 25.0,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Statement Showing Fixation of Pay due to completion of 18 years continuous and satisfactory service in terms of G.O. No 437-SE (P&B)/SL/5S-408/19 dated 13.12.2019",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 14),

              _pdfStatementRow("1. Name of the Institution with Address", "${instNameCtrl.text}\n${instAddressCtrl.text}"),
              _pdfStatementRow("2. Name & Designation of the Employee", fullEmpNameDesig),
              _pdfStatementRow(sl3Label, sl3Value),
              _pdfStatementRow("4. Date of Completion of 18 years continuous and satisfactory service", completionDateCtrl.text),
              _pdfStatementRow("5. Date of Option for coming under 18 years benefit", optionDateCtrl.text),
              _pdfStatementRow("6. Existing Basic Pay as on (Date of option for 18 yrs. Benefit)", "Rs. ${basicPayCtrl.text}/- Level-$curLevel, Cell-$curCell"),
              _pdfStatementRow("7. Basic Pay after adding one increment in the same level", "Rs. $afterIncrBasic/- Level-$curLevel, Cell-$afterIncrCell"),
              _pdfStatementRow("8. Pay to be fixed at next level due to completion of 18 yrs. Service", "Rs. $revisedBasic/- Level-$nextLevel, Cell-$nextLvlCell"),
              _pdfStatementRow("9. Revised Basic Pay (Level: .....$nextLevel...... Cell: ...$nextLvlCell..........)", "Rs. $revisedBasic/-"),
              _pdfStatementRow("10. Date of Effect", effectDateCtrl.text),
              _pdfStatementRow("11. Date of Next Increment", nextIncrDateCtrl.text),

              pw.SizedBox(height: 14),
              pw.Text(
                "Submitted to the District Inspector of Schools (S.E.), ${diOfficeNameCtrl.text} (Name of District)",
                style: const pw.TextStyle(fontSize: 9.8),
                textAlign: pw.TextAlign.justify,
              ),

              pw.Spacer(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Signature of the President of", style: const pw.TextStyle(fontSize: 9.2)),
                      pw.Text("the Institution with seal", style: const pw.TextStyle(fontSize: 9.2)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Signature of the Secretary of", style: const pw.TextStyle(fontSize: 9.2)),
                      pw.Text("the Institution with date & seal", style: const pw.TextStyle(fontSize: 9.2)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '18_Years_Fixation_Statement.pdf',
    );
  }

  // ৪ নং ও ৮ নং সহ সব লাইনের সমান্তরাল ইন্ডেন্টেশন ও কোলন (:) এর পর ৪ স্পেস ডানে সরানো
  pw.Widget _pdfStatementRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.8), // লাইন স্পেস বৃদ্ধি
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 250,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.2),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.Text(" : ", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 14), // কোলন চিহ্ন থেকে ৪ স্পেস ডানপাশে সরানো
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, lineSpacing: 1.3),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ২. FORWARDING LETTER PDF
  // =========================================================================
  Future<void> _printForwardingPdf() async {
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    final bool isMultiple = (selectedJoiningType == "1st Joining Date");
    final fullEmpName = empNameCtrl.text;

    String desigSubjectText = "$selectedDesignation. of the school in $selectedSubject ($selectedCategory)";
    if (isMultiple && currentApprovalCtrl.text.trim().isNotEmpty) {
      desigSubjectText += ", vide ${currentApprovalCtrl.text.trim().replaceAll('\n', ', ')}";
    }

    final String joiningPhrase = isMultiple
        ? "since his date of first joining ${joinDateCtrl.text}"
        : "since his date of joining ${joinDateCtrl.text}";

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.only(
          top: 245.0, // ২ লাইন কমানো হয়েছে (275 -> 245 pt)
          left: 45.0,
          right: 45.0,
          bottom: 20.0,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("To,", style: const pw.TextStyle(fontSize: 9.8)),
              pw.Text(toOfficerCtrl.text, style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.2)),
              pw.SizedBox(height: 12),

              // Subject Center Aligned
              pw.Center(
                child: pw.Text(
                  "Sub: Submission of papers regarding 18 years benefit asper G.O.No.437-SE(P&B)/SL/5S-408/1, Dated- 13/12/2019.",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Text("Respected Sir,", style: const pw.TextStyle(fontSize: 9.8)),
              pw.SizedBox(height: 6),

              // Body Paragraph 1 (Justified + ফন্ট ও লাইন স্পেস বৃদ্ধি)
              pw.Text(
                "        I, the Teacher in Charge of the school hereby submit the relevant papers regarding 18 years benefit of $fullEmpName, $desigSubjectText who has already completed 18 years continuous satisfactory service on ${completionDateCtrl.text} $joiningPhrase without any break.",
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2.2),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 8),

              // Body Paragraph 2 (Justified)
              pw.Text(
                "        So, please be kind and take necessary action so that he may get the said benefit at an earliest. His all relevant papers are enclosed herewith.",
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2.2),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),

              // Thanking you - herewith এর ঠিক সোজা সমান্তরাল করে বসানো
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 100),
                  child: pw.Text("Thanking you,", style: const pw.TextStyle(fontSize: 9.8)),
                ),
              ),
              pw.SizedBox(height: 12),

              // Dated এবং Yours faithfully সমান্তরালভাবে এক লাইনে
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Dated: ....................", style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 25),
                    child: pw.Text("Yours faithfully,", style: const pw.TextStyle(fontSize: 9.8)),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // ১৩টি এনক্লোজার তালিকা
              pw.Text("Enclosures:", style: pw.TextStyle(fontSize: 9.2, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _pdfEnclosureItem("01. Forwarding Letter"),
              _pdfEnclosureItem("02. Application of Incumbent"),
              _pdfEnclosureItem("03. M.C/D.D.O Resolution"),
              _pdfEnclosureItem("04. Fixation Formula"),
              _pdfEnclosureItem("05. Option Form"),
              _pdfEnclosureItem("06. Validity of M.C/D.D.O"),
              _pdfEnclosureItem("07. Non Litigation Certificate"),
              _pdfEnclosureItem("08. Copy of Approvals"),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 22, bottom: 2.0),
                child: pw.Text("(For Multiple Schools if any)", style: const pw.TextStyle(fontSize: 7.8)),
              ),
              _pdfEnclosureItem("09. Copy of SSC Recommendation"),
              _pdfEnclosureItem("10. Copy of Service Book"),
              _pdfEnclosureItem("11. Copy of Aquitance Roll"),
              _pdfEnclosureItem("12. Copy of ROPA-09 & 19"),
              _pdfEnclosureItem("13. EOL/Non EOL Certificate"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '18_Years_Forwarding_Letter.pdf',
    );
  }

  pw.Widget _pdfEnclosureItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 4, bottom: 2.0),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8.5)),
    );
  }
}
