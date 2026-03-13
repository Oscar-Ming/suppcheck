import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';
import '../widgets/supplement_card.dart';

/// 添加/编辑补剂页面
class AddSupplementScreen extends StatefulWidget {
  final Supplement? supplement;

  const AddSupplementScreen({super.key, this.supplement});

  @override
  State<AddSupplementScreen> createState() => _AddSupplementScreenState();
}

class _AddSupplementScreenState extends State<AddSupplementScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _maxDailyController = TextEditingController(text: '3');
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();

  String _form = '胶囊';
  String _frequency = '每日1次';
  List<String> _timing = ['早餐后'];
  SupplementCategory _category = SupplementCategory.other;

  late AnimationController _controller;
  late List<Animation<double>> _fieldAnimations;

  bool get isEditing => widget.supplement != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final s = widget.supplement!;
      _nameController.text = s.name;
      _dosageController.text = s.dosage;
      _maxDailyController.text = s.maxDaily.toString();
      _stockController.text = s.stock?.toString() ?? '';
      _notesController.text = s.notes ?? '';
      _form = s.form;
      _frequency = s.frequency;
      _timing = List.from(s.timing);
      _category = s.category;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 为每个表单区域创建动画
    _fieldAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.08,
            0.4 + index * 0.08,
            curve: AppleCurves.decelerate,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _maxDailyController.dispose();
    _stockController.dispose();
    _notesController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        middle: Text(isEditing ? '编辑补剂' : '添加补剂'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            isEditing ? '保存' : '添加',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: _saveSupplement,
        ),
        border: null,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              // 基本信息
              _buildAnimatedSection(
                0,
                _buildSectionTitle('基本信息'),
              ),
              _buildAnimatedSection(
                1,
                _buildCard([
                  _buildTextField(
                    controller: _nameController,
                    label: '名称',
                    placeholder: '如：维生素D3',
                    validator: (v) => v?.isEmpty ?? true ? '请输入名称' : null,
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildTextField(
                    controller: _dosageController,
                    label: '剂量',
                    placeholder: '如：1000 IU 或 1粒',
                    validator: (v) => v?.isEmpty ?? true ? '请输入剂量' : null,
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildCategorySelector(),
                ]),
              ),

              const SizedBox(height: 24),

              // 服用设置
              _buildAnimatedSection(
                2,
                _buildSectionTitle('服用设置'),
              ),
              _buildAnimatedSection(
                3,
                _buildCard([
                  _buildPickerTile(
                    label: '剂型',
                    value: _form,
                    options: AppConstants.forms,
                    onChanged: (v) => setState(() => _form = v),
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildPickerTile(
                    label: '频率',
                    value: _frequency,
                    options: AppConstants.frequencies,
                    onChanged: (v) => setState(() => _frequency = v),
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildTimingSelector(),
                  const Divider(height: 1, indent: 16),
                  _buildTextField(
                    controller: _maxDailyController,
                    label: '每日最大量',
                    placeholder: '3',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return '请输入最大量';
                      final n = int.tryParse(v!);
                      if (n == null || n < 1) return '请输入有效数字';
                      return null;
                    },
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // 库存（可选）
              _buildAnimatedSection(
                4,
                _buildSectionTitle('库存（可选）'),
              ),
              _buildAnimatedSection(
                5,
                _buildCard([
                  _buildTextField(
                    controller: _stockController,
                    label: '当前库存',
                    placeholder: '如：30',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // 备注
              _buildAnimatedSection(
                5,
                _buildSectionTitle('备注（可选）'),
              ),
              _buildAnimatedSection(
                5,
                _buildCard([
                  _buildTextField(
                    controller: _notesController,
                    label: '备注',
                    placeholder: '添加备注信息...',
                    maxLines: 3,
                  ),
                ]),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _fieldAnimations[index],
      builder: (context, child) {
        return Opacity(
          opacity: _fieldAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fieldAnimations[index].value) * 20),
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
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.body,
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: null,
              style: AppTextStyles.body,
              placeholderStyle: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showPicker(label, options, value, onChanged),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body),
            Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('分类', style: AppTextStyles.body),
              AnimatedContainer(
                duration: AnimationDurations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _category.displayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  _category.displayName,
                  style: AppTextStyles.callout.copyWith(
                    color: _category.displayColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: SupplementCategory.values.map((cat) {
              final isSelected = _category == cat;
              return PressableButton(
                scale: 0.92,
                onPressed: () {
                  setState(() {
                    _category = cat;
                  });
                },
                child: AnimatedContainer(
                  duration: AnimationDurations.fast,
                  curve: AppleCurves.spring,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cat.displayColor
                        : cat.displayColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: cat.displayColor.withOpacity(0.2),
                          ),
                  ),
                  child: Text(
                    cat.displayName,
                    style: AppTextStyles.callout.copyWith(
                      color: isSelected ? Colors.white : cat.displayColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('服用时间', style: AppTextStyles.body),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: AppConstants.timingOptions.map((time) {
              final isSelected = _timing.contains(time);
              return PressableButton(
                scale: 0.92,
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      if (_timing.length > 1) _timing.remove(time);
                    } else {
                      _timing.add(time);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: AnimationDurations.fast,
                  curve: AppleCurves.spring,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.callout.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showPicker(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onChanged,
  ) {
    var selectedValue = currentValue;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BottomSheetAnimation(
        child: Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 拖动条
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 顶部栏
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('取消'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        title,
                        style: AppTextStyles.headline,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text(
                          '确定',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          onChanged(selectedValue);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: options.indexOf(currentValue),
                    ),
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      selectedValue = options[index];
                    },
                    children: options.map((option) {
                      return Center(
                        child: Text(
                          option,
                          style: AppTextStyles.body,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveSupplement() {
    if (_formKey.currentState?.validate() ?? false) {
      final supplement = Supplement(
        id: widget.supplement?.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        form: _form,
        frequency: _frequency,
        timing: _timing,
        maxDaily: int.parse(_maxDailyController.text),
        stock: _stockController.text.isEmpty
            ? null
            : int.parse(_stockController.text),
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text.trim(),
        category: _category,
      );

      final provider = context.read<SupplementProvider>();
      
      if (isEditing) {
        provider.updateSupplement(supplement);
      } else {
        provider.addSupplement(supplement);
      }

      Navigator.pop(context);
    }
  }
}
