import 'package:flutter/material.dart';

/// Style for a specific day in the [PCalendar].
class PCalendarDayStyle {
  const PCalendarDayStyle({
    this.backgroundColor,
    this.textStyle,
    this.border,
  });

  /// Background color of the day cell.
  final Color? backgroundColor;

  /// Text style for the day number.
  final TextStyle? textStyle;

  /// Border for the day cell.
  final BoxBorder? border;
}

/// Controller to manage the state of the [PCalendar] widget.
class PCalendarController extends ChangeNotifier {
  PCalendarController({
    required DateTime initialDate,
  }) {
    _currentMonth = DateTime(initialDate.year, initialDate.month);
    _selectedDate = initialDate;
  }

  late DateTime _currentMonth;
  DateTime? _selectedDate;

  DateTime get currentMonth => _currentMonth;
  DateTime? get selectedDate => _selectedDate;

  /// Moves the calendar to the next month.
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    notifyListeners();
  }

  /// Moves the calendar to the previous month.
  void prevMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    notifyListeners();
  }

  /// Sets the current month to show.
  void setMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  /// Sets the selected date.
  void selectDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }
}

/// A monthly calendar widget that displays days in a grid view.
class PCalendar extends StatefulWidget {
  const PCalendar({
    required this.initialDate,
    super.key,
    this.controller,
    this.onDateSelected,
    this.onMonthChanged,
    this.dayStyleBuilder,
    this.highlightedDates,
    this.highlightColor,
    this.highlightTextStyle,
    this.monthTextStyle,
    this.weekdayTextStyle,
    this.dayTextStyle,
    this.selectedColor,
    this.todayColor,
    this.backgroundColor,
    this.borderRadius = 4.0,
    this.compact = true,
  });

  /// The initial date to display and select.
  final DateTime initialDate;

  /// Optional controller to manage the calendar state.
  final PCalendarController? controller;

  /// Callback when a date is selected.
  final Function(DateTime)? onDateSelected;

  /// Callback when the month is changed.
  final Function(DateTime)? onMonthChanged;

  /// A function that returns a custom style for a specific day.
  /// If this is provided, [highlightedDates] and [highlightColor] will be ignored for matching dates.
  final PCalendarDayStyle? Function(DateTime date)? dayStyleBuilder;

  /// A list of dates to highlight in the calendar (deprecated in favor of `dayStyleBuilder`).
  final List<DateTime>? highlightedDates;

  /// Color for the highlighted dates background.
  final Color? highlightColor;

  /// Style for the highlighted dates numbers.
  final TextStyle? highlightTextStyle;

  /// Style for the month/year title.
  final TextStyle? monthTextStyle;

  /// Style for the weekday labels (Mon, Tue, etc.).
  final TextStyle? weekdayTextStyle;

  /// Style for the day numbers.
  final TextStyle? dayTextStyle;

  /// Color for the selected day background.
  final Color? selectedColor;

  /// Color for the today indicator.
  final Color? todayColor;

  /// Background color of the calendar.
  final Color? backgroundColor;

  /// Border radius for the calendar days.
  final double borderRadius;

  /// If true, reduces sizes and padding to the minimum.
  final bool compact;

  @override
  State<PCalendar> createState() => _PCalendarState();
}

class _PCalendarState extends State<PCalendar> {
  late PCalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PCalendarController(initialDate: widget.initialDate);
    _controller.addListener(_handleControllerUpdate);
  }

  @override
  void didUpdateWidget(PCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerUpdate);
      _controller = widget.controller ?? PCalendarController(initialDate: widget.initialDate);
      _controller.addListener(_handleControllerUpdate);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleControllerUpdate);
    }
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _nextMonth() {
    _controller.nextMonth();
    widget.onMonthChanged?.call(_controller.currentMonth);
  }

  void _prevMonth() {
    _controller.prevMonth();
    widget.onMonthChanged?.call(_controller.currentMonth);
  }

  bool _isHighlighted(DateTime date) {
    if (widget.highlightedDates == null) return false;
    for (final hDate in widget.highlightedDates!) {
      if (hDate.year == date.year && hDate.month == date.month && hDate.day == date.day) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final todayColor = widget.todayColor ?? colorScheme.secondary;
    final defaultHighlightColor = widget.highlightColor ?? colorScheme.primaryContainer.withValues(alpha: 0.4);

    final weekdayLabels = widget.compact
        ? ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    final currentMonth = _controller.currentMonth;

    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month);

    final startingWeekday = firstDayOfMonth.weekday;
    final leadingEmptyCells = startingWeekday - 1;

    final today = DateTime.now();

    final double padding = widget.compact ? 4.0 : 16.0;
    final double headerSpacing = widget.compact ? 4.0 : 16.0;
    final double gridSpacing = widget.compact ? 2.0 : 8.0;
    final double monthFontSize = widget.compact ? 12.0 : 18.0;
    final double weekdayFontSize = widget.compact ? 10.0 : 12.0;
    final double dayFontSize = widget.compact ? 10.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.compact ? 6 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(Icons.chevron_left, _prevMonth),
              Text(
                '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                style: widget.monthTextStyle ??
                    TextStyle(
                      fontSize: monthFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              _buildNavButton(Icons.chevron_right, _nextMonth),
            ],
          ),
          SizedBox(height: headerSpacing),
          // Weekday Labels
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: weekdayLabels.map((label) {
              return Center(
                child: Text(
                  label,
                  style: widget.weekdayTextStyle ??
                      TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: weekdayFontSize,
                      ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: gridSpacing),
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: gridSpacing,
              crossAxisSpacing: gridSpacing,
            ),
            itemCount: leadingEmptyCells + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingEmptyCells) {
                return const SizedBox.shrink();
              }

              final day = index - leadingEmptyCells + 1;
              final date = DateTime(
                currentMonth.year,
                currentMonth.month,
                day,
              );

              final selectedDate = _controller.selectedDate;
              final isSelected = selectedDate != null &&
                  selectedDate.year == date.year &&
                  selectedDate.month == date.month &&
                  selectedDate.day == date.day;

              final isToday = today.year == date.year &&
                  today.month == date.month &&
                  today.day == date.day;

              // Priority: Custom Builder -> HighlightedDates list
              final customStyle = widget.dayStyleBuilder?.call(date);
              final isHighlighted = customStyle != null || _isHighlighted(date);

              // Background Color determination
              Color? backgroundColor;
              if (isSelected) {
                backgroundColor = selectedColor;
              } else if (customStyle?.backgroundColor != null) {
                backgroundColor = customStyle!.backgroundColor;
              } else if (_isHighlighted(date)) {
                backgroundColor = defaultHighlightColor;
              } else if (isToday) {
                backgroundColor = todayColor.withValues(alpha: 0.1);
              } else {
                backgroundColor = Colors.transparent;
              }

              // Text Style determination
              TextStyle? textStyle;
              if (isSelected) {
                textStyle = (widget.dayTextStyle?.copyWith(color: colorScheme.onPrimary) ??
                    TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold));
              } else if (customStyle?.textStyle != null) {
                textStyle = customStyle!.textStyle;
              } else if (_isHighlighted(date)) {
                textStyle = widget.highlightTextStyle;
              } else if (isToday) {
                textStyle = widget.dayTextStyle?.copyWith(color: todayColor);
              } else {
                textStyle = widget.dayTextStyle;
              }

              // Final Fallback for Color and Weight
              textStyle = (textStyle ?? const TextStyle()).copyWith(
                fontSize: dayFontSize,
                color: isSelected
                    ? colorScheme.onPrimary
                    : (textStyle?.color ?? (isToday ? todayColor : colorScheme.onSurface)),
                fontWeight: textStyle?.fontWeight ?? (isSelected || isToday || isHighlighted
                    ? FontWeight.bold
                    : FontWeight.w500),
              );

              return InkWell(
                onTap: () {
                  _controller.selectDate(date);
                  widget.onDateSelected?.call(date);
                },
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: customStyle?.border ?? (isToday && !isSelected
                        ? Border.all(
                            color: todayColor,
                            width: widget.compact ? 0.5 : 2,
                          )
                        : null),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: textStyle,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    final double iconSize = widget.compact ? 14 : 20;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(widget.compact ? 2 : 8),
          child: Icon(icon, size: iconSize),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    String name = months[month - 1];
    if (widget.compact) {
      if (name.length > 4) return '${name.substring(0, 3)}.';
    }
    return name;
  }
}
