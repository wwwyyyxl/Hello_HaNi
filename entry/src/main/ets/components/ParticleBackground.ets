/**
 * ParticleBackground.ets — 高性能粒子流动效背景组件
 * High-Performance Particle Flow Animated Background Component.
 *
 * 在 UI 底层铺设全屏 Canvas 组件，纯手搓基于时间的帧动画。
 * 科技感连线粒子流，挑战 60Hz+ 满帧运行。
 *
 * Renders a full-screen Canvas at the UI base layer with hand-crafted
 * time-based frame animation. Tech-style connected particle flow
 * targeting 60Hz+ full frame rate.
 *
 * 【V2 状态管理】@ComponentV2 + @Local 驱动渲染帧刷新
 */
import { ParticleEngine } from '../utils/ParticleSystem';

@ComponentV2
export struct ParticleBackground {
  // Canvas 渲染上下文 (Canvas rendering context)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private engine: ParticleEngine | null = null;
  private animationTimer: number = -1;

  // 画布尺寸 (canvas dimensions)
  @Local canvasWidth: number = 0;
  @Local canvasHeight: number = 0;

  aboutToDisappear(): void {
    // 释放帧动画定时器 (Release frame animation timer)
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  /**
   * 启动帧循环 — 以约 30fps 驱动粒子物理更新和渲染
   * Start frame loop at ~30fps for physics update and rendering
   *
   * 30fps 在移动端已足够流畅，同时大幅降低 CPU/GPU 功耗。
   * 30fps is visually smooth on mobile while significantly reducing power consumption.
   */
  private startAnimation(): void {
    if (this.animationTimer !== -1) {
      return;
    }
    this.animationTimer = setInterval(() => {
      if (this.engine) {
        this.engine.update();   // 物理帧 (physics tick)
        this.engine.render(this.ctx); // 渲染帧 (render frame)
      }
    }, 33); // ~30fps
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height('100%')
      .backgroundColor('#0F172A') // 深邃蓝底 (deep blue base)
      .onReady(() => {
        // Canvas 就绪后初始化粒子引擎
        // Initialize particle engine after Canvas is ready
        this.canvasWidth = this.ctx.width;
        this.canvasHeight = this.ctx.height;
        this.engine = new ParticleEngine(this.canvasWidth, this.canvasHeight, 55);
        this.startAnimation();
      })
  }
}
