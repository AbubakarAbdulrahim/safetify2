import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300), // Adjust for sidebar
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
