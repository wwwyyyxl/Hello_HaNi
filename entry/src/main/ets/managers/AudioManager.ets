/**
 * AudioManager.ets — 全局后台 AVPlayer 单例管理器
 * Global Background AVPlayer Singleton Manager.
 *
 * 基于 @kit.MediaKit 封装，实现极客风格的背景白噪音 BGM 播放。
 * 入场时自带音量淡入效果 (Fade-in)，创造沉浸式听觉体验。
 *
 * Built on @kit.MediaKit, provides background ambient audio playback
 * with a smooth volume fade-in effect for immersive audio experience.
 *
 * 【V2 状态管理】使用 @ObservedV2 + @Trace 实现细粒度状态追踪
 */
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class AudioManager {
  // 单例实例 (Singleton instance)
  private static instance: AudioManager | null = null;

  private avPlayer: media.AVPlayer | null = null;
  private fadeTimer: number = -1;

  @Trace isPlaying: boolean = false;
  @Trace currentVolume: number = 0;

  private readonly targetVolume: number = 0.3; // 目标音量 (target volume)
  private readonly fadeStep: number = 0.02;    // 每步淡入增量 (fade-in increment per step)
  private readonly fadeInterval: number = 100; // 淡入间隔 ms (fade interval in ms)

  private constructor() {}

  /**
   * 获取单例实例
   * Get singleton instance
   */
  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  /**
   * 初始化 AVPlayer 并加载 rawfile 音频资源
   * Initialize AVPlayer and load rawfile audio resource
   *
   * @param context - UIAbility 上下文，用于获取 rawfile 资源
   * @param fileName - rawfile 目录下的音频文件名
   */
  async init(context: common.UIAbilityContext, fileName: string): Promise<void> {
    try {
      // 创建 AVPlayer 实例 (Create AVPlayer instance)
      this.avPlayer = await media.createAVPlayer();

      // 设置 AVPlayer 状态回调 (Set AVPlayer state callbacks)
      this.avPlayer.on('stateChange', (state: string) => {
        if (state === 'prepared' && this.avPlayer) {
          // 播放器就绪后设置初始音量为0，然后开始播放
          // After prepared, set initial volume to 0 then start playback
          this.avPlayer.setVolume(0);
          this.avPlayer.loop = true; // 循环播放 (loop playback)
          this.avPlayer.play();
          this.isPlaying = true;
          this.startFadeIn(); // 启动淡入效果 (start fade-in effect)
        }
      });

      this.avPlayer.on('error', (err: Error) => {
        console.error(`[AudioManager] AVPlayer error: ${err.message}`);
      });

      // 从 rawfile 加载音频资源 (Load audio from rawfile)
      const resourceManager = context.resourceManager;
      const fileDescriptor = await resourceManager.getRawFd(fileName);
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.avPlayer.fdSrc = avFileDescriptor;

    } catch (error) {
      // 音频初始化失败时静默降级，不影响主功能
      // Silent degradation on audio init failure — does not affect core functionality
      console.warn(`[AudioManager] Init failed (silent degradation): ${error}`);
    }
  }

  /**
   * 音量淡入效果 — 从 0 缓缓升至目标音量
   * Volume fade-in effect: smoothly ramp from 0 to target volume
   */
  private startFadeIn(): void {
    this.currentVolume = 0;
    this.fadeTimer = setInterval(() => {
      if (this.currentVolume < this.targetVolume && this.avPlayer) {
        this.currentVolume = Math.min(this.currentVolume + this.fadeStep, this.targetVolume);
        this.avPlayer.setVolume(this.currentVolume);
      } else {
        clearInterval(this.fadeTimer);
      }
    }, this.fadeInterval);
  }

  /**
   * 暂停播放
   * Pause playback
   */
  pause(): void {
    if (this.avPlayer && this.isPlaying) {
      this.avPlayer.pause();
      this.isPlaying = false;
    }
  }

  /**
   * 恢复播放
   * Resume playback
   */
  resume(): void {
    if (this.avPlayer && !this.isPlaying) {
      this.avPlayer.play();
      this.isPlaying = true;
    }
  }

  /**
   * 释放所有资源 — 在组件 aboutToDisappear 时调用
   * Release all resources — called in aboutToDisappear lifecycle
   */
  async release(): Promise<void> {
    if (this.fadeTimer !== -1) {
      clearInterval(this.fadeTimer);
    }
    if (this.avPlayer) {
      await this.avPlayer.release();
      this.avPlayer = null;
      this.isPlaying = false;
    }
  }
}
