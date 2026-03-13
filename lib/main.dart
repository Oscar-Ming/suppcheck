import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'providers/supplement_provider.dart';
import 'utils/constants.dart';
import 'utils/animations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日期格式化
  await initializeDateFormatting();
  
  // 设置状态栏样式 - 白底黑字高级质感
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  // 初始化服务（带错误处理）
  try {
    await DatabaseService.instance.initialize();
    debugPrint('✅ Database initialized');
  } catch (e) {
    debugPrint('❌ Database error: $e');
  }
  
  try {
    await NotificationService.instance.initialize();
    debugPrint('✅ Notification initialized');
  } catch (e) {
    debugPrint('❌ Notification error: $e');
  }
  
  runApp(const SuppCheckApp());
}

class SuppCheckApp extends StatelessWidget {
  const SuppCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupplementProvider()),
      ],
      child: MaterialApp(
        title: 'SuppCheck',
        debugShowCheckedModeBanner: false,
        theme: _buildPremiumTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  /// 高级质感白底黑字主题
  ThemeData _buildPremiumTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ========== 颜色方案 ==========
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.white,
        background: AppColors.background,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // ========== 页面背景 ==========
      scaffoldBackgroundColor: AppColors.background,
      
      // ========== 字体 ==========
      fontFamily: kIsWeb ? null : '.SF Pro Text',
      
      // ========== 卡片样式 ==========
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: AppColors.cardBackground,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      
      // ========== AppBar 样式 ==========
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.headline,
        toolbarHeight: 56,
      ),
      
      // ========== 底部导航栏样式 ==========
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // ========== 按钮样式 ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: const BorderSide(color: AppColors.border, width: 1),
          textStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      
      // ========== 输入框样式 ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, 
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      
      // ========== 分隔线样式 ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
        indent: AppSpacing.lg,
      ),
      
      // ========== 列表样式 ==========
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, 
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: 40,
        dense: false,
        visualDensity: VisualDensity.compact,
      ),
      
      // ========== 复选框样式 ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray200;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      
      // ========== 单选按钮样式 ==========
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray400;
        }),
      ),
      
      // ========== 开关样式 ==========
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.white;
          }
          return AppColors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray300;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),
      
      // ========== 滑块样式 ==========
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.gray200,
        thumbColor: AppColors.white,
        overlayColor: AppColors.primary.withOpacity(0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8,
          elevation: 2,
        ),
      ),
      
      // ========== 进度指示器样式 ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.gray100,
        circularTrackColor: AppColors.gray100,
      ),
      
      // ========== 对话框样式 ==========
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTextStyles.title2,
        contentTextStyle: AppTextStyles.body,
      ),
      
      // ========== 底部Sheet样式 ==========
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      
      // ========== Chip样式 ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray50,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.gray100,
        labelStyle: AppTextStyles.callout,
        secondaryLabelStyle: AppTextStyles.callout.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, 
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: BorderSide.none,
      ),
      
      // ========== 悬浮按钮样式 ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, 
          vertical: AppSpacing.md,
        ),
      ),
      
      // ========== TabBar样式 ==========
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      
      // ========== 滚动条样式 ==========
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.gray300),
        trackColor: MaterialStateProperty.all(Colors.transparent),
        thickness: MaterialStateProperty.all(4),
        radius: const Radius.circular(2),
        minThumbLength: 40,
      ),
      
      // ========== 页面转场动画 ==========
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: const _ApplePageTransitionBuilder(),
          TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: const _ApplePageTransitionBuilder(),
          TargetPlatform.linux: const _ApplePageTransitionBuilder(),
          TargetPlatform.fuchsia: const _ApplePageTransitionBuilder(),
        },
      ),
    );
  }
}

/// 苹果风格的页面转场构建器（用于Android等平台）
class _ApplePageTransitionBuilder extends PageTransitionsBuilder {
  const _ApplePageTransitionBuilder();
  
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: AppleCurves.standard,
      reverseCurve: AppleCurves.accelerate,
    );
    
    final secondaryCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppleCurves.standard,
    );
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.25, 0),
        end: Offset.zero,
      ).animate(curve),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(curve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.25, 0),
          ).animate(secondaryCurve),
          child: child,
        ),
      ),
    );
  }
}
