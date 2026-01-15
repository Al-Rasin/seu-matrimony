import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  final String? label;
  final String? errorText;
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Axis direction;
  final bool enabled;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomRadioGroup({
    super.key,
    this.label,
    this.errorText,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.direction = Axis.vertical,
    this.enabled = true,
    this.spacing = 8,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: selectedValue,
      validator: validator,
      builder: (FormFieldState<T> state) {
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
            direction == Axis.vertical
                ? Column(
                    crossAxisAlignment: crossAxisAlignment,
                    children: _buildOptions(state),
                  )
                : Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: _buildOptions(state),
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
    );
  }

  List<Widget> _buildOptions(FormFieldState<T> state) {
    return options.map((option) {
      final isSelected = selectedValue == option.value;
      return Padding(
        padding: direction == Axis.vertical
            ? EdgeInsets.only(bottom: spacing)
            : EdgeInsets.zero,
        child: InkWell(
          onTap: enabled && !option.disabled
              ? () {
                  state.didChange(option.value);
                  onChanged?.call(option.value);
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomRadio<T>(
                value: option.value,
                groupValue: selectedValue,
                onChanged: enabled && !option.disabled
                    ? (value) {
                        state.didChange(value);
                        onChanged?.call(value);
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: enabled && !option.disabled
                            ? isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    if (option.description != null)
                      Text(
                        option.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

/// Custom radio widget to avoid deprecation warnings
class _CustomRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final void Function(T?)? onChanged;

  const _CustomRadio({
    required this.value,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(value) : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Radio option data class
class RadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const RadioOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

/// Radio group with card-style options
class CardRadioGroup<T> extends StatelessWidget {
  final String? label;
  final String? errorText;
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const CardRadioGroup({
    super.key,
    this.label,
    this.errorText,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: selectedValue,
      validator: validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: AppTextStyles.inputLabel,
              ),
              const SizedBox(height: 12),
            ],
            ...options.map((option) {
              final isSelected = selectedValue == option.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: enabled && !option.disabled
                      ? () {
                          state.didChange(option.value);
                          onChanged?.call(option.value);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.textOnPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: enabled && !option.disabled
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                              if (option.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  option.description!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (state.hasError || errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  errorText ?? state.errorText ?? '',
                  style: AppTextStyles.inputError,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Simple string-based radio group for common use cases
class SimpleRadioGroup extends StatelessWidget {
  final String? label;
  final String? errorText;
  final List<String> options;
  final String? selectedValue;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Axis direction;
  final bool enabled;

  const SimpleRadioGroup({
    super.key,
    this.label,
    this.errorText,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.direction = Axis.vertical,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRadioGroup<String>(
      label: label,
      errorText: errorText,
      options: options
          .map((opt) => RadioOption(value: opt, label: opt))
          .toList(),
      selectedValue: selectedValue,
      onChanged: onChanged,
      validator: validator,
      direction: direction,
      enabled: enabled,
    );
  }
}

/// Gender selection radio group
class GenderRadioGroup extends StatelessWidget {
  final String? label;
  final String? errorText;
  final String? selectedValue;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Axis direction;
  final bool enabled;

  const GenderRadioGroup({
    super.key,
    this.label,
    this.errorText,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.direction = Axis.horizontal,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRadioGroup<String>(
      label: label ?? 'Gender',
      errorText: errorText,
      options: const [
        RadioOption(value: 'male', label: 'Male'),
        RadioOption(value: 'female', label: 'Female'),
      ],
      selectedValue: selectedValue,
      onChanged: onChanged,
      validator: validator ?? _validateGender,
      direction: direction,
      enabled: enabled,
    );
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }
}
