import 'package:material_ui/material_ui.dart';

import '../models/semester.dart';
import '../state/course_store.dart';

Future<void> showSemesterSettings(BuildContext context, CourseStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SemesterSettingsSheet(store: store),
  );
}

class SemesterSettingsSheet extends StatefulWidget {
  const SemesterSettingsSheet({super.key, required this.store});

  final CourseStore store;

  @override
  State<SemesterSettingsSheet> createState() => _SemesterSettingsSheetState();
}

class _SemesterSettingsSheetState extends State<SemesterSettingsSheet> {
  late SemesterConfig _config;
  final TextEditingController _weeksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _config = widget.store.semester;
    _weeksController.text = '${_config.totalWeeks}';
  }

  @override
  void dispose() {
    _weeksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentWeek = _config.weekOf(now);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '学期设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentWeek >= 1 && currentWeek <= _config.totalWeeks
                    ? '今天是第 $currentWeek 周'
                    : '今天不在本学期的周次范围内，请检查开始日期。',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _SettingRow(
                label: '第 1 周周一',
                value: '${_config.startDate.year}年${_config.startDate.month}月${_config.startDate.day}日',
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text(
                    '总周数',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _weeksController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (value) {
                        final weeks = int.tryParse(value);
                        if (weeks != null && weeks >= 1 && weeks <= 30) {
                          setState(() => _config = _config.copyWith(totalWeeks: weeks));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _config.showWeekend,
                onChanged: (value) => setState(() {
                  _config = _config.copyWith(showWeekend: value);
                }),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text('显示周六、周日', style: TextStyle(fontSize: 12, color: scheme.onSurface)),
                subtitle: Text(
                  '周末没有课时建议关闭，界面更紧凑',
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      final monday = now.subtract(Duration(days: now.weekday - 1));
                      setState(() {
                        _config = _config.copyWith(
                          startDate: DateTime(monday.year, monday.month, monday.day),
                        );
                      });
                    },
                    child: const Text('本周设为第 1 周'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(100, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _config.startDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 3),
      helpText: '选择第 1 周周一',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null) return;
    // 把日期吸附到所在周的周一。
    final monday = picked.subtract(Duration(days: picked.weekday - 1));
    setState(() {
      _config = _config.copyWith(
        startDate: DateTime(monday.year, monday.month, monday.day),
      );
    });
  }

  void _save() {
    widget.store.setSemester(_config);
    Navigator.of(context).pop();
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 12, color: scheme.onSurface)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
