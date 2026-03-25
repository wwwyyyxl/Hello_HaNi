/**
 * SensorManager.ets — 加速度计/陀螺仪传感器管理器 (视差 3D 效果)
 * Accelerometer/Gyroscope Sensor Manager for Parallax 3D Effect.
 *
 * 接入底层 @kit.SensorServiceKit 传感器，监听设备空间倾斜数据。
 * 配合 UI 层级 (Z轴)，让前景与背景产生微弱的相对位移偏差，
 * 营造通透的物理悬浮"裸眼 3D"视差感。
 *
 * Hooks into the low-level sensor service to monitor device spatial tilt.
 * Combined with UI Z-axis layering, creates a subtle relative displacement
 * between foreground and background for a "naked-eye 3D" parallax effect.
 *
 * 【V2 状态管理】@ObservedV2 + @Trace 实现跨组件细粒度响应式更新
 * 【低通滤波】LERP 阻尼平滑算法避免传感器原始数据的高频抖动
 */
import { sensor } from '@kit.SensorServiceKit';

@ObservedV2
export class SensorManager {
  // 单例实例 (Singleton instance)
  private static instance: SensorManager | null = null;

  /**
   * 视差偏移量 — UI 层通过 @Trace 响应式消费
   * Parallax offset values — consumed reactively by UI via @Trace
   * 范围: 大约 -15 ~ 15 vp (Range: approximately -15 ~ 15 vp)
   */
  @Trace offsetX: number = 0;
  @Trace offsetY: number = 0;

  private isListening: boolean = false;

  // 低通滤波系数 — 越小越平滑，但延迟越高
  // Low-pass filter coefficient: smaller = smoother but higher latency
  private readonly smoothFactor: number = 0.08;

  // 最大偏移幅度 (Maximum offset amplitude in vp)
  private readonly maxOffset: number = 15;

  private constructor() {}

  /**
   * 获取单例实例
   * Get singleton instance
   */
  static getInstance(): SensorManager {
    if (!SensorManager.instance) {
      SensorManager.instance = new SensorManager();
    }
    return SensorManager.instance;
  }

  /**
   * 启动传感器监听
   * Start sensor listening
   *
   * 使用加速度计 (ACCELEROMETER) 采集设备倾斜数据，
   * 采样周期 game 级别 (约 20ms) 保证视差动画的流畅性。
   *
   * Uses ACCELEROMETER to collect device tilt data with a 'game'
   * sampling interval (~20ms) to ensure parallax animation smoothness.
   */
  start(): void {
    if (this.isListening) {
      return;
    }
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        /**
         * 传感器坐标系说明:
         * x: 设备左右倾斜 (left-right tilt)
         * y: 设备前后倾斜 (forward-backward tilt)
         * z: 垂直方向 (vertical, ~9.8 when flat)
         *
         * 我们取 x, y 分量做视差，并做阻尼平滑 (LERP)
         * We use x, y components for parallax with LERP smoothing
         */
        const rawX = this.clamp(data.x * 1.5, -this.maxOffset, this.maxOffset);
        const rawY = this.clamp(data.y * 1.5, -this.maxOffset, this.maxOffset);

        // LERP 低通滤波: newValue = oldValue + (targetValue - oldValue) * factor
        // LERP low-pass filter: smooth out high-frequency jitter
        this.offsetX = this.offsetX + (rawX - this.offsetX) * this.smoothFactor;
        this.offsetY = this.offsetY + (rawY - this.offsetY) * this.smoothFactor;
      }, { interval: 'game' }); // 'game' 级别采样 (~20ms)

      this.isListening = true;
    } catch (error) {
      // 静默降级：模拟器或不支持加速度计的设备
      // Silent degradation: emulator or devices without accelerometer
      console.warn(`[SensorManager] Accelerometer unavailable (silent degradation): ${error}`);
    }
  }

  /**
   * 停止传感器监听 — 在组件 aboutToDisappear 时调用以释放资源
   * Stop sensor listening — call in aboutToDisappear to release resources
   */
  stop(): void {
    if (this.isListening) {
      try {
        sensor.off(sensor.SensorId.ACCELEROMETER);
      } catch (error) {
        console.debug(`[SensorManager] Sensor off error: ${error}`);
      }
      this.isListening = false;
    }
  }

  /**
   * 数值钳位工具 (Clamp utility)
   */
  private clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }
}
