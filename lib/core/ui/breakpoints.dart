import 'package:flutter/widgets.dart';

class AppBreakpoints {
  static const double mobile = 720;
  static const double tablet = 1100;
}

extension BreakpointContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < AppBreakpoints.mobile;
  bool get isTablet =>
      screenWidth >= AppBreakpoints.mobile &&
      screenWidth < AppBreakpoints.tablet;
  bool get isDesktop => screenWidth >= AppBreakpoints.tablet;

  double get pageHorizontalPadding {
    if (isMobile) return 14;
    if (isTablet) return 20;
    return 24;
  }

  double get pageMaxWidth {
    if (isMobile) return 900;
    if (isTablet) return 1080;
    return 1240;
  }
}
