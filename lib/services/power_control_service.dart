import 'package:flutter/services.dart';

class PowerControlService {
  PowerControlService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.powercontrol.power_control/power';

  final MethodChannel _channel;

  Future<bool> isAccessibilityServiceEnabled() async {
    final enabled = await _channel.invokeMethod<bool>(
      'isAccessibilityServiceEnabled',
    );
    if (enabled == null) {
      throw PlatformException(
        code: 'invalid_response',
        message: 'Không nhận được trạng thái dịch vụ Trợ năng từ Android.',
      );
    }
    return enabled;
  }

  Future<void> openAccessibilitySettings() async {
    final opened = await _channel.invokeMethod<bool>(
      'openAccessibilitySettings',
    );
    if (opened != true) {
      throw PlatformException(
        code: 'settings_unavailable',
        message: 'Không thể mở Cài đặt Trợ năng trên thiết bị này.',
      );
    }
  }

  Future<void> openPowerMenu() async {
    final opened = await _channel.invokeMethod<bool>('openPowerMenu');
    if (opened != true) {
      throw PlatformException(
        code: 'power_menu_unavailable',
        message: 'Dịch vụ Trợ năng chưa sẵn sàng để mở menu nguồn.',
      );
    }
  }
}
