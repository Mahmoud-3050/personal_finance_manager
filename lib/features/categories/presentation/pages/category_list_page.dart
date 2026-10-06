import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/finance_ledger.dart';
import '../../../../shared/widgets/finance_menu_field.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/confirm_action_dialog.dart';
import '../../domain/usecases/deactivate_category_use_case.dart';
import '../../domain/usecases/delete_category_use_case.dart';
import '../../domain/usecases/save_category_use_case.dart';
import '../controller/deactivate_category/deactivate_category_cubit.dart';
import '../controller/delete_category/delete_category_cubit.dart';
import '../controller/get_categories/get_categories_cubit.dart';
import '../controller/save_category/save_category_cubit.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<SaveCategoryCubit, ApiCallState<FinanceRecords>>(
          listener: _refresh,
        ),
        BlocListener<DeactivateCategoryCubit, ApiCallState<FinanceRecords>>(
          listener: _refresh,
        ),
        BlocListener<DeleteCategoryCubit, ApiCallState<FinanceRecords>>(
          listener: _refresh,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoCategories,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: BlocBuilder<GetCategoriesCubit, ApiCallState<FinanceRecords>>(
          builder: (BuildContext context, ApiCallState<FinanceRecords> state) {
            if (state is! ApiCallSuccess<FinanceRecords>) {
              return const Center(child: CircularProgressIndicator());
            }
            final FinanceRecords book = state.data;
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: <Widget>[
                for (final Category category in book.categories) ...<Widget>[
                  _CategoryTile(book: book, category: category),
                  for (final Subcategory subcategory
                      in book.subcategories.where(
                        (Subcategory item) => item.categoryId == category.id,
                      ))
                    _SubcategoryTile(book: book, subcategory: subcategory),
                ],
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addCategory(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _refresh(BuildContext context, ApiCallState<FinanceRecords> state) {
    if (state is ApiCallSuccess<FinanceRecords>) {
      context.read<GetCategoriesCubit>().fGetCategories();
    }
  }

  Future<void> _addCategory(BuildContext context) async {
    final (String, CategoryKind)? result =
        await showDialog<(String, CategoryKind)>(
          context: context,
          builder: (BuildContext context) => const _CategoryPrompt(),
        );
    if (result == null || !context.mounted || result.$1.isEmpty) {
      return;
    }
    context.read<SaveCategoryCubit>().fSaveCategory(
      SaveCategoryParams(name: result.$1, kind: result.$2),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.book, required this.category});

  final FinanceRecords book;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final bool used = _idIsUsed(book, category.id);
    return FinanceLedgerRow(
      title: category.name,
      subtitle: category.isActive ? category.kind.name : Strings.fenzoDeactivate,
      trailing: PopupMenuButton<String>(
        onSelected: (String action) => _onAction(context, action, used),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'rename',
            child: Text(Strings.fenzoName, style: TextStyles.of(size: 14)),
          ),
          PopupMenuItem<String>(
            value: 'subcategory',
            child: Text(
              Strings.fenzoSubcategory,
              style: TextStyles.of(size: 14),
            ),
          ),
          if (category.isActive && used)
            PopupMenuItem<String>(
              value: 'disable',
              child: Text(
                Strings.fenzoDeactivate,
                style: TextStyles.of(size: 14),
              ),
            ),
          if (!used)
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(Strings.fenzoDelete, style: TextStyles.of(size: 14)),
            ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, String action, bool used) async {
    switch (action) {
      case 'rename':
        final String? name = await _askName(context, category.name);
        if (name == null || name.isEmpty || !context.mounted) {
          return;
        }
        context.read<SaveCategoryCubit>().fSaveCategory(
          SaveCategoryParams(id: category.id, name: name, kind: category.kind),
        );
      case 'subcategory':
        final String? name = await _askName(context, '');
        if (name == null || name.isEmpty || !context.mounted) {
          return;
        }
        context.read<SaveCategoryCubit>().fSaveCategory(
          SaveCategoryParams(
            name: name,
            kind: category.kind,
            parentId: category.id,
          ),
        );
      case 'disable':
        final bool confirmed = await confirmAccountAction(
          context,
          message: Strings.fenzoDeactivate,
        );
        if (!confirmed || !context.mounted) {
          return;
        }
        context.read<DeactivateCategoryCubit>().fDeactivateCategory(
          DeactivateCategoryParams(category.id),
        );
      case 'delete':
        if (used) {
          return;
        }
        final bool confirmed = await confirmAccountAction(
          context,
          message: Strings.fenzoDelete,
        );
        if (!confirmed || !context.mounted) {
          return;
        }
        context.read<DeleteCategoryCubit>().fDeleteCategory(
          DeleteCategoryParams(category.id),
        );
    }
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({required this.book, required this.subcategory});

  final FinanceRecords book;
  final Subcategory subcategory;

  @override
  Widget build(BuildContext context) {
    final bool used = _idIsUsed(book, subcategory.id);
    final CategoryKind kind = book.categories
        .firstWhere((Category item) => item.id == subcategory.categoryId)
        .kind;
    return FinanceLedgerRow(
      indent: 16.w,
      title: subcategory.name,
      subtitle: subcategory.isActive
          ? Strings.fenzoSubcategory
          : Strings.fenzoDeactivate,
      trailing: PopupMenuButton<String>(
        onSelected: (String action) async {
          if (action == 'rename') {
            final String? name = await _askName(context, subcategory.name);
            if (name == null || name.isEmpty || !context.mounted) {
              return;
            }
            context.read<SaveCategoryCubit>().fSaveCategory(
              SaveCategoryParams(
                id: subcategory.id,
                parentId: subcategory.categoryId,
                name: name,
                kind: kind,
              ),
            );
            return;
          }
          if (action == 'disable') {
            final bool confirmed = await confirmAccountAction(
              context,
              message: Strings.fenzoDeactivate,
            );
            if (!confirmed || !context.mounted) {
              return;
            }
            context.read<DeactivateCategoryCubit>().fDeactivateCategory(
              DeactivateCategoryParams(subcategory.id),
            );
            return;
          }
          final bool confirmed = await confirmAccountAction(
            context,
            message: Strings.fenzoDelete,
          );
          if (!confirmed || !context.mounted) {
            return;
          }
          context.read<DeleteCategoryCubit>().fDeleteCategory(
            DeleteCategoryParams(subcategory.id),
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'rename',
            child: Text(Strings.fenzoName, style: TextStyles.of(size: 14)),
          ),
          if (subcategory.isActive && used)
            PopupMenuItem<String>(
              value: 'disable',
              child: Text(
                Strings.fenzoDeactivate,
                style: TextStyles.of(size: 14),
              ),
            ),
          if (!used)
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(Strings.fenzoDelete, style: TextStyles.of(size: 14)),
            ),
        ],
      ),
    );
  }
}

class _CategoryPrompt extends StatefulWidget {
  const _CategoryPrompt();

  @override
  State<_CategoryPrompt> createState() => _CategoryPromptState();
}

class _CategoryPromptState extends State<_CategoryPrompt> {
  final TextEditingController _name = TextEditingController();
  CategoryKind _kind = CategoryKind.expense;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        Strings.fenzoAddCategory,
        style: TextStyles.of(size: 18, weight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppTextFormField(controller: _name, labelText: Strings.fenzoName),
          SizedBox(height: 12.h),
          FinanceMenuField<CategoryKind>(
            value: _kind,
            label: Strings.fenzoCategory,
            items: CategoryKind.values
                .map(
                  (CategoryKind kind) => DropdownMenuItem<CategoryKind>(
                    value: kind,
                    child: Text(
                      kind == CategoryKind.income
                          ? Strings.fenzoIncome
                          : Strings.fenzoExpense,
                      style: TextStyles.of(size: 16),
                    ),
                  ),
                )
                .toList(),
            onChanged: (CategoryKind? value) {
              if (value == null) {
                return;
              }
              setState(() => _kind = value);
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Strings.fenzoCancel, style: TextStyles.of(size: 14)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop((_name.text.trim(), _kind)),
          child: Text(Strings.fenzoSave, style: TextStyles.of(size: 14)),
        ),
      ],
    );
  }
}

Future<String?> _askName(BuildContext context, String initial) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => _NamePrompt(initial: initial),
  );
}

class _NamePrompt extends StatefulWidget {
  const _NamePrompt({required this.initial});

  final String initial;

  @override
  State<_NamePrompt> createState() => _NamePromptState();
}

class _NamePromptState extends State<_NamePrompt> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: AppTextFormField(
        controller: _name,
        labelText: Strings.fenzoName,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Strings.fenzoCancel, style: TextStyles.of(size: 14)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_name.text.trim()),
          child: Text(Strings.fenzoSave, style: TextStyles.of(size: 14)),
        ),
      ],
    );
  }
}

bool _idIsUsed(FinanceRecords book, String id) {
  return book.transactions.any(
    (MoneyTransaction item) =>
        item.categoryId == id || item.subcategoryId == id,
  );
}
