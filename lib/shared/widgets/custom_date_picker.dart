import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../core/utils/date_utils.dart';

class CustomDatePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final bool enabled;
  final void Function(DateTime)? onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateFormat? displayFormat;

  const CustomDatePicker({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.enabled = true,
    this.onDateSelected,
    this.validator,
    this.displayFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 8),
        ],
        FormField<DateTime>(
          initialValue: selectedDate,
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: enabled
                      ? () => _showDatePicker(context, state)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.surface : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.hasError
                            ? AppColors.error
                            : errorText != null
                                ? AppColors.error
                                : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.iconSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? _formatDate(selectedDate!)
                                : hint ?? 'Select date',
                            style: selectedDate != null
                                ? AppTextStyles.inputText
                                : AppTextStyles.inputHint,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.iconSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError || errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      errorText ?? state.errorText ?? '',
                      style: AppTextStyles.inputError,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    if (displayFormat != null) {
      return displayFormat!.format(date);
    }
    return AppDateUtils.formatDate(date);
  }

  Future<void> _showDatePicker(
    BuildContext context,
    FormFieldState<DateTime> state,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate ?? now,
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      state.didChange(picked);
      onDateSelected?.call(picked);
    }
  }
}

/// Date of Birth Picker with age calculation
class DateOfBirthPicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final DateTime? selectedDate;
  final bool enabled;
  final bool showAge;
  final int minAge;
  final int maxAge;
  final void Function(DateTime)? onDateSelected;
  final String? Function(DateTime?)? validator;

  const DateOfBirthPicker({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.selectedDate,
    this.enabled = true,
    this.showAge = true,
    this.minAge = 18,
    this.maxAge = 100,
    this.onDateSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomDatePicker(
          label: label ?? 'Date of Birth',
          hint: hint ?? 'Select your date of birth',
          errorText: errorText,
          selectedDate: selectedDate,
          enabled: enabled,
          firstDate: DateTime(now.year - maxAge),
          lastDate: DateTime(now.year - minAge, now.month, now.day),
          initialDate: DateTime(now.year - minAge),
          onDateSelected: onDateSelected,
          validator: validator ?? _validateAge,
        ),
        if (showAge && selectedDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Age: ${AppDateUtils.calculateAge(selectedDate!)} years',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  String? _validateAge(DateTime? date) {
    if (date == null) {
      return 'Date of birth is required';
    }
    final age = AppDateUtils.calculateAge(date);
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    if (age > maxAge) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }
}

/// Date Range Picker
class CustomDateRangePicker extends StatelessWidget {
  final String? label;
  final String? startHint;
  final String? endHint;
  final String? errorText;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final void Function(DateTime start, DateTime end)? onDateRangeSelected;

  const CustomDateRangePicker({
    super.key,
    this.label,
    this.startHint,
    this.endHint,
    this.errorText,
    this.startDate,
    this.endDate,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: enabled ? () => _showDateRangePicker(context) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_outlined,
                  color: AppColors.iconSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: (startDate != null && endDate != null)
                        ? AppTextStyles.inputText
                        : AppTextStyles.inputHint,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.iconSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: AppTextStyles.inputError,
            ),
          ),
      ],
    );
  }

  String _getDisplayText() {
    if (startDate != null && endDate != null) {
      return '${AppDateUtils.formatDayMonth(startDate)} - ${AppDateUtils.formatDayMonth(endDate)}';
    }
    return '${startHint ?? 'Start'} - ${endHint ?? 'End'}';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(now.year + 10),
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected?.call(picked.start, picked.end);
    }
  }
}

/// Type alias for compatibility with intl package
typedef DateFormat = dynamic;
