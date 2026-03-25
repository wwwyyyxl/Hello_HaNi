/**
 * HapticManager.ets — 线性马达震动反馈管理器
 * Linear Motor Haptic Feedback Manager.
 *
 * 封装 @kit.SensorServiceKit 的 vibrator 能力，为可交互元素
 * 提供类似机械按键段落感的细腻微震动反馈。
 *
 * Wraps vibrator capabilities from @kit.SensorServiceKit to provide
 * delicate micro-vibration feedback (mechanical key-press feel) for
 * all interactive elements.
 *
 * 【设计原则】静态工具类，无需实例化。传感器不可用时静默降级。
 * Static utility class, no instantiation needed. Silent degradation when sensor unavailable.
 */
import { vibrator } from '@kit.SensorServiceKit';

export class HapticManager {
  /**
   * 轻触反馈 — 用于技能标签、列表项等轻量交互
   * Light tap feedback — for skill tags, list items, and lightweight interactions
   * 时长: 20ms | 类型: sharp (清脆段落感)
   * Duration: 20ms | Type: sharp (crisp tactile click)
   */
  static lightTap(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 20
      }, {
        id: 0,
        usage: 'touch'
      });
    } catch (error) {
      // 静默降级：真机不支持或权限不足时不影响用户流程
      // Silent degradation: no impact on UX when hardware/permissions unavailable
      console.debug(`[HapticManager] lightTap skipped: ${error}`);
    }
  }

  /**
   * 中等按压反馈 — 用于 FAB 按钮、卡片点击等重要交互
   * Medium press feedback — for FAB button, card taps, and significant interactions
   * 时长: 35ms | 类型: 更强的触觉冲击
   * Duration: 35ms | Type: stronger tactile impact
   */
  static mediumPress(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 35
      }, {
        id: 0,
        usage: 'touch'
      });
    } catch (error) {
      console.debug(`[HapticManager] mediumPress skipped: ${error}`);
    }
  }

  /**
   * 成功完成反馈 — 用于复制邮箱等操作成功场景
   * Success feedback — for clipboard copy success and similar scenarios
   * 时长: 50ms | 类型: 满足感的确认震动
   * Duration: 50ms | Type: satisfying confirmation vibration
   */
  static success(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 50
      }, {
        id: 0,
        usage: 'touch'
      });
    } catch (error) {
      console.debug(`[HapticManager] success skipped: ${error}`);
    }
  }
}
