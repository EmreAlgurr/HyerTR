// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobDetailController)
final jobDetailControllerProvider = JobDetailControllerFamily._();

final class JobDetailControllerProvider
    extends $AsyncNotifierProvider<JobDetailController, String?> {
  JobDetailControllerProvider._(
      {required JobDetailControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'jobDetailControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobDetailControllerHash();

  @override
  String toString() {
    return r'jobDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JobDetailController create() => JobDetailController();

  @override
  bool operator ==(Object other) {
    return other is JobDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobDetailControllerHash() =>
    r'ccc8df03ec9ca349977efc875cebf23013b3d5c7';

final class JobDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<JobDetailController, AsyncValue<String?>, String?,
            FutureOr<String?>, String> {
  JobDetailControllerFamily._()
      : super(
          retry: null,
          name: r'jobDetailControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  JobDetailControllerProvider call(
    String jobId,
  ) =>
      JobDetailControllerProvider._(argument: jobId, from: this);

  @override
  String toString() => r'jobDetailControllerProvider';
}

abstract class _$JobDetailController extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as String;
  String get jobId => _$args;

  FutureOr<String?> build(
    String jobId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String?>, String?>,
        AsyncValue<String?>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
