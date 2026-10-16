import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Asks for a UTC date and time. Both fields are text fields that select
/// their content when focused, so a value can be typed over at once; the
/// calendar and the clock are one tap away for those who prefer them.
///
/// Returns null if cancelled. [latest] is the newest date that is accepted.
Future<UtcDateTime?> showUtcDateTimeDialog(
  BuildContext context, {
  required UtcDateTime initial,
  required DateTime latest,
}) => showDialog<UtcDateTime>(
  context: context,
  builder: (context) => _UtcDateTimeDialog(initial: initial, latest: latest),
);

/// The digits of [text] only.
String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');

String _two(int n) => n.toString().padLeft(2, '0');

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

class _UtcDateTimeDialog extends StatefulWidget {
  const new({required this.initial, required this.latest});

  final UtcDateTime initial;
  final DateTime latest;

  @override
  State<_UtcDateTimeDialog> createState() => _UtcDateTimeDialogState();
}

class _UtcDateTimeDialogState extends State<_UtcDateTimeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  late final TextEditingController _date;
  late final TextEditingController _time;
  late String _lastDate;

  @override
  void initState() {
    super.initState();
    final t = widget.initial.value;
    _date = TextEditingController(text: _isoDate(t));
    _lastDate = _date.text;
    _time = TextEditingController(text: '${_two(t.hour)}:${_two(t.minute)}');
    _selectAllOnFocus(_dateFocus, _date);
    _selectAllOnFocus(_timeFocus, _time);
  }

  @override
  void dispose() {
    _dateFocus.dispose();
    _timeFocus.dispose();
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  void _selectAllOnFocus(FocusNode focus, TextEditingController controller) {
    focus.addListener(() {
      if (!focus.hasFocus) return;
      // After the field has placed its own cursor.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !focus.hasFocus) return;
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      });
    });
  }

  /// The date typed, or null if it is not a real date.
  UtcDateTime? get _typedDate =>
      UtcDateTime.tryParseAdif(_digits(_date.text), '000000');

  /// `HHMM` of the time typed (three digits count as `HMM`), or null.
  String? get _typedClock {
    var digits = _digits(_time.text);
    if (digits.length == 3) digits = '0$digits';
    return digits.length == 4 ? digits : null;
  }

  String? _validateDate(AppLocalizations l10n) {
    final date = _typedDate;
    if (date == null) return l10n.dateInvalid;
    return date.value.isAfter(widget.latest) ? l10n.dateInFuture : null;
  }

  String? _validateTime(AppLocalizations l10n) {
    final clock = _typedClock;
    if (clock == null) return l10n.timeInvalid;
    return UtcDateTime.tryParseAdif('20000101', '${clock}00') == null
        ? l10n.timeInvalid
        : null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = UtcDateTime.tryParseAdif(
      _digits(_date.text),
      '${_typedClock!}00',
    );
    if (value != null) Navigator.of(context).pop(value);
  }

  void _dateChanged(String after) {
    // Jump to the time once the eighth digit is typed (or the whole date is
    // replaced), but not while a digit in the middle of a date is corrected.
    final atEnd = _date.selection.extentOffset == after.length;
    if (_digits(after).length == 8 && atEnd && after != _lastDate) {
      _timeFocus.requestFocus();
    }
    _lastDate = after;
  }

  Future<void> _pickDate() async {
    final current = _typedDate ?? widget.initial;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.value.isAfter(widget.latest)
          ? widget.latest
          : current.value,
      firstDate: DateTime.utc(1930),
      lastDate: widget.latest,
    );
    if (picked == null || !mounted) return;
    _date.text = _isoDate(picked);
    _lastDate = _date.text;
    _formKey.currentState?.validate();
    _timeFocus.requestFocus();
  }

  Future<void> _pickTime() async {
    final clock = _typedClock;
    final picked = await showTimePicker(
      context: context,
      initialTime: clock == null
          ? TimeOfDay(
              hour: widget.initial.value.hour,
              minute: widget.initial.value.minute,
            )
          : TimeOfDay(
              hour: int.parse(clock.substring(0, 2)).clamp(0, 23),
              minute: int.parse(clock.substring(2)).clamp(0, 59),
            ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    _time.text = '${_two(picked.hour)}:${_two(picked.minute)}';
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    return AlertDialog(
      title: Text(l10n.dateTimeDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _date,
                focusNode: _dateFocus,
                autofocus: true,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: l10n.dateUtcLabel,
                  hintText: l10n.dateFormatHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    tooltip: l10n.pickDate,
                    onPressed: _pickDate,
                  ),
                ),
                validator: (_) => _validateDate(l10n),
                onChanged: _dateChanged,
                onFieldSubmitted: (_) => _timeFocus.requestFocus(),
              ),
              SizedBox(height: metrics.md),
              TextFormField(
                controller: _time,
                focusNode: _timeFocus,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: l10n.timeUtcLabel,
                  hintText: l10n.timeFormatHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    tooltip: l10n.pickTime,
                    onPressed: _pickTime,
                  ),
                ),
                validator: (_) => _validateTime(l10n),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.dateTimeDialogSet)),
      ],
    );
  }
}
