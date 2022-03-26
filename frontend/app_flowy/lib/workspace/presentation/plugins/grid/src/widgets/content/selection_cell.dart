import 'package:app_flowy/startup/startup.dart';
import 'package:app_flowy/workspace/application/grid/prelude.dart';
import 'package:flutter/material.dart';

class SingleSelectCell extends StatefulWidget {
  final FutureCellData cellData;

  const SingleSelectCell({
    required this.cellData,
    Key? key,
  }) : super(key: key);

  @override
  State<SingleSelectCell> createState() => _SingleSelectCellState();
}

class _SingleSelectCellState extends State<SingleSelectCell> {
  late SelectionCellBloc _cellBloc;

  @override
  void initState() {
    _cellBloc = getIt<SelectionCellBloc>(param1: widget.cellData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Future<void> dispose() async {
    _cellBloc.close();
    super.dispose();
  }
}

//----------------------------------------------------------------
class MultiSelectCell extends StatefulWidget {
  final FutureCellData cellData;

  const MultiSelectCell({
    required this.cellData,
    Key? key,
  }) : super(key: key);

  @override
  State<MultiSelectCell> createState() => _MultiSelectCellState();
}

class _MultiSelectCellState extends State<MultiSelectCell> {
  late SelectionCellBloc _cellBloc;

  @override
  void initState() {
    _cellBloc = getIt<SelectionCellBloc>(param1: widget.cellData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Future<void> dispose() async {
    _cellBloc.close();
    super.dispose();
  }
}
