import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

/// 设置页面 - 数据备份、导入导出
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.slow,
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
      appBar: CupertinoNavigationBar(
        middle: const Text('设置'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('返回'),
          onPressed: () => Navigator.pop(context),
        ),
        border: null,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // 数据备份
            _buildAnimatedSection(
              0,
              _buildSectionTitle('数据管理'),
            ),
            _buildAnimatedSection(
              1,
              _buildCard([
                _buildActionTile(
                  icon: CupertinoIcons.share,
                  iconColor: AppColors.primary,
                  title: '导出备份',
                  subtitle: '将所有数据导出为JSON',
                  onTap: () => _exportData(context),
                ),
                const Divider(height: 1, indent: 60, color: AppColors.border),
                _buildActionTile(
                  icon: CupertinoIcons.arrow_down_doc,
                  iconColor: AppColors.success,
                  title: '导入数据',
                  subtitle: '从JSON文件恢复数据',
                  onTap: () => _showImportDialog(context),
                ),
                const Divider(height: 1, indent: 60, color: AppColors.border),
                _buildActionTile(
                  icon: CupertinoIcons.doc_on_clipboard,
                  iconColor: AppColors.warning,
                  title: '复制到剪贴板',
                  subtitle: '将备份数据复制到剪贴板',
                  onTap: () => _copyToClipboard(context),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // 关于
            _buildAnimatedSection(
              2,
              _buildSectionTitle('关于'),
            ),
            _buildAnimatedSection(
              3,
              _buildCard([
                _buildInfoTile(
                  icon: CupertinoIcons.info_circle,
                  iconColor: AppColors.textSecondary,
                  title: '版本',
                  value: '1.1.0',
                ),
                const Divider(height: 1, indent: 60, color: AppColors.border),
                _buildInfoTile(
                  icon: CupertinoIcons.heart_fill,
                  iconColor: const Color(0xFFFF2D55),
                  title: 'SuppCheck',
                  value: '补剂记录',
                ),
              ]),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final animations = List.generate(6, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.08,
            0.4 + i * 0.08,
            curve: AppleCurves.decelerate,
          ),
        ),
      );
    });

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: animations[index].value,
          child: Transform.translate(
            offset: Offset(0, (1 - animations[index].value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.footnote.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PressableButton(
      scale: 0.98,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor,
                    iconColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.footnote,
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTextStyles.body),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final provider = context.read<SupplementProvider>();
    final data = await provider.exportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    
    // 分享数据
    await Share.share(
      jsonStr,
      subject: 'SuppCheck 数据备份 ${DateTime.now().toString().split(' ')[0]}',
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final provider = context.read<SupplementProvider>();
    final data = await provider.exportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    
    await Clipboard.setData(ClipboardData(text: jsonStr));
    
    if (context.mounted) {
      _showSuccessToast(context, '已复制到剪贴板');
    }
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('导入数据'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              const Text('请粘贴备份的JSON数据'),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: controller,
                maxLines: 5,
                placeholder: '粘贴JSON数据...',
                style: const TextStyle(fontSize: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('导入'),
            onPressed: () async {
              final jsonStr = controller.text.trim();
              if (jsonStr.isEmpty) return;
              
              try {
                final data = jsonDecode(jsonStr) as Map<String, dynamic>;
                await context.read<SupplementProvider>().importData(data);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSuccessToast(context, '导入成功');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _showErrorToast(context, '导入失败: 数据格式错误');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.gray900.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showErrorToast(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.gray900.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.xmark_circle_fill,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.pop(context);
    });
  }
}
