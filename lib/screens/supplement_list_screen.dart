import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';
import '../widgets/supplement_card.dart';
import 'add_supplement_screen.dart';

/// 补剂列表页面 - 管理所有补剂
class SupplementListScreen extends StatefulWidget {
  const SupplementListScreen({super.key});

  @override
  State<SupplementListScreen> createState() => _SupplementListScreenState();
}

class _SupplementListScreenState extends State<SupplementListScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.normal,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<SupplementProvider>(
          builder: (context, provider, child) {
            final supplements = provider.supplements;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 顶部标题
                SliverToBoxAdapter(
                  child: FadeIn(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('我的补剂', style: AppTextStyles.largeTitle),
                          if (supplements.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                              child: Text(
                                '${supplements.length} 种',
                                style: AppTextStyles.footnote.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 补剂列表
                if (supplements.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final supplement = supplements[index];
                          return SupplementListItem(
                            supplement: supplement,
                            index: index,
                            onTap: () => _showSupplementDetail(context, supplement),
                            onEdit: () => _editSupplement(context, supplement),
                            onDelete: () => _deleteSupplement(context, supplement),
                          );
                        },
                        childCount: supplements.length,
                      ),
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FadeIn(
        delay: const Duration(milliseconds: 400),
        slideOffset: const Offset(0, 0.2),
        child: PressableButton(
          scale: 0.95,
          onPressed: () => _addSupplement(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      delay: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(
                CupertinoIcons.capsule,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有添加补剂',
              style: AppTextStyles.title3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角添加你的第一个补剂',
              style: AppTextStyles.callout,
            ),
          ],
        ),
      ),
    );
  }

  void _addSupplement(BuildContext context) {
    Navigator.push(
      context,
      ApplePageRoute(
        child: const AddSupplementScreen(),
        fromBottom: true,
      ),
    );
  }

  void _editSupplement(BuildContext context, Supplement supplement) {
    Navigator.push(
      context,
      ApplePageRoute(
        child: AddSupplementScreen(supplement: supplement),
        fromBottom: true,
      ),
    );
  }

  void _deleteSupplement(BuildContext context, Supplement supplement) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${supplement.name}" 吗？此操作不可恢复。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () async {
              await context.read<SupplementProvider>().deleteSupplement(
                supplement.id!,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSupplementDetail(BuildContext context, Supplement supplement) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BottomSheetAnimation(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部拖动条
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                ),

                // 标题
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              supplement.category.displayColor,
                              supplement.category.displayColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(
                          CupertinoIcons.capsule,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplement.name,
                              style: AppTextStyles.title2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              supplement.category.displayName,
                              style: AppTextStyles.callout.copyWith(
                                color: supplement.category.displayColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 详情项
                _buildDetailItem('剂量', supplement.dosage),
                _buildDetailItem('剂型', supplement.form),
                _buildDetailItem('频率', supplement.frequency),
                _buildDetailItem('服用时间', supplement.timing.join('、')),
                _buildDetailItem('每日最大量', '${supplement.maxDaily} 次'),
                if (supplement.stock != null)
                  _buildDetailItem(
                    '库存', 
                    '${supplement.stock}',
                    valueColor: supplement.stock! <= 7 ? AppColors.danger : null,
                  ),
                if (supplement.notes != null && supplement.notes!.isNotEmpty)
                  _buildDetailItem('备注', supplement.notes!),

                const SizedBox(height: 24),

                // 操作按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: const Text(
                            '编辑',
                            style: AppTextStyles.button,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _editSupplement(context, supplement);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Text(
                            '删除',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteSupplement(context, supplement);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }
}
