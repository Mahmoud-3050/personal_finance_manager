import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/run_automatic_backup/run_automatic_backup_cubit.dart';

class AutomaticBackupHost extends StatefulWidget {
  const AutomaticBackupHost({required this.child, super.key});

  final Widget child;

  @override
  State<AutomaticBackupHost> createState() => _AutomaticBackupHostState();
}

class _AutomaticBackupHostState extends State<AutomaticBackupHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<RunAutomaticBackupCubit>().fRunAutomaticBackup();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
