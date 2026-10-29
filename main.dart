import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

String currentAppLanguage = 'ar';
final ValueNotifier<bool> azDarkMode = ValueNotifier<bool>(false);

const Map<String, Map<String, String>> _translations = {
  'الرئيسية': {'fr': 'Accueil', 'en': 'Home'},
  'الكراتين': {'fr': 'Cartons', 'en': 'Cartons'},
  'المخزون والكراتين': {'fr': 'Stock et cartons', 'en': 'Stock & cartons'},
  'الكريدي': {'fr': 'Crédit', 'en': 'Credit'},
  'المصاريف': {'fr': 'Dépenses', 'en': 'Expenses'},
  'المزيد': {'fr': 'Plus', 'en': 'More'},
  'مرحباً بك': {'fr': 'Bienvenue', 'en': 'Welcome'},
  'إدارة بيانات AZ Store محليًا وبأمان': {'fr': 'Gérez vos données AZ Store localement et en sécurité', 'en': 'Manage AZ Store data locally and securely'},
  'بحث سريع...': {'fr': 'Recherche rapide...', 'en': 'Quick search...'},
  'آخر العمليات': {'fr': 'Dernières opérations', 'en': 'Recent activity'},
  'إجمالي الحبات في السجل: ': {'fr': 'Total des pièces enregistrées : ', 'en': 'Total pieces recorded: '},
  'المخزون حسب السلعة': {'fr': 'Stock par produit', 'en': 'Stock by product'},
  'آخر عمليات الشراء': {'fr': 'Derniers achats', 'en': 'Recent purchases'},
  'إضافة إلى المخزون': {'fr': 'Ajouter au stock', 'en': 'Add to stock'},
  'اسم السلعة *': {'fr': 'Nom du produit *', 'en': 'Product name *'},
  'كراتين': {'fr': 'Cartons', 'en': 'Cartons'},
  'حبات مفردة': {'fr': 'Pièces seules', 'en': 'Loose pieces'},
  'عدد الكراتين': {'fr': 'Nombre de cartons', 'en': 'Number of cartons'},
  'عدد الحبات في الكرتونة الواحدة': {'fr': 'Pièces par carton', 'en': 'Pieces per carton'},
  'سعر شراء الكرتونة (DA)': {'fr': 'Prix d’achat du carton (DA)', 'en': 'Carton purchase price (DA)'},
  'سعر شراء الحبة الواحدة (اختياري)': {'fr': 'Prix d’achat par pièce (facultatif)', 'en': 'Purchase price per piece (optional)'},
  'عدد الحبات المشتراة': {'fr': 'Nombre de pièces achetées', 'en': 'Number of pieces purchased'},
  'سعر شراء الحبة الواحدة (DA)': {'fr': 'Prix d’achat par pièce (DA)', 'en': 'Purchase price per piece (DA)'},
  'حفظ': {'fr': 'Enregistrer', 'en': 'Save'},
  'إلغاء': {'fr': 'Annuler', 'en': 'Cancel'},
  'موافق': {'fr': 'Confirmer', 'en': 'Confirm'},
  'اختيار اللغة / Choose language / Choisir la langue': {'fr': 'Choisir la langue', 'en': 'Choose language'},
  'الإحصائيات والملخص': {'fr': 'Statistiques et résumé', 'en': 'Statistics & summary'},
  'سجل العمليات': {'fr': 'Historique des opérations', 'en': 'Activity log'},
  'سلة المحذوفات': {'fr': 'Corbeille', 'en': 'Trash'},
  'النسخ المحلية': {'fr': 'Sauvegardes locales', 'en': 'Local backups'},
  'حالة البيانات': {'fr': 'État des données', 'en': 'Data status'},
  'تصدير ومشاركة ملف AZ Store': {'fr': 'Exporter et partager AZ Store', 'en': 'Export and share AZ Store'},
  'استيراد ملف AZ Store': {'fr': 'Importer un fichier AZ Store', 'en': 'Import AZ Store file'},
  'PIN / بصمة': {'fr': 'PIN / Empreinte', 'en': 'PIN / Fingerprint'},
  'اللغة / Language / Langue': {'fr': 'Langue', 'en': 'Language'},
  'أوفلاين': {'fr': 'Hors ligne', 'en': 'Offline'},
  'المتبقي': {'fr': 'Restant', 'en': 'Outstanding'},
  'تم التسديد': {'fr': 'Payé', 'en': 'Paid'},
  'غير مسدد': {'fr': 'Non payé', 'en': 'Unpaid'},
};

String _translate(String value) {
  if (currentAppLanguage == 'ar') return value;
  final exact = _translations[value];
  if (exact != null) return exact[currentAppLanguage] ?? value;
  var result = value;
  final entries = _translations.entries.toList()..sort((a, b) => b.key.length.compareTo(a.key.length));
  for (final entry in entries) {
    final replacement = entry.value[currentAppLanguage];
    if (replacement != null && entry.key.isNotEmpty) result = result.replaceAll(entry.key, replacement);
  }
  return result;
}

class Text extends StatelessWidget {
  const Text(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap});
  final String? data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final m.TextOverflow? overflow;
  final bool? softWrap;
  @override
  Widget build(BuildContext context) => m.Text(
    data == null ? '' : _translate(data!), style: style, textAlign: textAlign,
    maxLines: maxLines, overflow: overflow, softWrap: softWrap,
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LHApp());
}

class LHApp extends StatelessWidget {
  const LHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: azDarkMode,
      builder: (context, isDark, child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AZ Store',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0877E8), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0877E8), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF10141C),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  Map<String, dynamic>? data;
  bool busy = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    try {
      final loaded = await LocalStore.load();
      final settings = Map<String, dynamic>.from(
        loaded['settings'] as Map? ?? <String, dynamic>{},
      );
      final pinHash = settings['pinHash']?.toString() ?? '';
      final biometric = settings['biometric'] == true;

      if (pinHash.isNotEmpty || biometric) {
        final ok = await showLock(
          context,
          allowBiometric: biometric,
          hasPin: pinHash.isNotEmpty,
          expectedPinHash: pinHash,
        );
        if (!ok) {
          if (!mounted) return;
          setState(() {
            busy = false;
            error = 'التطبيق مقفل';
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        data = loaded;
        busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        busy = false;
        error = 'تعذر فتح البيانات المحلية';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (data == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => setState(() => busy = true),
            child: Text(error.isEmpty ? 'فتح التطبيق' : error),
          ),
        ),
      );
    }
    return LHHome(initialData: data!);
  }
}

Future<bool> showLock(
  BuildContext context, {
  required bool allowBiometric,
  required bool hasPin,
  required String expectedPinHash,
}) async {
  final auth = LocalAuthentication();

  if (allowBiometric) {
    try {
      final supported = await auth.isDeviceSupported();
      if (supported) {
        final ok = await auth.authenticate(
          localizedReason: 'افتح تطبيق AZ Store',
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        );
        if (ok) return true;
      }
    } catch (_) {}
  }

  if (!hasPin || !context.mounted) return false;

  final controller = TextEditingController();
  bool failed = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('🔐 رمز PIN'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: 'أدخل PIN',
                errorText: failed ? 'PIN غير صحيح' : null,
              ),
              onSubmitted: (_) {
                if (sha256Text(controller.text) == expectedPinHash) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setDialogState(() => failed = true);
                }
              },
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  if (sha256Text(controller.text) == expectedPinHash) {
                    Navigator.pop(dialogContext, true);
                  } else {
                    setDialogState(() => failed = true);
                  }
                },
                child: const Text('فتح'),
              ),
            ],
          );
        },
      );
    },
  );
  controller.dispose();
  return result == true;
}

class LocalStore {
  static Future<File> file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/lh_data.json');
  }

  static Future<Map<String, dynamic>> load() async {
    final f = await file();
    if (!await f.exists()) {
      final fresh = _newData();
      await save(fresh);
      return fresh;
    }
    try {
      final decoded = jsonDecode(await f.readAsString());
      if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);
        _ensureShape(data);
        return data;
      }
    } catch (_) {}
    final fresh = _newData();
    await save(fresh);
    return fresh;
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final f = await file();
    const encoder = JsonEncoder.withIndent('  ');
    await f.writeAsString(encoder.convert(data), flush: true);
  }

  static Map<String, dynamic> _newData() {
    return {
      'format': 1,
      'revision': 0,
      'updatedAt': DateTime.now().toIso8601String(),
      'deviceId': _randomId(),
      'boxes': <dynamic>[],
      'settings': {'pinHash': '', 'biometric': false, 'language': 'ar', 'darkMode': false},
      'credits': <dynamic>[],
      'expenses': <dynamic>[],
      'reminders': <dynamic>[],
      'trash': <dynamic>[],
      'logs': <dynamic>[],
      'backups': <dynamic>[],
    };
  }

  static void _ensureShape(Map<String, dynamic> d) {
    d['format'] ??= 1;
    d['revision'] ??= 0;
    d['updatedAt'] ??= DateTime.now().toIso8601String();
    d['deviceId'] ??= _randomId();
    for (final key in ['boxes', 'credits', 'expenses', 'reminders', 'trash', 'logs', 'backups']) {
      if (d[key] is! List) d[key] = <dynamic>[];
    }
    if (d['settings'] is! Map) {
      d['settings'] = {'pinHash': '', 'biometric': false, 'language': 'ar'};
    }
    final settings = Map<String, dynamic>.from(d['settings'] as Map);
    settings['language'] ??= 'ar';
    settings['pinHash'] ??= '';
    settings['biometric'] ??= false;
    settings['darkMode'] ??= false;
    d['settings'] = settings;
  }

  static String _randomId() {
    final r = Random();
    return '${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(1 << 32)}';
  }
}

String sha256Text(String input) {
  final bytes = utf8.encode(input);
  // Small deterministic local hash for the test build.
  var h1 = 0x811c9dc5;
  for (final b in bytes) {
    h1 ^= b;
    h1 = (h1 * 0x01000193) & 0xffffffff;
  }
  return h1.toRadixString(16).padLeft(8, '0');
}

String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(999999)}';

String fmtDate(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String fmtDateTime(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  return '${fmtDate(iso)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String money(num value) {
  final rounded = value.round();
  final s = rounded.toString();
  final parts = <String>[];
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    parts.add(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) parts.add(' ');
  }
  return '${parts.join()} DA';
}

num numValue(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '') ?? 0;
}

class LHHome extends StatefulWidget {
  const LHHome({super.key, required this.initialData});

  final Map<String, dynamic> initialData;

  @override
  State<LHHome> createState() => _LHHomeState();
}

class _LHHomeState extends State<LHHome> {
  late Map<String, dynamic> db;
  int tab = 0;
  String search = '';
  String language = 'ar';

  @override
  void initState() {
    super.initState();
    db = Map<String, dynamic>.from(widget.initialData);
    final settings = Map<String, dynamic>.from(db['settings'] as Map? ?? {});
    language = settings['language']?.toString() ?? 'ar';
    currentAppLanguage = language;
    azDarkMode.value = settings['darkMode'] == true;
  }

  List<Map<String, dynamic>> list(String key) {
    final raw = db[key];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> save({
    required String action,
    required String details,
  }) async {
    db['revision'] = numValue(db['revision']) + 1;
    db['updatedAt'] = DateTime.now().toIso8601String();

    final logs = list('logs');
    logs.insert(0, {
      'id': newId(),
      'action': action,
      'details': details,
      'at': db['updatedAt'],
      'deviceId': db['deviceId'],
    });
    db['logs'] = logs.take(300).toList();
    await LocalStore.save(db);
    if (mounted) setState(() {});
  }

  Future<void> addBox() async {
    final result = await showInventoryDialog(context, existing: list('boxes'));
    if (result == null) return;
    final boxes = list('boxes');
    final name = result['name'].toString().trim();
    final pieces = numValue(result['pieces']).round();
    final now = DateTime.now().toIso8601String();
    // Keep each purchase as a transaction; stock is aggregated by product name.
    boxes.insert(0, {
      'id': newId(),
      'name': name,
      'type': result['type'],
      'count': numValue(result['cartons']).round(),
      'piecesPerCarton': numValue(result['piecesPerCarton']).round(),
      'pieces': pieces,
      'purchasePrice': numValue(result['purchasePrice']),
      'unitPrice': numValue(result['unitPrice']),
      'totalCost': numValue(result['totalCost']),
      'date': now,
    });
    db['boxes'] = boxes;
    await save(
      action: 'إضافة مخزون',
      details: '$name - $pieces حبة - ${money(numValue(result['totalCost']))}',
    );
  }

  Future<void> addCredit() async {
    final result = await showCreditDialog(context);
    if (result == null) return;

    result['id'] = newId();
    result['createdAt'] = DateTime.now().toIso8601String();
    result['paid'] = false;

    final credits = list('credits');
    credits.insert(0, result);
    db['credits'] = credits;
    await save(
      action: 'إضافة كريدي',
      details: '${result['name']} - ${money(numValue(result['amount']))}',
    );
  }

  Future<void> addExpense() async {
    final result = await showExpenseDialog(context);
    if (result == null) return;

    result['id'] = newId();
    result['createdAt'] = DateTime.now().toIso8601String();

    final expenses = list('expenses');
    expenses.insert(0, result);
    db['expenses'] = expenses;
    await save(
      action: 'إضافة مصروف',
      details: '${result['name']} - ${money(numValue(result['amount']))}',
    );
  }

  Future<void> togglePaid(Map<String, dynamic> item) async {
    final credits = list('credits');
    final index = credits.indexWhere((e) => e['id'] == item['id']);
    if (index < 0) return;

    final paid = credits[index]['paid'] == true;
    credits[index]['paid'] = !paid;
    credits[index]['paidAt'] =
        !paid ? DateTime.now().toIso8601String() : null;
    db['credits'] = credits;

    await save(
      action: !paid ? 'تسديد كريدي' : 'إلغاء التسديد',
      details: '${item['name']} - ${money(numValue(item['amount']))}',
    );
  }

  Future<void> deleteItem(String type, Map<String, dynamic> item) async {
    final title = type == 'credits'
        ? item['name']
        : type == 'expenses'
            ? item['name']
            : '${item['name'] ?? 'مخزون'} (${item['pieces'] ?? item['count']} حبة)';

    final ok = await confirmDialog(
      context,
      'نقل إلى سلة المحذوفات؟',
      title,
    );
    if (!ok) return;

    final source = list(type);
    source.removeWhere((e) => e['id'] == item['id']);
    db[type] = source;

    final trash = list('trash');
    trash.insert(0, {
      'id': newId(),
      'type': type,
      'item': item,
      'deletedAt': DateTime.now().toIso8601String(),
    });
    db['trash'] = trash;

    await save(action: 'حذف', details: title);
  }

  Future<void> restoreTrash(Map<String, dynamic> trashItem) async {
    final type = trashItem['type']?.toString() ?? '';
    final itemRaw = trashItem['item'];
    if (itemRaw is! Map || !['boxes', 'credits', 'expenses'].contains(type)) {
      return;
    }
    final item = Map<String, dynamic>.from(itemRaw);
    final target = list(type);
    target.insert(0, item);
    db[type] = target;

    final trash = list('trash');
    trash.removeWhere((e) => e['id'] == trashItem['id']);
    db['trash'] = trash;

    await save(action: 'استعادة', details: 'استعادة عنصر');
  }

  Future<void> emptyTrash() async {
    final ok = await confirmDialog(
      context,
      'حذف نهائي',
      'سيتم حذف عناصر السلة نهائيًا.',
    );
    if (!ok) return;
    db['trash'] = <dynamic>[];
    await save(action: 'تفريغ السلة', details: 'حذف نهائي');
  }

  Future<void> backup() async {
    final backups = list('backups');
    backups.insert(0, {
      'id': newId(),
      'createdAt': DateTime.now().toIso8601String(),
      'revision': db['revision'],
      'data': jsonDecode(jsonEncode(db)),
    });
    db['backups'] = backups.take(10).toList();
    await save(action: 'نسخة محلية', details: 'إنشاء نسخة احتياطية');
    showSnack('تم إنشاء النسخة المحلية');
  }

  Future<void> restoreBackup(Map<String, dynamic> backup) async {
    final raw = backup['data'];
    if (raw is! Map) return;

    final ok = await confirmDialog(
      context,
      'استعادة النسخة',
      'سيتم استبدال البيانات الحالية بهذه النسخة.',
    );
    if (!ok) return;

    final restored = Map<String, dynamic>.from(raw);
    restored['backups'] = db['backups'];
    restored['revision'] = numValue(db['revision']) + 1;
    restored['updatedAt'] = DateTime.now().toIso8601String();
    restored['deviceId'] = db['deviceId'];
    db = restored;
    await LocalStore.save(db);
    if (mounted) setState(() {});
    showSnack('تمت الاستعادة');
  }

  Future<void> exportLH() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/AZ_Store_Backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(db), flush: true);

      await SharePlus.instance.share(
        ShareParams(
          title: 'مشاركة ملف AZ Store',
          text: 'نسخة بيانات AZ Store المحلية',
          files: [
            XFile(file.path, mimeType: 'application/json'),
          ],
          fileNameOverrides: ['AZ_Store_Backup.json'],
        ),
      );
      showSnack('تم فتح قائمة المشاركة');
    } catch (e) {
      showSnack('فشل التصدير');
    }
  }

  Future<void> importLH() async {
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['lh', 'json', 'bin', 'txt'],
      );
      if (selected == null) return;

      final bytes = await selected.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: false).replaceFirst('\uFEFF', '').trim();
      // Some Android sharing apps rename JSON attachments to .bin;
      // identify the backup by its JSON content, not its filename extension.
      final decoded = jsonDecode(content);
      if (decoded is! Map) throw Exception('invalid');

      final imported = Map<String, dynamic>.from(decoded);
      final importedRevision = numValue(imported['revision']);
      final currentRevision = numValue(db['revision']);

      if (importedRevision < currentRevision) {
        final ok = await confirmDialog(
          context,
          'نسخة أقدم',
          'الملف المستورد أقدم من النسخة الحالية. هل تريد استبداله؟',
        );
        if (!ok) return;
      }

      imported['deviceId'] = db['deviceId'];
      imported['revision'] = currentRevision + 1;
      imported['updatedAt'] = DateTime.now().toIso8601String();

      if (imported['settings'] is! Map) {
        imported['settings'] = db['settings'];
      }

      db = imported;
      await save(
        action: 'استيراد ملف AZ Store',
        details: 'استيراد نسخة خارجية',
      );
      showSnack('تم استيراد الملف');
    } catch (_) {
      showSnack('تعذر استرداد الملف. اختر ملف النسخة الاحتياطية JSON أو BIN الذي يحتوي على بيانات AZ Store.');
    }
  }

  Future<void> chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اختيار اللغة / Choose language / Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(value: 'ar', groupValue: language, title: const Text('العربية'), onChanged: (v) => Navigator.pop(dialogContext, v)),
            RadioListTile<String>(value: 'fr', groupValue: language, title: const Text('Français'), onChanged: (v) => Navigator.pop(dialogContext, v)),
            RadioListTile<String>(value: 'en', groupValue: language, title: const Text('English'), onChanged: (v) => Navigator.pop(dialogContext, v)),
          ],
        ),
      ),
    );
    if (selected == null) return;
    language = selected;
    currentAppLanguage = selected;
    final settings = Map<String, dynamic>.from(db['settings'] as Map? ?? {});
    settings['language'] = selected;
    db['settings'] = settings;
    await save(action: 'تغيير اللغة', details: selected);
    if (mounted) setState(() {});
  }

  Future<void> configureSecurity() async {
    final settings = Map<String, dynamic>.from(
      db['settings'] as Map? ?? <String, dynamic>{},
    );
    final pinSet = settings['pinHash']?.toString().isNotEmpty == true;
    final biometric = settings['biometric'] == true;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🔐 الحماية',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('قفل PIN'),
                      subtitle: Text(pinSet ? 'مفعل' : 'غير مفعل'),
                      value: pinSet,
                      onChanged: (_) async {
                        if (pinSet) {
                          final ok = await confirmDialog(
                            context,
                            'إزالة PIN',
                            'هل تريد تعطيل رمز PIN؟',
                          );
                          if (!ok) return;
                          settings['pinHash'] = '';
                        } else {
                          final pin = await pinDialog(context);
                          if (pin == null) return;
                          settings['pinHash'] = sha256Text(pin);
                        }
                        setSheet(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('بصمة / قفل الجهاز'),
                      subtitle: const Text('يستخدم حماية الهاتف المحلية'),
                      value: biometric,
                      onChanged: (_) async {
                        final auth = LocalAuthentication();
                        try {
                          final supported = await auth.isDeviceSupported();
                          if (!supported) {
                            showSnack('هذا الهاتف لا يدعم المصادقة المحلية');
                            return;
                          }
                          settings['biometric'] = !biometric;
                          setSheet(() {});
                        } catch (_) {
                          showSnack('تعذر فحص الحماية');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        db['settings'] = settings;
                        await save(
                          action: 'تعديل الحماية',
                          details: 'PIN/بصمة',
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  int countBoxes() => list('boxes').fold(0, (sum, e) => sum + numValue(e['count']).round());

  int totalPieces() => list('boxes').fold(0, (sum, e) {
    final explicit = e['pieces'];
    if (explicit != null) return sum + numValue(explicit).round();
    return sum + numValue(e['count']).round(); // legacy records were carton counts only
  });

  List<Map<String, dynamic>> inventorySummary() {
    final result = <String, Map<String, dynamic>>{};
    for (final e in list('boxes')) {
      final name = e['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final item = result.putIfAbsent(name.toLowerCase(), () => {'name': name, 'pieces': 0, 'cartons': 0, 'lastDate': e['date'] ?? ''});
      item['pieces'] = numValue(item['pieces']) + numValue(e['pieces']);
      item['cartons'] = numValue(item['cartons']) + numValue(e['count']);
      if ((e['date']?.toString() ?? '').compareTo(item['lastDate'].toString()) > 0) item['lastDate'] = e['date'];
    }
    return result.values.toList();
  }

  num creditTotal() =>
      list('credits').fold<num>(0, (sum, e) => sum + numValue(e['amount']));

  num unpaidTotal() => list('credits')
      .where((e) => e['paid'] != true)
      .fold<num>(0, (sum, e) => sum + numValue(e['amount']));

  num expenseTotal() =>
      list('expenses').fold<num>(0, (sum, e) => sum + numValue(e['amount']));

  List<Map<String, dynamic>> filtered(String type) {
    final q = search.trim().toLowerCase();
    final source = list(type);
    if (q.isEmpty) return source;

    return source.where((e) {
      final text = jsonEncode(e).toLowerCase();
      return text.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildBoxes(),
      buildCredits(),
      buildExpenses(),
      buildMore(),
    ];

    return Directionality(
      textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0877E8),
          foregroundColor: Colors.white,
          title: const Text(
            'AZ Store',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, size: 18),
                    SizedBox(width: 4),
                    Text('أوفلاين'),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: pages[tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() {
            tab = i;
            search = '';
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'الكراتين',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card),
              label: 'الكريدي',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'المصاريف',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFEAF4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0877E8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.cloud_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('إدارة بيانات AZ Store محليًا وبأمان'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            dashboardCard(
              'الكراتين',
              '${countBoxes()}',
              Icons.inventory_2,
              () => setState(() => tab = 1),
            ),
            dashboardCard(
              'الكريدي',
              money(creditTotal()),
              Icons.credit_card,
              () => setState(() => tab = 2),
            ),
            dashboardCard(
              'المتبقي',
              money(unpaidTotal()),
              Icons.warning_amber,
              () => setState(() => tab = 2),
            ),
            dashboardCard(
              'المصاريف',
              money(expenseTotal()),
              Icons.payments,
              () => setState(() => tab = 3),
            ),
          ],
        ),
        const SizedBox(height: 18),
        searchBox(),
        const SizedBox(height: 18),
        const Text(
          'آخر العمليات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...list('logs').take(8).map(operationTile),
      ],
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0877E8), size: 28),
              const Spacer(),
              Text(title),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return TextField(
      onChanged: (v) => setState(() => search = v),
      decoration: InputDecoration(
        hintText: 'بحث سريع...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildBoxes() {
    final purchases = filtered('boxes');
    final summary = inventorySummary().where((e) => search.trim().isEmpty || jsonEncode(e).toLowerCase().contains(search.trim().toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        pageHeader('المخزون والكراتين', 'إضافة كراتين أو حبات مفردة', Icons.inventory_2, addBox),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          const Icon(Icons.inventory, color: Color(0xFF0877E8), size: 30),
          const SizedBox(width: 10),
          Expanded(child: Text('إجمالي الحبات في السجل: ${totalPieces()}')),
        ]))),
        const SizedBox(height: 12),
        searchBox(),
        const SizedBox(height: 12),
        const Text('المخزون حسب السلعة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...summary.map((e) => itemCard(
          icon: Icons.inventory_2,
          title: e['name'].toString(),
          subtitle: 'المخزون: ${e['pieces']} حبة • الكراتين المسجلة: ${e['cartons']}\nآخر عملية: ${fmtDateTime(e['lastDate']?.toString() ?? '')}',
          trailing: const Icon(Icons.inventory_2_outlined),
        )),
        const SizedBox(height: 10),
        const Text('آخر عمليات الشراء', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...purchases.map((e) => itemCard(
          icon: e['type'] == 'loose' ? Icons.shopping_bag_outlined : Icons.inventory_2,
          title: '${e['name'] ?? 'مخزون'} • ${numValue(e['pieces']).round()} حبة',
          subtitle: '${e['type'] == 'loose' ? 'شراء حبات مفردة' : '${e['count'] ?? 0} كرتونة × ${e['piecesPerCarton'] ?? 0} حبة'}\nسعر الوحدة: ${money(numValue(e['unitPrice']))} • الإجمالي: ${money(numValue(e['totalCost']))}\n${fmtDateTime(e['date']?.toString() ?? '')}',
          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteItem('boxes', e)),
        )),
      ],
    );
  }

  Widget buildCredits() {
    final items = filtered('credits');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        pageHeader(
          'الكريدي',
          'متابعة الديون والتسديد',
          Icons.credit_card,
          addCredit,
        ),
        const SizedBox(height: 12),
        searchBox(),
        const SizedBox(height: 12),
        ...items.map(
          (e) => itemCard(
            icon: e['paid'] == true
                ? Icons.check_circle
                : Icons.credit_card,
            iconColor: e['paid'] == true ? Colors.green : Colors.orange,
            title: e['name']?.toString() ?? '',
            subtitle:
                '${money(numValue(e['amount']))} • ${fmtDate(e['createdAt']?.toString() ?? '')}'
                '${(e['phone']?.toString().isNotEmpty ?? false) ? '\n📞 ${e['phone']}' : ''}'
                '${(e['note']?.toString().isNotEmpty ?? false) ? '\n📝 ${e['note']}' : ''}',
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'paid') await togglePaid(e);
                if (v == 'delete') await deleteItem('credits', e);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'paid',
                  child: Text(
                    e['paid'] == true ? 'إلغاء التسديد' : 'تم التسديد',
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('نقل للسلة'),
                ),
              ],
            ),
            badge: e['paid'] == true ? 'تم التسديد' : 'غير مسدد',
            badgeColor: e['paid'] == true ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget buildExpenses() {
    final items = filtered('expenses');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        pageHeader(
          'المصاريف',
          'تسجيل ومتابعة المصاريف',
          Icons.payments,
          addExpense,
        ),
        const SizedBox(height: 12),
        searchBox(),
        const SizedBox(height: 12),
        ...items.map(
          (e) => itemCard(
            icon: Icons.payments,
            iconColor: Colors.green,
            title: e['name']?.toString() ?? '',
            subtitle:
                '${money(numValue(e['amount']))} • ${fmtDate(e['createdAt']?.toString() ?? '')}'
                '${(e['note']?.toString().isNotEmpty ?? false) ? '\n📝 ${e['note']}' : ''}',
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => deleteItem('expenses', e),
            ),
          ),
        ),
      ],
    );
  }

  Widget pageHeader(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAdd,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE7F2FF),
          child: Icon(icon, color: const Color(0xFF0877E8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle),
            ],
          ),
        ),
        FloatingActionButton.small(
          heroTag: title,
          onPressed: onAdd,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget itemCard({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    String? badge,
    Color? badgeColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? const Color(0xFF0877E8)).withAlpha(25),
          child: Icon(icon, color: iconColor ?? const Color(0xFF0877E8)),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (badgeColor ?? Colors.grey).withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget operationTile(Map<String, dynamic> e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history, color: Color(0xFF0877E8)),
        title: Text(e['action']?.toString() ?? ''),
        subtitle: Text(
          '${e['details'] ?? ''}\n${fmtDateTime(e['at']?.toString() ?? '')}',
        ),
      ),
    );
  }

  Future<void> showReminders() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Directionality(
        textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: RemindersPage(
          items: list('reminders'),
          onAdd: addReminder,
          onDone: toggleReminderDone,
          onDelete: deleteReminder,
          onConvert: convertReminderToExpense,
        ),
      ),
    ));
    if (mounted) setState(() {});
  }

  Future<void> addReminder() async {
    final result = await showReminderDialog(context);
    if (result == null) return;
    result['id'] = newId();
    result['createdAt'] = DateTime.now().toIso8601String();
    result['done'] = false;
    final reminders = list('reminders')..insert(0, result);
    db['reminders'] = reminders;
    await save(action: 'إضافة ملاحظة/تذكير', details: result['title'].toString());
  }

  Future<void> toggleReminderDone(Map<String, dynamic> item) async {
    final reminders = list('reminders');
    final index = reminders.indexWhere((e) => e['id'] == item['id']);
    if (index < 0) return;
    reminders[index]['done'] = reminders[index]['done'] != true;
    reminders[index]['completedAt'] = reminders[index]['done'] == true ? DateTime.now().toIso8601String() : null;
    db['reminders'] = reminders;
    await save(action: 'تحديث تذكير', details: item['title'].toString());
  }

  Future<void> deleteReminder(Map<String, dynamic> item) async {
    final reminders = list('reminders')..removeWhere((e) => e['id'] == item['id']);
    db['reminders'] = reminders;
    final trash = list('trash')..insert(0, {'type':'reminders', 'item':item, 'deletedAt':DateTime.now().toIso8601String()});
    db['trash'] = trash;
    await save(action: 'حذف تذكير', details: item['title'].toString());
  }

  Future<void> convertReminderToExpense(Map<String, dynamic> item) async {
    final amount = numValue(item['price']);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف سعرًا للتذكير أولًا')));
      return;
    }
    final ok = await confirmDialog(context, 'تحويل إلى مصروف', 'سيتم تسجيل ${money(amount)} كمصروف. هل تريد المتابعة؟');
    if (!ok) return;
    final expenses = list('expenses')..insert(0, {
      'id': newId(), 'name': item['title'], 'amount': amount,
      'note': 'تم التحويل من التذكيرات: ${item['note'] ?? ''}',
      'createdAt': DateTime.now().toIso8601String(), 'sourceReminderId': item['id'],
    });
    db['expenses'] = expenses;
    final reminders = list('reminders');
    final index = reminders.indexWhere((e) => e['id'] == item['id']);
    if (index >= 0) reminders[index]['convertedToExpense'] = true;
    db['reminders'] = reminders;
    await save(action: 'تحويل تذكير إلى مصروف', details: '${item['title']} - ${money(amount)}');
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المبلغ إلى المصاريف')));
  }

  Widget buildMore() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'المزيد',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        moreTile(
          Icons.bar_chart,
          'الإحصائيات والملخص',
          'إجمالي الكريدي والمصاريف والكراتين',
          showStats,
        ),
        moreTile(
          Icons.history,
          'سجل العمليات',
          'معرفة ماذا حدث ومتى',
          showLogs,
        ),
        moreTile(
          Icons.notifications_active_outlined,
          'ذكّرني / ملاحظاتي',
          '${list('reminders').where((e) => e['done'] != true).length} تذكير غير مكتمل',
          showReminders,
        ),
        moreTile(
          Icons.delete_sweep,
          'سلة المحذوفات',
          '${list('trash').length} عنصر',
          showTrash,
        ),
        moreTile(
          Icons.backup,
          'النسخ المحلية',
          '${list('backups').length} نسخة',
          showBackups,
        ),
        SwitchListTile(
          secondary: Icon(azDarkMode.value ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF0877E8)),
          title: const Text('الوضع الداكن'),
          subtitle: Text(azDarkMode.value ? 'مفعل' : 'غير مفعل'),
          value: azDarkMode.value,
          onChanged: (enabled) async {
            final settings = Map<String, dynamic>.from(db['settings'] as Map? ?? {});
            settings['darkMode'] = enabled;
            db['settings'] = settings;
            azDarkMode.value = enabled;
            await save(action: 'تغيير المظهر', details: enabled ? 'الوضع الداكن' : 'الوضع الفاتح');
            if (mounted) setState(() {});
          },
        ),
        moreTile(
          Icons.language,
          'اللغة / Language / Langue',
          language == 'ar' ? 'العربية' : language == 'fr' ? 'Français' : 'English',
          chooseLanguage,
        ),
        moreTile(
          Icons.security,
          'PIN / بصمة',
          'حماية التطبيق محليًا',
          configureSecurity,
        ),
        moreTile(
          Icons.file_upload,
          'تصدير ومشاركة ملف AZ Store',
          'نسخة بيانات قابلة للنقل',
          exportLH,
        ),
        moreTile(
          Icons.file_download,
          'استيراد ملف AZ Store',
          'استعادة ملف من هاتف آخر',
          importLH,
        ),
        moreTile(
          Icons.info_outline,
          'حالة البيانات',
          'Revision ${db['revision']} • آخر تعديل ${fmtDateTime(db['updatedAt'].toString())}',
          () => showStatus(),
        ),
      ],
    );
  }

  Widget moreTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE7F2FF),
          child: Icon(icon, color: const Color(0xFF0877E8)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }

  Future<void> showStats() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📊 الإحصائيات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            statRow('📦 عدد الكراتين', '${countBoxes()}'),
            statRow('💳 إجمالي الكريدي', money(creditTotal())),
            statRow('🔴 المتبقي', money(unpaidTotal())),
            statRow(
              '🟢 المسدد',
              money(creditTotal() - unpaidTotal()),
            ),
            statRow('💰 المصاريف', money(expenseTotal())),
            statRow('📝 العمليات', '${list('logs').length}'),
          ],
        ),
      ),
    );
  }

  Widget statRow(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> showLogs() async {
    await showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('📝 سجل العمليات'),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: ListView(
              children: list('logs').map(operationTile).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showTrash() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '🗑️ سلة المحذوفات',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: list('trash').map((e) {
                      final item = e['item'] is Map
                          ? Map<String, dynamic>.from(e['item'])
                          : <String, dynamic>{};
                      final title = item['name']?.toString() ??
                          'عدد ${item['count'] ?? ''} كرتونة';
                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(
                            'حذف: ${fmtDateTime(e['deletedAt']?.toString() ?? '')}',
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await restoreTrash(e);
                            },
                            child: const Text('استعادة'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await emptyTrash();
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('تفريغ السلة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showBackups() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '💾 النسخ المحلية',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...list('backups').map(
                  (e) => Card(
                    child: ListTile(
                      title: Text(
                        'Revision ${e['revision'] ?? '-'}',
                      ),
                      subtitle: Text(
                        fmtDateTime(e['createdAt']?.toString() ?? ''),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await restoreBackup(e);
                        },
                        child: const Text('استعادة'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showStatus() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🟢 حالة البيانات'),
        content: Text(
          'الوضع: أوفلاين\n'
          'السحابة: غير مفعلة\n'
          'Revision: ${db['revision']}\n'
          'الجهاز: ${db['deviceId']}\n'
          'آخر تعديل: ${fmtDateTime(db['updatedAt'].toString())}',
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> showInventoryDialog(
  BuildContext context, {required List<Map<String, dynamic>> existing}) async {
  final name = TextEditingController();
  final cartons = TextEditingController(text: '1');
  final piecesPerCarton = TextEditingController(text: '24');
  final quantity = TextEditingController(text: '1');
  final cartonPrice = TextEditingController();
  final unitPrice = TextEditingController();
  String type = 'carton';
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('إضافة إلى المخزون'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السلعة *')),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'carton', label: Text('كراتين'), icon: Icon(Icons.inventory_2)),
            ButtonSegment(value: 'loose', label: Text('حبات مفردة'), icon: Icon(Icons.shopping_bag_outlined)),
          ],
          selected: {type},
          onSelectionChanged: (v) => setDialogState(() => type = v.first),
        ),
        if (type == 'carton') ...[
          TextField(controller: cartons, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'عدد الكراتين')),
          TextField(controller: piecesPerCarton, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'عدد الحبات في الكرتونة الواحدة')),
          TextField(controller: cartonPrice, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'سعر شراء الكرتونة (DA)')),
          TextField(controller: unitPrice, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'سعر شراء الحبة الواحدة (اختياري)')),
        ] else ...[
          TextField(controller: quantity, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'عدد الحبات المشتراة')),
          TextField(controller: unitPrice, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'سعر شراء الحبة الواحدة (DA)')),
        ],
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
        FilledButton(onPressed: () {
          final n = name.text.trim();
          if (n.isEmpty) return;
          final int cartonCount = type == 'carton' ? (int.tryParse(cartons.text) ?? 0) : 0;
          final int perCarton = type == 'carton' ? (int.tryParse(piecesPerCarton.text) ?? 0) : 0;
          final int looseCount = type == 'loose' ? (int.tryParse(quantity.text) ?? 0) : cartonCount * perCarton;
          final num unit = num.tryParse(unitPrice.text) ?? 0;
          final num price = num.tryParse(cartonPrice.text) ?? 0;
          if (looseCount <= 0 || (type == 'carton' && (cartonCount <= 0 || perCarton <= 0 || price <= 0)) || (type == 'loose' && unit <= 0)) return;
          final num total = type == 'carton' ? cartonCount * price : looseCount * unit;
          final num effectiveUnit = type == 'loose' ? unit : (unit > 0 ? unit : price / perCarton);
          Navigator.pop(dialogContext, {
            'name': n, 'type': type, 'cartons': cartonCount,
            'piecesPerCarton': perCarton, 'pieces': looseCount,
            'purchasePrice': type == 'carton' ? price : unit,
            'unitPrice': effectiveUnit, 'totalCost': total,
          });
        }, child: const Text('حفظ')),
      ],
    )),
  );
  name.dispose(); cartons.dispose(); piecesPerCarton.dispose(); quantity.dispose(); cartonPrice.dispose(); unitPrice.dispose();
  return result;
}

Future<num?> numberDialog(
  BuildContext context, {
  required String title,
  required String label,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<num>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final value = num.tryParse(controller.text);
            if (value != null) Navigator.pop(dialogContext, value);
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<Map<String, dynamic>?> showCreditDialog(BuildContext context) async {
  final name = TextEditingController();
  final amount = TextEditingController();
  final phone = TextEditingController();
  final note = TextEditingController();

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('💳 إضافة كريدي'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'اسم الشخص *',
              ),
            ),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'المبلغ (DA) *',
              ),
            ),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
              ),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(
                labelText: 'ملاحظة (اختيارية)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final n = name.text.trim();
            final a = num.tryParse(amount.text.trim());
            if (n.isEmpty || a == null || a <= 0) return;
            Navigator.pop(dialogContext, {
              'name': n,
              'amount': a,
              'phone': phone.text.trim(),
              'note': note.text.trim(),
            });
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );

  name.dispose();
  amount.dispose();
  phone.dispose();
  note.dispose();
  return result;
}

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key, required this.items, required this.onAdd, required this.onDone, required this.onDelete, required this.onConvert});
  final List<Map<String, dynamic>> items;
  final Future<void> Function() onAdd;
  final Future<void> Function(Map<String, dynamic>) onDone;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Future<void> Function(Map<String, dynamic>) onConvert;
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}
class _RemindersPageState extends State<RemindersPage> {
  @override
  Widget build(BuildContext context) {
    final items = [...widget.items]..sort((a,b) {
      if (a['done'] == true && b['done'] != true) return 1;
      if (a['done'] != true && b['done'] == true) return -1;
      return (a['dueDate']?.toString() ?? '9999').compareTo(b['dueDate']?.toString() ?? '9999');
    });
    return Scaffold(
      appBar: AppBar(title: const Text('ذكّرني وملاحظاتي'), actions: [IconButton(onPressed: () async { await widget.onAdd(); if(mounted) setState((){}); }, icon: const Icon(Icons.add))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { await widget.onAdd(); if(mounted) setState((){}); }, icon: const Icon(Icons.add), label: const Text('إضافة تذكير')),
      body: items.isEmpty ? const Center(child: Text('لا توجد ملاحظات أو تذكيرات بعد')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: items.length, itemBuilder: (context, i) {
        final e = items[i]; final done = e['done'] == true; final price = numValue(e['price']);
        final due = e['dueDate']?.toString() ?? '';
        final dueDate = DateTime.tryParse(due);
        final overdue = !done && dueDate != null && DateTime(dueDate.year,dueDate.month,dueDate.day).isBefore(DateTime.now()) && due.isNotEmpty;
        return Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(e['title']?.toString() ?? 'بدون عنوان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, decoration: done ? TextDecoration.lineThrough : null))), if(overdue) const Chip(label: Text('متأخر'), avatar: Icon(Icons.warning_amber, size: 16)), Checkbox(value: done, onChanged: (_) async { await widget.onDone(e); if(mounted) setState((){}); })]),
          if ((e['note']?.toString() ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(e['note'].toString())),
          if ((e['phone']?.toString() ?? '').isNotEmpty) Text('📞 ${e['phone']}'),
          if (due.isNotEmpty) Text('📅 موعد: ${due.length >= 10 ? due.substring(0,10) : due}'),
          if (price > 0) Text('💰 السعر: ${money(price)}'),
          if (e['convertedToExpense'] == true) const Text('✓ تم تحويله إلى مصروف', style: TextStyle(color: Colors.green)),
          Wrap(alignment: WrapAlignment.end, children: [if(price > 0 && e['convertedToExpense'] != true) TextButton.icon(onPressed: () async { await widget.onConvert(e); if(mounted) setState((){}); }, icon: const Icon(Icons.payments_outlined), label: const Text('تحويل إلى مصروف')), IconButton(tooltip:'حذف', onPressed: () async { await widget.onDelete(e); if(mounted) setState((){}); }, icon: const Icon(Icons.delete_outline))])
        ])));
      }),
    );
  }
}

Future<Map<String, dynamic>?> showReminderDialog(BuildContext context) async {
  final title = TextEditingController(); final note = TextEditingController(); final phone = TextEditingController(); final price = TextEditingController();
  DateTime? dueDate;
  final result = await showDialog<Map<String,dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
    title: const Text('إضافة ملاحظة أو تذكير'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller:title, decoration: const InputDecoration(labelText:'عنوان الشغل أو التذكير *')),
      TextField(controller:note, minLines:2, maxLines:4, decoration: const InputDecoration(labelText:'ملاحظات / تفاصيل الشغل')),
      TextField(controller:phone, keyboardType:TextInputType.phone, decoration: const InputDecoration(labelText:'رقم الهاتف (اختياري)')),
      TextField(controller:price, keyboardType:const TextInputType.numberWithOptions(decimal:true), inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))], decoration: const InputDecoration(labelText:'السعر المتوقع (DA، اختياري)')),
      const SizedBox(height:8), OutlinedButton.icon(onPressed:() async { final now=DateTime.now(); final d=await showDatePicker(context:ctx, initialDate:dueDate ?? now, firstDate:DateTime(now.year-1), lastDate:DateTime(now.year+10)); if(d!=null) setLocal(()=>dueDate=d); }, icon:const Icon(Icons.calendar_month), label:Text(dueDate==null?'اختيار يوم التذكير':'الموعد: ${dueDate!.year}-${dueDate!.month.toString().padLeft(2,'0')}-${dueDate!.day.toString().padLeft(2,'0')}')),
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx), child:const Text('إلغاء')), FilledButton(onPressed:(){ final t=title.text.trim(); final p=num.tryParse(price.text.trim()) ?? 0; if(t.isEmpty || p<0) return; Navigator.pop(ctx, {'title':t,'note':note.text.trim(),'phone':phone.text.trim(),'price':p,'dueDate':dueDate==null?null:DateTime(dueDate!.year,dueDate!.month,dueDate!.day).toIso8601String(),'done':false,'convertedToExpense':false}); }, child:const Text('حفظ'))]
  )));
  title.dispose(); note.dispose(); phone.dispose(); price.dispose(); return result;
}

Future<Map<String, dynamic>?> showExpenseDialog(BuildContext context) async {
  final name = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('💰 إضافة مصروف'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'اسم المصروف *',
              ),
            ),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'المبلغ (DA) *',
              ),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(
                labelText: 'ملاحظة (اختيارية)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final n = name.text.trim();
            final a = num.tryParse(amount.text.trim());
            if (n.isEmpty || a == null || a <= 0) return;
            Navigator.pop(dialogContext, {
              'name': n,
              'amount': a,
              'note': note.text.trim(),
            });
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );

  name.dispose();
  amount.dispose();
  note.dispose();
  return result;
}

Future<bool> confirmDialog(
  BuildContext context,
  String title,
  String message,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('موافق'),
        ),
      ],
    ),
  );
  return result == true;
}

Future<String?> pinDialog(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('🔐 تعيين PIN'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 8,
        decoration: const InputDecoration(
          hintText: '4 إلى 8 أرقام',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.length >= 4 && value.length <= 8) {
              Navigator.pop(dialogContext, value);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
