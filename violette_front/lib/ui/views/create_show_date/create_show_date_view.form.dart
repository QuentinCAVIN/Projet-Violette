// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String TitleValueKey = 'title';
const String DateValueKey = 'date';
const String StartTimeValueKey = 'startTime';
const String EndTimeValueKey = 'endTime';
const String ArtistsCountValueKey = 'artistsCount';
const String FeeValueKey = 'fee';
const String DescriptionValueKey = 'description';

final Map<String, TextEditingController>
    _CreateShowDateViewTextEditingControllers = {};

final Map<String, FocusNode> _CreateShowDateViewFocusNodes = {};

final Map<String, String? Function(String?)?>
    _CreateShowDateViewTextValidations = {
  TitleValueKey: null,
  DateValueKey: null,
  StartTimeValueKey: null,
  EndTimeValueKey: null,
  ArtistsCountValueKey: null,
  FeeValueKey: null,
  DescriptionValueKey: null,
};

mixin $CreateShowDateView {
  TextEditingController get titleController =>
      _getFormTextEditingController(TitleValueKey);
  TextEditingController get dateController =>
      _getFormTextEditingController(DateValueKey);
  TextEditingController get startTimeController =>
      _getFormTextEditingController(StartTimeValueKey);
  TextEditingController get endTimeController =>
      _getFormTextEditingController(EndTimeValueKey);
  TextEditingController get artistsCountController =>
      _getFormTextEditingController(ArtistsCountValueKey);
  TextEditingController get feeController =>
      _getFormTextEditingController(FeeValueKey);
  TextEditingController get descriptionController =>
      _getFormTextEditingController(DescriptionValueKey);

  FocusNode get titleFocusNode => _getFormFocusNode(TitleValueKey);
  FocusNode get dateFocusNode => _getFormFocusNode(DateValueKey);
  FocusNode get startTimeFocusNode => _getFormFocusNode(StartTimeValueKey);
  FocusNode get endTimeFocusNode => _getFormFocusNode(EndTimeValueKey);
  FocusNode get artistsCountFocusNode =>
      _getFormFocusNode(ArtistsCountValueKey);
  FocusNode get feeFocusNode => _getFormFocusNode(FeeValueKey);
  FocusNode get descriptionFocusNode => _getFormFocusNode(DescriptionValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_CreateShowDateViewTextEditingControllers.containsKey(key)) {
      return _CreateShowDateViewTextEditingControllers[key]!;
    }

    _CreateShowDateViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _CreateShowDateViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_CreateShowDateViewFocusNodes.containsKey(key)) {
      return _CreateShowDateViewFocusNodes[key]!;
    }
    _CreateShowDateViewFocusNodes[key] = FocusNode();
    return _CreateShowDateViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    titleController.addListener(() => _updateFormData(model));
    dateController.addListener(() => _updateFormData(model));
    startTimeController.addListener(() => _updateFormData(model));
    endTimeController.addListener(() => _updateFormData(model));
    artistsCountController.addListener(() => _updateFormData(model));
    feeController.addListener(() => _updateFormData(model));
    descriptionController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    titleController.addListener(() => _updateFormData(model));
    dateController.addListener(() => _updateFormData(model));
    startTimeController.addListener(() => _updateFormData(model));
    endTimeController.addListener(() => _updateFormData(model));
    artistsCountController.addListener(() => _updateFormData(model));
    feeController.addListener(() => _updateFormData(model));
    descriptionController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          TitleValueKey: titleController.text,
          DateValueKey: dateController.text,
          StartTimeValueKey: startTimeController.text,
          EndTimeValueKey: endTimeController.text,
          ArtistsCountValueKey: artistsCountController.text,
          FeeValueKey: feeController.text,
          DescriptionValueKey: descriptionController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (var controller in _CreateShowDateViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _CreateShowDateViewFocusNodes.values) {
      focusNode.dispose();
    }

    _CreateShowDateViewTextEditingControllers.clear();
    _CreateShowDateViewFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get titleValue => this.formValueMap[TitleValueKey] as String?;
  String? get dateValue => this.formValueMap[DateValueKey] as String?;
  String? get startTimeValue => this.formValueMap[StartTimeValueKey] as String?;
  String? get endTimeValue => this.formValueMap[EndTimeValueKey] as String?;
  String? get artistsCountValue =>
      this.formValueMap[ArtistsCountValueKey] as String?;
  String? get feeValue => this.formValueMap[FeeValueKey] as String?;
  String? get descriptionValue =>
      this.formValueMap[DescriptionValueKey] as String?;

  set titleValue(String? value) {
    this.setData(
      this.formValueMap..addAll({TitleValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(TitleValueKey)) {
      _CreateShowDateViewTextEditingControllers[TitleValueKey]?.text =
          value ?? '';
    }
  }

  set dateValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DateValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(DateValueKey)) {
      _CreateShowDateViewTextEditingControllers[DateValueKey]?.text =
          value ?? '';
    }
  }

  set startTimeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({StartTimeValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(
        StartTimeValueKey)) {
      _CreateShowDateViewTextEditingControllers[StartTimeValueKey]?.text =
          value ?? '';
    }
  }

  set endTimeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EndTimeValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(
        EndTimeValueKey)) {
      _CreateShowDateViewTextEditingControllers[EndTimeValueKey]?.text =
          value ?? '';
    }
  }

  set artistsCountValue(String? value) {
    this.setData(
      this.formValueMap..addAll({ArtistsCountValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(
        ArtistsCountValueKey)) {
      _CreateShowDateViewTextEditingControllers[ArtistsCountValueKey]?.text =
          value ?? '';
    }
  }

  set feeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({FeeValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(FeeValueKey)) {
      _CreateShowDateViewTextEditingControllers[FeeValueKey]?.text =
          value ?? '';
    }
  }

  set descriptionValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DescriptionValueKey: value}),
    );

    if (_CreateShowDateViewTextEditingControllers.containsKey(
        DescriptionValueKey)) {
      _CreateShowDateViewTextEditingControllers[DescriptionValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasTitle =>
      this.formValueMap.containsKey(TitleValueKey) &&
      (titleValue?.isNotEmpty ?? false);
  bool get hasDate =>
      this.formValueMap.containsKey(DateValueKey) &&
      (dateValue?.isNotEmpty ?? false);
  bool get hasStartTime =>
      this.formValueMap.containsKey(StartTimeValueKey) &&
      (startTimeValue?.isNotEmpty ?? false);
  bool get hasEndTime =>
      this.formValueMap.containsKey(EndTimeValueKey) &&
      (endTimeValue?.isNotEmpty ?? false);
  bool get hasArtistsCount =>
      this.formValueMap.containsKey(ArtistsCountValueKey) &&
      (artistsCountValue?.isNotEmpty ?? false);
  bool get hasFee =>
      this.formValueMap.containsKey(FeeValueKey) &&
      (feeValue?.isNotEmpty ?? false);
  bool get hasDescription =>
      this.formValueMap.containsKey(DescriptionValueKey) &&
      (descriptionValue?.isNotEmpty ?? false);

  bool get hasTitleValidationMessage =>
      this.fieldsValidationMessages[TitleValueKey]?.isNotEmpty ?? false;
  bool get hasDateValidationMessage =>
      this.fieldsValidationMessages[DateValueKey]?.isNotEmpty ?? false;
  bool get hasStartTimeValidationMessage =>
      this.fieldsValidationMessages[StartTimeValueKey]?.isNotEmpty ?? false;
  bool get hasEndTimeValidationMessage =>
      this.fieldsValidationMessages[EndTimeValueKey]?.isNotEmpty ?? false;
  bool get hasArtistsCountValidationMessage =>
      this.fieldsValidationMessages[ArtistsCountValueKey]?.isNotEmpty ?? false;
  bool get hasFeeValidationMessage =>
      this.fieldsValidationMessages[FeeValueKey]?.isNotEmpty ?? false;
  bool get hasDescriptionValidationMessage =>
      this.fieldsValidationMessages[DescriptionValueKey]?.isNotEmpty ?? false;

  String? get titleValidationMessage =>
      this.fieldsValidationMessages[TitleValueKey];
  String? get dateValidationMessage =>
      this.fieldsValidationMessages[DateValueKey];
  String? get startTimeValidationMessage =>
      this.fieldsValidationMessages[StartTimeValueKey];
  String? get endTimeValidationMessage =>
      this.fieldsValidationMessages[EndTimeValueKey];
  String? get artistsCountValidationMessage =>
      this.fieldsValidationMessages[ArtistsCountValueKey];
  String? get feeValidationMessage =>
      this.fieldsValidationMessages[FeeValueKey];
  String? get descriptionValidationMessage =>
      this.fieldsValidationMessages[DescriptionValueKey];
}

extension Methods on FormStateHelper {
  setTitleValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[TitleValueKey] = validationMessage;
  setDateValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DateValueKey] = validationMessage;
  setStartTimeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[StartTimeValueKey] = validationMessage;
  setEndTimeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EndTimeValueKey] = validationMessage;
  setArtistsCountValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[ArtistsCountValueKey] = validationMessage;
  setFeeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[FeeValueKey] = validationMessage;
  setDescriptionValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DescriptionValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    titleValue = '';
    dateValue = '';
    startTimeValue = '';
    endTimeValue = '';
    artistsCountValue = '';
    feeValue = '';
    descriptionValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      TitleValueKey: getValidationMessage(TitleValueKey),
      DateValueKey: getValidationMessage(DateValueKey),
      StartTimeValueKey: getValidationMessage(StartTimeValueKey),
      EndTimeValueKey: getValidationMessage(EndTimeValueKey),
      ArtistsCountValueKey: getValidationMessage(ArtistsCountValueKey),
      FeeValueKey: getValidationMessage(FeeValueKey),
      DescriptionValueKey: getValidationMessage(DescriptionValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _CreateShowDateViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _CreateShowDateViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      TitleValueKey: getValidationMessage(TitleValueKey),
      DateValueKey: getValidationMessage(DateValueKey),
      StartTimeValueKey: getValidationMessage(StartTimeValueKey),
      EndTimeValueKey: getValidationMessage(EndTimeValueKey),
      ArtistsCountValueKey: getValidationMessage(ArtistsCountValueKey),
      FeeValueKey: getValidationMessage(FeeValueKey),
      DescriptionValueKey: getValidationMessage(DescriptionValueKey),
    });
