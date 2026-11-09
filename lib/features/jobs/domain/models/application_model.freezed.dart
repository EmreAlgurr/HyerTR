// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApplicationModel _$ApplicationModelFromJson(Map<String, dynamic> json) {
  return _ApplicationModel.fromJson(json);
}

/// @nodoc
mixin _$ApplicationModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tasker_id')
  String get tasker_id => throw _privateConstructorUsedError;
  ApplicationStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Joined data
  @JsonKey(name: 'tasker_name')
  String? get taskerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'tasker_avatar')
  String? get taskerAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_title')
  String? get jobTitle => throw _privateConstructorUsedError;

  /// Serializes this ApplicationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApplicationModelCopyWith<ApplicationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationModelCopyWith<$Res> {
  factory $ApplicationModelCopyWith(
          ApplicationModel value, $Res Function(ApplicationModel) then) =
      _$ApplicationModelCopyWithImpl<$Res, ApplicationModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'tasker_id') String tasker_id,
      ApplicationStatus status,
      String? message,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'tasker_name') String? taskerName,
      @JsonKey(name: 'tasker_avatar') String? taskerAvatar,
      @JsonKey(name: 'job_title') String? jobTitle});
}

/// @nodoc
class _$ApplicationModelCopyWithImpl<$Res, $Val extends ApplicationModel>
    implements $ApplicationModelCopyWith<$Res> {
  _$ApplicationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? tasker_id = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? taskerName = freezed,
    Object? taskerAvatar = freezed,
    Object? jobTitle = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      tasker_id: null == tasker_id
          ? _value.tasker_id
          : tasker_id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      taskerName: freezed == taskerName
          ? _value.taskerName
          : taskerName // ignore: cast_nullable_to_non_nullable
              as String?,
      taskerAvatar: freezed == taskerAvatar
          ? _value.taskerAvatar
          : taskerAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApplicationModelImplCopyWith<$Res>
    implements $ApplicationModelCopyWith<$Res> {
  factory _$$ApplicationModelImplCopyWith(_$ApplicationModelImpl value,
          $Res Function(_$ApplicationModelImpl) then) =
      __$$ApplicationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'tasker_id') String tasker_id,
      ApplicationStatus status,
      String? message,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'tasker_name') String? taskerName,
      @JsonKey(name: 'tasker_avatar') String? taskerAvatar,
      @JsonKey(name: 'job_title') String? jobTitle});
}

/// @nodoc
class __$$ApplicationModelImplCopyWithImpl<$Res>
    extends _$ApplicationModelCopyWithImpl<$Res, _$ApplicationModelImpl>
    implements _$$ApplicationModelImplCopyWith<$Res> {
  __$$ApplicationModelImplCopyWithImpl(_$ApplicationModelImpl _value,
      $Res Function(_$ApplicationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? tasker_id = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? taskerName = freezed,
    Object? taskerAvatar = freezed,
    Object? jobTitle = freezed,
  }) {
    return _then(_$ApplicationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      tasker_id: null == tasker_id
          ? _value.tasker_id
          : tasker_id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      taskerName: freezed == taskerName
          ? _value.taskerName
          : taskerName // ignore: cast_nullable_to_non_nullable
              as String?,
      taskerAvatar: freezed == taskerAvatar
          ? _value.taskerAvatar
          : taskerAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApplicationModelImpl implements _ApplicationModel {
  const _$ApplicationModelImpl(
      {required this.id,
      @JsonKey(name: 'job_id') required this.jobId,
      @JsonKey(name: 'tasker_id') required this.tasker_id,
      required this.status,
      this.message,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'tasker_name') this.taskerName,
      @JsonKey(name: 'tasker_avatar') this.taskerAvatar,
      @JsonKey(name: 'job_title') this.jobTitle});

  factory _$ApplicationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApplicationModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  @JsonKey(name: 'tasker_id')
  final String tasker_id;
  @override
  final ApplicationStatus status;
  @override
  final String? message;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
// Joined data
  @override
  @JsonKey(name: 'tasker_name')
  final String? taskerName;
  @override
  @JsonKey(name: 'tasker_avatar')
  final String? taskerAvatar;
  @override
  @JsonKey(name: 'job_title')
  final String? jobTitle;

  @override
  String toString() {
    return 'ApplicationModel(id: $id, jobId: $jobId, tasker_id: $tasker_id, status: $status, message: $message, createdAt: $createdAt, taskerName: $taskerName, taskerAvatar: $taskerAvatar, jobTitle: $jobTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplicationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.tasker_id, tasker_id) ||
                other.tasker_id == tasker_id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.taskerName, taskerName) ||
                other.taskerName == taskerName) &&
            (identical(other.taskerAvatar, taskerAvatar) ||
                other.taskerAvatar == taskerAvatar) &&
            (identical(other.jobTitle, jobTitle) ||
                other.jobTitle == jobTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, jobId, tasker_id, status,
      message, createdAt, taskerName, taskerAvatar, jobTitle);

  /// Create a copy of ApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplicationModelImplCopyWith<_$ApplicationModelImpl> get copyWith =>
      __$$ApplicationModelImplCopyWithImpl<_$ApplicationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApplicationModelImplToJson(
      this,
    );
  }
}

abstract class _ApplicationModel implements ApplicationModel {
  const factory _ApplicationModel(
          {required final String id,
          @JsonKey(name: 'job_id') required final String jobId,
          @JsonKey(name: 'tasker_id') required final String tasker_id,
          required final ApplicationStatus status,
          final String? message,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'tasker_name') final String? taskerName,
          @JsonKey(name: 'tasker_avatar') final String? taskerAvatar,
          @JsonKey(name: 'job_title') final String? jobTitle}) =
      _$ApplicationModelImpl;

  factory _ApplicationModel.fromJson(Map<String, dynamic> json) =
      _$ApplicationModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  @JsonKey(name: 'tasker_id')
  String get tasker_id;
  @override
  ApplicationStatus get status;
  @override
  String? get message;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Joined data
  @override
  @JsonKey(name: 'tasker_name')
  String? get taskerName;
  @override
  @JsonKey(name: 'tasker_avatar')
  String? get taskerAvatar;
  @override
  @JsonKey(name: 'job_title')
  String? get jobTitle;

  /// Create a copy of ApplicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApplicationModelImplCopyWith<_$ApplicationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
