import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

/// Custom checkbox with label
class CustomCheckbox extends StatelessWidget {
  final String? label;
  final String? description;
  final bool value;
  final bool enabled;
  final void Function(bool)? onChanged;
  final Widget? leading;
  final CrossAxisAlignment alignment;

  const CustomCheckbox({
    super.key,
    this.label,
    this.description,
    required this.value,
    this.enabled = true,
    this.onChanged,
    this.leading,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: alignment,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            _CheckboxIcon(
              value: value,
              enabled: enabled,
            ),
            if (label != null || description != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom checkbox icon widget
class _CheckboxIcon extends StatelessWidget {
  final bool value;
  final bool enabled;

  const _CheckboxIcon({
    required this.value,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value
              ? AppColors.primary
              : enabled
                  ? AppColors.border
                  : AppColors.textHint,
          width: 2,
        ),
      ),
      child: value
          ? const Icon(
              Icons.check,
              size: 18,
              color: AppColors.textOnPrimary,
            )
          : null,
    );
  }
}

/// Checkbox group for multiple selections
class CheckboxGroup<T> extends StatelessWidget {
  final String? label;
  final String? errorText;
  final List<CheckboxOption<T>> options;
  final List<T> selectedValues;
  final void Function(List<T>)? onChanged;
  final String? Function(List<T>)? validator;
  final bool enabled;
  final double spacing;

  const CheckboxGroup({
    super.key,
    this.label,
    this.errorText,
    required this.options,
    required this.selectedValues,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
      initialValue: selectedValues,
      validator: (_) => validator?.call(selectedValues),
      builder: (FormFieldState<List<T>> state) {
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
            ...options.map((option) {
              final isSelected = selectedValues.contains(option.value);
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: CustomCheckbox(
                  label: option.label,
                  description: option.description,
                  value: isSelected,
                  enabled: enabled && !option.disabled,
                  onChanged: (checked) {
                    final newValues = List<T>.from(selectedValues);
                    if (checked) {
                      newValues.add(option.value);
                    } else {
                      newValues.remove(option.value);
                    }
                    state.didChange(newValues);
                    onChanged?.call(newValues);
                  },
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

/// Checkbox option data class
class CheckboxOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const CheckboxOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

/// Simple string-based checkbox group
class SimpleCheckboxGroup extends StatelessWidget {
  final String? label;
  final String? errorText;
  final List<String> options;
  final List<String> selectedValues;
  final void Function(List<String>)? onChanged;
  final String? Function(List<String>)? validator;
  final bool enabled;

  const SimpleCheckboxGroup({
    super.key,
    this.label,
    this.errorText,
    required this.options,
    required this.selectedValues,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxGroup<String>(
      label: label,
      errorText: errorText,
      options: options
          .map((opt) => CheckboxOption(value: opt, label: opt))
          .toList(),
      selectedValues: selectedValues,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }
}

/// Terms and conditions checkbox
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final String? termsText;
  final VoidCallback? onTermsTap;
  final String? errorText;

  const TermsCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.termsText,
    this.onTermsTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged?.call(!value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckboxIcon(value: value, enabled: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: onTermsTap,
                            child: Text(
                              termsText ?? 'Terms and Conditions',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 36),
            child: Text(
              errorText!,
              style: AppTextStyles.inputError,
            ),
          ),
      ],
    );
  }
}

/// Card-style checkbox for prominent selections
class CardCheckbox extends StatelessWidget {
  final String label;
  final String? description;
  final IconData? icon;
  final bool value;
  final bool enabled;
  final void Function(bool)? onChanged;

  const CardCheckbox({
    super.key,
    required this.label,
    this.description,
    this.icon,
    required this.value,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primaryLight.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: value ? AppColors.primary : AppColors.iconSecondary,
                size: 28,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CheckboxIcon(value: value, enabled: enabled),
          ],
        ),
      ),
    );
  }
}
