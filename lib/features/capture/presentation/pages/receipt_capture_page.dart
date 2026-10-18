import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/platform/platform_activity_indicator.dart';
import '../../../../shared/widgets/platform/platform_app_bar.dart';
import '../../domain/entities/capture_review_request.dart';
import '../../domain/entities/receipt_capture_failure.dart';
import '../../domain/entities/receipt_capture_outcome.dart';
import '../../domain/entities/receipt_image_source.dart';
import '../controller/start_receipt_capture/start_receipt_capture_cubit.dart';
import 'capture_review_page.dart';

class ReceiptCapturePage extends StatelessWidget {
  const ReceiptCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartReceiptCaptureCubit, StartReceiptCaptureState>(
      listener: _onState,
      builder: (BuildContext context, StartReceiptCaptureState state) {
        final bool loading = state.isLoading;
        final bool readFailed =
            state is ApiCallError<ReceiptCaptureOutcome> &&
            state.message == ReceiptCaptureFailure.readFailed;
        return Scaffold(
          appBar: PlatformAppBar(
            title: Text(
              Strings.fenzoReceipt,
              style: TextStyles.of(size: 18, weight: TextStyles.semibold),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppElevatedButton(
                  key: const Key('receipt-take-photo'),
                  text: Strings.fenzoReceiptTakePhoto,
                  enabled: !loading,
                  onPressed: () => _start(context, ReceiptImageSource.camera),
                ),
                SizedBox(height: 12.h),
                AppElevatedButton(
                  key: const Key('receipt-choose-photo'),
                  text: Strings.fenzoReceiptChoosePhoto,
                  enabled: !loading,
                  onPressed: () => _start(context, ReceiptImageSource.gallery),
                ),
                if (loading) ...<Widget>[
                  SizedBox(height: 24.h),
                  const Center(child: PlatformActivityIndicator()),
                ],
                if (state is ApiCallError<ReceiptCaptureOutcome>) ...<Widget>[
                  SizedBox(height: 16.h),
                  Text(
                    captureFailureCopy(state.message),
                    style: TextStyles.of(size: 14),
                  ),
                ],
                if (readFailed) ...<Widget>[
                  SizedBox(height: 12.h),
                  AppElevatedButton(
                    key: const Key('receipt-continue-blank'),
                    text: Strings.fenzoReceiptSkipped,
                    onPressed: () => context
                        .read<StartReceiptCaptureCubit>()
                        .fSkipToBlankDraft(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _start(BuildContext context, ReceiptImageSource source) {
    context.read<StartReceiptCaptureCubit>().fStartReceiptCapture(source);
  }

  Future<void> _onState(
    BuildContext context,
    StartReceiptCaptureState state,
  ) async {
    if (state is! ApiCallSuccess<ReceiptCaptureOutcome>) {
      return;
    }
    switch (state.data) {
      case ReceiptProposalReady(:final draft, :final photo):
        context.push(
          AppRoutes.captureReview,
          extra: CaptureReviewRequest(draft: draft, photo: photo),
        );
      case ReceiptBlankReady(:final draft):
        context.push(
          AppRoutes.captureReview,
          extra: CaptureReviewRequest(draft: draft),
        );
      case ReceiptConsentRequired():
        await _explainOffDevice(context);
      case ReceiptCaptureCancelled():
        break;
    }
  }

  Future<void> _explainOffDevice(BuildContext context) async {
    final bool? agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(Strings.fenzoReceiptOffDevice),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(Strings.fenzoReceiptSkipped),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(Strings.fenzoCaptureConfirm),
            ),
          ],
        );
      },
    );
    if (!context.mounted || agreed == null) {
      return;
    }
    final StartReceiptCaptureCubit cubit = context
        .read<StartReceiptCaptureCubit>();
    if (agreed) {
      await cubit.fAcceptOffDeviceReading();
      return;
    }
    await cubit.fSkipToBlankDraft();
  }
}
