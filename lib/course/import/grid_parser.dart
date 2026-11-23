import '../models/course.dart';
import 'import_models.dart';

/// 解析“周几 × 节次”的表格型课表（Word/HTML/Excel 通用）。
///
/// 典型结构：
/// 第一行或某一行为「周一 周二 …」，最左列为「1 2 3 …」或「第1节」，
/// 单元格里是课程名/教师/地点/周次。不同学校排版差异较大，这里做启发式识别，
/// 导入后统一让用户预览确认。
CourseImportResult parseTimetableGrid(
  List<List<String>> rows, {
  required int totalWeeks,
}) {
  final warnings = <String>[];
  if (rows.isEmpty) {
    return const CourseImportResult(courses: <CourseDraft>[], warnings: <String>['文件里没有可识别的表格']);
  }

  var headerRow = -1;
  var dayColumns = <int, int>{};
  for (var i = 0; i < rows.length; i++) {
    final found = <int, int>{};
    for (var col = 0; col < rows[i].length; col++) {
      final day = TimetableText.weekday(rows[i][col]);
      if (day != null) found[col] = day;
    }
    if (found.length >= 3) {
      headerRow = i;
      dayColumns = found;
      break;
    }
  }

  if (headerRow == -1) {
    warnings.add('没有识别到星期表头，已尝试按文本行解析');
    return parseTextLines(
      rows
          .expand((row) => row)
          .expand((cell) => cell.split('\n'))
          .toList(),
      totalWeeks: totalWeeks,
    );
  }

  final drafts = <CourseDraft>[];
  // 每个星期列当前正在延续的课程（用于合并跨节的单元格）。
  final active = <int, _ActiveCell>{};

  bool flushIfNeeded(int day, _ActiveCell? cell, int currentSection) {
    if (cell != null && currentSection - cell.endSection > 1) {
      drafts[cell.draftIndex] =
          drafts[cell.draftIndex].copyWith(endSection: cell.endSection);
      active.remove(day);
      return true;
    }
    return false;
  }

  for (var rowIndex = headerRow + 1; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    final firstCell = row.isEmpty ? '' : row.first.trim();
    final section = _sectionNumber(firstCell);
    if (section == null) continue;

    for (final entry in dayColumns.entries) {
      final day = entry.value;
      final col = entry.key;
      final text = col < row.length ? TimetableText.cleanLine(row[col]) : '';
      final current = active[day];
      if (text.isEmpty) {
        // 空单元格结束当前课程（跨节合并的常见写法是空行也算延续，这里以 2 行为限）。
        if (current != null && section - current.endSection > 1) {
          active.remove(day);
        }
        continue;
      }
      if (current != null && current.rawText == text && section == current.endSection + 1) {
        current.endSection = section;
        continue;
      }
      flushIfNeeded(day, current, section);
      final draft = parseCellText(text, day, section, totalWeeks);
      if (draft == null) {
        active.remove(day);
        continue;
      }
      drafts.add(draft);
      active[day] = _ActiveCell(
        startSection: section,
        endSection: section,
        rawText: text,
        draftIndex: drafts.length - 1,
      );
    }
  }

  // 把合并单元格的结束节次写回草稿。
  for (final cell in active.values) {
    final draft = drafts[cell.draftIndex];
    drafts[cell.draftIndex] = draft.copyWith(endSection: cell.endSection);
  }

  if (drafts.isEmpty) {
    warnings.add('表格格式没有识别出课程，请检查表头或改用手动录入');
  } else {
    warnings.add('已按表格结构识别 ${drafts.length} 门课程，请逐条核对教师、地点和周次');
  }
  return CourseImportResult(
    courses: drafts,
    warnings: warnings,
    formatLabel: '表格课表',
  );
}

int? _sectionNumber(String raw) {
  final text = raw.replaceAll(RegExp(r'第|节|\s'), '');
  final range = RegExp(r'^(\d+)[-—~至](\d+)$').firstMatch(text);
  if (range != null) return int.tryParse(range.group(1)!);
  return int.tryParse(text);
}

CourseDraft? parseCellText(
  String raw,
  int weekday,
  int section,
  int totalWeeks,
) {
  var text = TimetableText.cleanLine(raw);
  if (text.isEmpty) return null;
  // 常见分隔符统一成换行，再按行解析。
  text = text.replaceAll(RegExp(r'[;；]'), '\n');
  final rawLines = text
      .split(RegExp(r'\n'))
      .map(TimetableText.cleanLine)
      .where((line) => line.isNotEmpty)
      .toList();
  if (rawLines.isEmpty) return null;

  List<String> lines;
  var weeks = <int>[];
  int? parsedStart;
  int? parsedEnd;

  // 先尝试从整段文本中抽取周次/节次。
  final weekMatch = RegExp(r'(\d{1,2}\s*(?:[-—~至]\s*\d{1,2})?)\s*周')
      .allMatches(text)
      .map((match) => match.group(1)!)
      .toList();
  if (weekMatch.isNotEmpty) {
    final parsed = TimetableText.weeks(weekMatch.last, totalWeeks: totalWeeks);
    if (parsed != null) weeks = parsed;
  }
  final sectionMatch = RegExp(r'(\d{1,2})\s*[-—~至]\s*(\d{1,2})\s*节')
      .firstMatch(text);
  if (sectionMatch != null) {
    parsedStart = int.tryParse(sectionMatch.group(1)!);
    parsedEnd = int.tryParse(sectionMatch.group(2)!);
  }

  // 去掉周次/节次行，剩下的通常包含课程名、教师、地点。
  lines = rawLines
      .where((line) => !RegExp(r'^[\d\s,，\-—~至周()（）单双]+$').hasMatch(line))
      .where((line) => !RegExp(r'周[次]?$').hasMatch(line))
      .toList();
  if (lines.isEmpty) lines = rawLines;

  var name = lines.first;
  var teacher = '';
  var location = '';
  final noteLines = <String>[];

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i]
        .replaceAll(RegExp(r'^(教师|老师|任课教师|授课教师)[:：]?'), '')
        .trim();
    if (line.isEmpty) continue;
    if (RegExp(r'(楼|室|教室|校区|地点|实验|机房|体育馆|操场|报告厅|馆|A\d|B\d)')
        .hasMatch(line)) {
      if (location.isEmpty) {
        location = line.replaceAll(RegExp(r'^(地点|教室)[:：]?'), '').trim();
      } else {
        noteLines.add(line);
      }
    } else if (teacher.isEmpty && line.length <= 8 && !line.contains('周')) {
      teacher = line;
    } else {
      noteLines.add(line);
    }
  }

  // 单元格里只有一行但塞了所有字段时，按空格再拆一次。
  if (teacher.isEmpty && location.isEmpty && name.contains(' ')) {
    final tokens = name.split(RegExp(r'\s+'));
    if (tokens.length >= 2) {
      name = tokens.first;
      for (final token in tokens.skip(1)) {
        if (location.isEmpty &&
            RegExp(r'(楼|室|教室|校区|地点|实验|机房|馆)').hasMatch(token)) {
          location = token;
        } else if (teacher.isEmpty && token.length <= 8) {
          teacher = token;
        }
      }
    }
  }

  if (name.trim().isEmpty) return null;
  if (weeks.isEmpty) {
    weeks = List<int>.generate(totalWeeks, (index) => index + 1);
  }
  return CourseDraft(
    name: name.trim(),
    teacher: teacher.trim(),
    location: location.trim(),
    note: noteLines.join('；'),
    weekday: weekday,
    startSection: parsedStart ?? section,
    endSection: parsedEnd ?? section,
    weeks: weeks,
  );
}

class _ActiveCell {
  _ActiveCell({
    required this.startSection,
    required this.endSection,
    required this.rawText,
    required this.draftIndex,
  });

  final int startSection;
  int endSection;
  final String rawText;
  final int draftIndex;
}

/// 兜底：对 PDF/纯文本中「一行一门课」的内容做识别。
CourseImportResult parseTextLines(
  List<String> lines, {
  required int totalWeeks,
}) {
  final warnings = <String>[];
  final drafts = <CourseDraft>[];
  for (final raw in lines) {
    final line = TimetableText.cleanLine(raw);
    if (line.length < 4) continue;
    final dayMatch = TimetableText.weekdayPattern.firstMatch(line);
    if (dayMatch == null) continue;
    final weekday = TimetableText.weekday(dayMatch.group(1));
    if (weekday == null) continue;

    final afterDay = line.substring(dayMatch.end).trim();
    final weeksMatch = RegExp(r'(\d{1,2}\s*(?:[-—~至]\s*\d{1,2})?)\s*周')
        .allMatches(line)
        .map((match) => match.group(1)!)
        .toList();
    final weeks = weeksMatch.isEmpty
        ? List<int>.generate(totalWeeks, (index) => index + 1)
        : TimetableText.weeks(weeksMatch.last, totalWeeks: totalWeeks) ??
            List<int>.generate(totalWeeks, (index) => index + 1);

    final sectionMatch = RegExp(r'(\d{1,2})\s*[-—~至]\s*(\d{1,2})\s*节')
        .firstMatch(afterDay);
    final start = sectionMatch != null
        ? int.tryParse(sectionMatch.group(1)!)
        : null;
    final end = sectionMatch != null
        ? int.tryParse(sectionMatch.group(2)!)
        : null;

    var namePart = line.substring(0, dayMatch.start).trim();
    if (namePart.isEmpty) namePart = afterDay;
    final name = namePart
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[•·\-\d.、]+'), '')
        .trim();
    if (name.isEmpty) continue;

    drafts.add(CourseDraft(
      name: name,
      weekday: weekday,
      startSection: start ?? 1,
      endSection: end ?? start ?? 1,
      weeks: weeks,
      note: '由文本自动识别，请核对节次与周次',
    ));
  }
  if (drafts.isEmpty) {
    warnings.add('没有识别到包含「周几」的课程行，建议复制表格文本或手动录入');
  } else {
    warnings.add('已从文本识别 ${drafts.length} 门课程，建议重点核对节次和时间');
  }
  return CourseImportResult(
    courses: drafts,
    warnings: warnings,
    formatLabel: '文本课表',
  );
}

int colorForIndex(int index) => index % Course.palette.length;
