import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

part '../widgets/legal_screen_widgets.dart';

enum LegalPage { terms, privacy, usage }

class LegalScreen extends StatefulWidget {
  final LegalPage page;
  const LegalScreen({super.key, required this.page});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];

  late _LegalContent _content;

  @override
  void initState() {
    super.initState();
    _content = _getContent(widget.page);
    _sectionKeys
        .addAll(List.generate(_content.sections.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(LegalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      setState(() {
        _content = _getContent(widget.page);
        _sectionKeys.clear();
        _sectionKeys.addAll(
            List.generate(_content.sections.length, (_) => GlobalKey()));
      });
      _scrollController.animateTo(0, duration: 300.ms, curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    HapticFeedback.selectionClick();
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: 400.ms,
        curve: Curves.easeInOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final isDesktop = context.isDesktop;
    final hPadding = context.pageHorizontalPadding;
    final maxWidth = context.pageMaxWidth;

    return Scaffold(
      backgroundColor: ext.bg,
      appBar: (!isDesktop)
          ? AppBar(
              backgroundColor: ext.surface,
              title: Text(_content.title,
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: ext.text),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(color: ext.border, height: 1),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Cyberpunk Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.primary.withValues(alpha: 0.15),
                    ext.bg.withValues(alpha: 0.0),
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 3.seconds, begin: 0.5, end: 1.0),
          ),

          Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: maxWidth > 1000 ? 1000 : maxWidth),
              child: isDesktop
                  ? _buildDesktopLayout(ext, hPadding)
                  : _buildMobileLayout(ext, hPadding),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AuralixThemeExtension ext, double hPadding) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _buildScrollableContent(ext, hPadding, hPadding / 2),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: _buildTableOfContents(ext),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuralixThemeExtension ext, double hPadding) {
    return _buildScrollableContent(ext, hPadding, hPadding);
  }

  Widget _buildTableOfContents(AuralixThemeExtension ext) {
    return StickyTocBuilder(
      title: _content.title,
      sections: _content.sections,
      onTap: _scrollTo,
      theme: ext,
    );
  }

  Widget _buildScrollableContent(
      AuralixThemeExtension ext, double leftPad, double rightPad) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(leftPad, 20, rightPad, 48),
      child: TerminalPageReveal(
        animationKey: 'legal-${_content.title}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TerminalPageHeader(
              title: 'legal',
              subtitle: _content.title,
              actions: const [
                StatusBadge(code: 200, message: 'active policy'),
              ],
            ),
            const SizedBox(height: 24),
            GlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 16, color: ext.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Last update: March 2025 â€¢ Strict Mode: Enabled',
                    style: TextStyle(
                      color: ext.primary,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().shimmer(
                duration: 1.seconds, color: ext.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 32),
            ...List.generate(_content.sections.length, (index) {
              final s = _content.sections[index];
              return Padding(
                key: _sectionKeys[index],
                padding: const EdgeInsets.only(bottom: 24),
                child: HoverLegalSection(section: s),
              )
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                  .slideX(begin: 0.05, end: 0, curve: Curves.easeOutBack);
            }),

            // Terminal EOF marker
            const SizedBox(height: 20),
            Center(
              child: const Text('EOF',
                      style:
                          TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(duration: 800.ms, begin: 0.3, end: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  _LegalContent _getContent(LegalPage p) => switch (p) {
        LegalPage.terms => _terms,
        LegalPage.privacy => _privacy,
        LegalPage.usage => _usage,
      };
}
