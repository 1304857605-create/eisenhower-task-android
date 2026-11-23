import '../models/semester.dart';
import 'docx_importer.dart';
import 'html_importer.dart';
import 'ics_importer.dart';
import 'import_models.dart';
import 'spreadsheet_importer.dart';

/// 按文件后缀分发到对应解析器。
///
/// PDF 需要额外的文字提取库，当前版本暂不支持；`.doc` 旧格式和扫描件同样
/// 不支持，页面会提示用户改用 Excel/HTML 或手动录入。
Future<CourseImportResult> importTimetableFile(
  ImportInput input, {
  required SemesterConfig semester,
}) async {
  final extension = input.extension;
  switch (extension) {
    case 'ics':
    case 'ical':
      return parseIcs(input.bytes, semester: semester);
    case 'csv':
    case 'txt':
      return parseCsv(input.bytes, totalWeeks: semester.totalWeeks);
    case 'xlsx':
    case 'xls':
      return parseXlsx(input.bytes, totalWeeks: semester.totalWeeks);
    case 'docx':
      return parseDocx(input.bytes, totalWeeks: semester.totalWeeks);
    case 'html':
    case 'htm':
      return parseHtml(input.bytes, totalWeeks: semester.totalWeeks);
    case 'pdf':
      return const CourseImportResult(
        courses: <CourseDraft>[],
        warnings: <String>[
          '当前版本暂不支持直接解析 PDF；请从教务系统导出 Excel/HTML/ICS，'
          '或在 PDF 中复制课表文本后手动录入。PDF 识别会放在后续版本。',
        ],
      );
    case 'doc':
      return const CourseImportResult(
        courses: <CourseDraft>[],
        warnings: <String>['暂不支持旧版 .doc，请在 Word 中另存为 .docx 或导出 Excel/HTML'],
      );
    default:
      return CourseImportResult(
        courses: const <CourseDraft>[],
        warnings: <String>['不支持的文件类型：.$extension（支持 .ics/.csv/.xlsx/.docx/.html）'],
      );
  }
}
