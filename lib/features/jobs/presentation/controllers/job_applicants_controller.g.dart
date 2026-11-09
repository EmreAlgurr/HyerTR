// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_applicants_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobApplicantsController)
final jobApplicantsControllerProvider = JobApplicantsControllerFamily._();

final class JobApplicantsControllerProvider extends $AsyncNotifierProvider<
    JobApplicantsController, List<ApplicationModel>> {
  JobApplicantsControllerProvider._(
      {required JobApplicantsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'jobApplicantsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobApplicantsControllerHash();

  @override
  String toString() {
    return r'jobApplicantsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JobApplicantsController create() => JobApplicantsController();

  @override
  bool operator ==(Object other) {
    return other is JobApplicantsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobApplicantsControllerHash() =>
    r'029556d2f4d14fd1ad222f1ef1d170920646b287';

final class JobApplicantsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            JobApplicantsController,
            AsyncValue<List<ApplicationModel>>,
            List<ApplicationModel>,
            FutureOr<List<ApplicationModel>>,
            String> {
  JobApplicantsControllerFamily._()
      : super(
          retry: null,
          name: r'jobApplicantsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  JobApplicantsControllerProvider call(
    String jobId,
  ) =>
      JobApplicantsControllerProvider._(argument: jobId, from: this);

  @override
  String toString() => r'jobApplicantsControllerProvider';
}

abstract class _$JobApplicantsController
    extends $AsyncNotifier<List<ApplicationModel>> {
  late final _$args = ref.$arg as String;
  String get jobId => _$args;

  FutureOr<List<ApplicationModel>> build(
    String jobId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<ApplicationModel>>, List<ApplicationModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ApplicationModel>>, List<ApplicationModel>>,
        AsyncValue<List<ApplicationModel>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
