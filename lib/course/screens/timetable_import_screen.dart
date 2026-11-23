
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../import/import_models.dart';
import '../import/timetable_import_service.dart';
import '../models/course.dart';
import '../state/course_store.dart';
import 'semester_settings_sheet.dart';

/// 课表导入：本地文件解析 + 预览确认，不上传任何文件。
class TimetableImportScreen extends StatefulWidget {
  const TimetableImportScreen({super.key, required this.store});

  final CourseStore store;

  @override
  State<TimetableImportScreen> createState() => _TimetableImportScreenState();
}

class _TimetableImportScreenState extends State<TimetableImportScreen> {
  CourseImportResult? _result;
  String? _fileName;
  bool _loading = false;
  bool _replace = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入课表'),
        actions: <Widget>[
          IconButton(
            tooltip: '学期设置',
            onPressed: () => showSemesterSettings(context, widget.store),
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '支持的文件',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ICS 日历、Excel（.xlsx）、CSV、Word（.docx）、网页（.html）。'
                  '文件只在本机解析，不会上传。PDF 直接解析将在后续版本支持。',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.6,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前学期：第 1 周周一 ${_dateText(widget.store.semester.startDate)}，共 ${widget.store.semester.totalWeeks} 周。'
                  '如果导入后发现周次不对，请先修改学期设置。',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.55,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _loading ? null : _pickFile,
            icon: _loading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 1.8),
                  )
                : const Icon(Icons.upload_file_rounded, size: 19),
            label: Text(_loading ? '正在解析…' : '选择课表文件'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_fileName != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '已解析：$_fileName',
              style: TextStyle(fontSize: 10.5, color: scheme.onSurfaceVariant),
            ),
          ],
          if (result != null) ...<Widget>[
            const SizedBox(height: 18),
            if (result.warnings.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.warnings
                      .map((warning) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '· $warning',
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.5,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ))
                      .toList(growable: false),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Text(
                  '识别到 ${result.courses.length} 门课程',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (result.formatLabel.isNotEmpty)
                  Text(
                    result.formatLabel,
                    style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (result.courses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '没有识别到课程。可以换一个文件，或回到课表手动添加。',
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                ),
              )
            else ...<Widget>[
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ),
                child: Column(
                  children: <Widget>[
                    for (var i = 0; i < result.courses.length && i < 60; i++)
                      _PreviewTile(draft: result.courses[i], isLast: i == result.courses.length - 1 || i == 59),
                  ],
                ),
              ),
              if (result.courses.length > 60)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '仅展示前 60 门，导入时会全部处理。',
                    style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _replace,
                onChanged: (value) => setState(() => _replace = value),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  '覆盖现有课表',
                  style: TextStyle(fontSize: 12, color: scheme.onSurface),
                ),
                subtitle: Text(
                  '关闭时追加导入，并自动跳过重复课程',
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                ),
              ),
              FilledButton(
                onPressed: () => _import(result),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_replace ? '覆盖并导入 ${result.courses.length} 门课程' : '导入 ${result.courses.length} 门课程'),
              ),
            ],
          ],
          const SizedBox(height: 18),
          Text(
            '小提示：如果学校教务系统没有导出按钮，可以打开课表页面后「打印 → 另存为 PDF」，'
            '或把表格复制到 Excel/CSV；PDF 的表格识别不如 Excel 稳定。',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.6,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _loading = true);
    try {
      final file = await FilePicker.pickFile(type: FileType.any);
      if (file == null) {
        setState(() => _loading = false);
        return;
      }
      final bytes = await file.readAsBytes();
      final result = await importTimetableFile(
        ImportInput(fileName: file.name, bytes: bytes),
        semester: widget.store.semester,
      );
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _result = result;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败：$error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _import(CourseImportResult result) {
    final courses = <Course>[];
    final now = DateTime.now();
    for (var i = 0; i < result.courses.length; i++) {
      final draft = result.courses[i];
      courses.add(Course(
        id: 'imp-${now.microsecondsSinceEpoch}-$i',
        name: draft.name,
        teacher: draft.teacher,
        location: draft.location,
        note: draft.note,
        weekday: draft.weekday,
        startSection: draft.startSection,
        endSection: draft.endSection,
        weeks: List<int>.unmodifiable(draft.weeks),
        createdAt: now,
        colorIndex: draft.colorIndex,
      ));
    }
    final added = widget.store.importCourses(courses, replace: _replace);
    final message = _replace ? '已导入 $added 门课程' : '已新增 $added 门课程';
    // 先拿到根 ScaffoldMessenger，再关闭页面，避免用已销毁的 context 弹提示。
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static String _dateText(DateTime date) =>
      '${date.year}年${date.month}月${date.day}日';
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.draft, required this.isLast});

  final CourseDraft draft;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const weekdays = <String>['一', '二', '三', '四', '五', '六', '日'];
    final weeks = Course.compactWeeks(draft.weeks);
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: Course.palette[draft.colorIndex % Course.palette.length],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  draft.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '周${weekdays[draft.weekday - 1]} · 第${draft.startSection}-${draft.endSection}节 · $weeks'
                  '${draft.location.isEmpty ? '' : ' · ${draft.location}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
