import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_control/models/accessibility_service_status.dart';
import 'package:power_control/services/power_control_service.dart';
import 'package:power_control/widgets/accessibility_status_card.dart';
import 'package:power_control/widgets/power_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.powerControlService,
  });

  final PowerControlService? powerControlService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final PowerControlService _service =
      widget.powerControlService ?? PowerControlService();
  AccessibilityServiceStatus _status = AccessibilityServiceStatus.checking;
  bool _isBusy = false;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    try {
      final enabled = await _service.isAccessibilityServiceEnabled();
      if (!mounted) return;
      setState(() {
        _status = enabled
            ? AccessibilityServiceStatus.enabled
            : AccessibilityServiceStatus.disabled;
        _statusError = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = AccessibilityServiceStatus.unavailable;
        _statusError = _errorMessage(error);
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _status = AccessibilityServiceStatus.unavailable;
        _statusError = 'Không tìm thấy chức năng Android cần thiết.';
      });
    }
  }

  Future<void> _handleAction(String action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final enabled = await _service.isAccessibilityServiceEnabled();
      if (!mounted) return;
      setState(() {
        _status = enabled
            ? AccessibilityServiceStatus.enabled
            : AccessibilityServiceStatus.disabled;
        _statusError = null;
      });

      if (!enabled) {
        setState(() => _isBusy = false);
        await _showAccessibilityDialog();
        return;
      }

      await _service.openPowerMenu();
      if (!mounted) return;
      _showMessage(
        'Menu nguồn đã mở. Hãy tự chọn “$action” trên điện thoại.',
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == 'accessibility_disabled') {
          _status = AccessibilityServiceStatus.disabled;
        } else if (error.code == 'service_unavailable') {
          _status = AccessibilityServiceStatus.unavailable;
        }
        _statusError = _errorMessage(error);
      });
      _showMessage(_errorMessage(error));
    } on MissingPluginException {
      if (!mounted) return;
      const message = 'Không tìm thấy chức năng Android cần thiết.';
      setState(() {
        _status = AccessibilityServiceStatus.unavailable;
        _statusError = message;
      });
      _showMessage(message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showAccessibilityDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần bật quyền Trợ năng'),
        content: const Text(
          'Hãy bật Power Control trong Cài đặt Trợ năng. '
          'Quyền này chỉ giúp mở menu nguồn Android; ứng dụng không tự '
          'chọn tắt máy hoặc khởi động lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bật quyền Trợ năng'),
          ),
        ],
      ),
    );

    if (openSettings != true || !mounted) return;
    try {
      await _service.openAccessibilitySettings();
    } on PlatformException catch (error) {
      if (mounted) _showMessage(_errorMessage(error));
    } on MissingPluginException {
      if (mounted) _showMessage('Không tìm thấy chức năng Android cần thiết.');
    }
  }

  String _errorMessage(PlatformException error) {
    return switch (error.code) {
      'accessibility_disabled' =>
        'Dịch vụ Trợ năng chưa được bật. Hãy bật dịch vụ trong Cài đặt.',
      'service_unavailable' =>
        'Dịch vụ Trợ năng chưa kết nối. Hãy kiểm tra quyền rồi thử lại.',
      'power_menu_unavailable' =>
        'Thiết bị không mở được menu nguồn bằng dịch vụ Trợ năng.',
      'settings_unavailable' =>
        'Không thể mở Cài đặt Trợ năng trên thiết bị này.',
      _ => error.message ?? 'Đã xảy ra lỗi khi giao tiếp với Android.',
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2638),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.power_settings_new_rounded,
                          color: Color(0xFF7CB3FF),
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 23),
                      const Text(
                        'Power Control',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Nubia Neo 3',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA8BA),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AccessibilityStatusCard(status: _status),
                      if (_status == AccessibilityServiceStatus.disabled ||
                          _status == AccessibilityServiceStatus.unavailable) ...[
                        const SizedBox(height: 13),
                        _GuidanceCard(
                          message:
                              _statusError ??
                              'Bật dịch vụ Trợ năng để mở menu nguồn.',
                        ),
                      ],
                      const SizedBox(height: 28),
                      PowerActionButton(
                        label: 'Shutdown',
                        subtitle: 'Mở menu nguồn Android',
                        icon: Icons.power_settings_new_rounded,
                        color: const Color(0xFFC94752),
                        isBusy: _isBusy,
                        onPressed: _isBusy ? null : () => _handleAction('Power off'),
                      ),
                      const SizedBox(height: 14),
                      PowerActionButton(
                        label: 'Restart',
                        subtitle: 'Mở menu nguồn Android',
                        icon: Icons.restart_alt_rounded,
                        color: const Color(0xFF2874D0),
                        isBusy: _isBusy,
                        onPressed: _isBusy ? null : () => _handleAction('Restart'),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Cả hai nút đều mở menu nguồn hệ thống. '
                        'Bạn cần tự chọn và xác nhận thao tác trên điện thoại.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8994A5),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF262319),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFFFFC857),
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFE4D7B6),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
