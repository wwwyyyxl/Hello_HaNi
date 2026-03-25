/**
 * ParticleSystem.ets — 高性能粒子引擎数据模型与物理计算
 * High-Performance Particle Engine: Data models and physics calculations.
 *
 * 使用纯 TypeScript 面向对象封装，与 UI 层完全解耦。
 * 粒子运动基于时间驱动的帧动画，确保渲染逻辑不阻塞 UI 主线程。
 *
 * Pure OOP encapsulation in TypeScript, fully decoupled from the UI layer.
 * Frame animation driven by time-delta to ensure non-blocking rendering.
 */

/**
 * 单个粒子的数据模型
 * Data model for a single particle
 */
export class Particle {
  x: number;
  y: number;
  vx: number; // X 轴速度 (velocity on X-axis)
  vy: number; // Y 轴速度 (velocity on Y-axis)
  radius: number;
  opacity: number;

  constructor(canvasWidth: number, canvasHeight: number) {
    this.x = Math.random() * canvasWidth;
    this.y = Math.random() * canvasHeight;
    this.vx = (Math.random() - 0.5) * 0.6; // 缓慢漂移 (slow drift)
    this.vy = (Math.random() - 0.5) * 0.6;
    this.radius = Math.random() * 1.5 + 0.5; // 0.5 ~ 2.0 px
    this.opacity = Math.random() * 0.5 + 0.3; // 0.3 ~ 0.8
  }
}

/**
 * 粒子系统引擎 — 管理粒子的生命周期和物理运动
 * Particle System Engine: Manages lifecycle and physics of all particles.
 */
export class ParticleEngine {
  private particles: Particle[] = [];
  private canvasWidth: number;
  private canvasHeight: number;
  private readonly connectionDistance: number = 120; // 连线阈值距离 (connection threshold in px)
  private readonly particleCount: number;

  constructor(width: number, height: number, count: number = 60) {
    this.canvasWidth = width;
    this.canvasHeight = height;
    this.particleCount = count;
    this.initParticles();
  }

  /**
   * 初始化粒子群
   * Initialize particle swarm
   */
  private initParticles(): void {
    this.particles = [];
    for (let i = 0; i < this.particleCount; i++) {
      this.particles.push(new Particle(this.canvasWidth, this.canvasHeight));
    }
  }

  /**
   * 更新画布尺寸 (设备旋转等场景)
   * Update canvas dimensions (e.g., device rotation)
   */
  updateDimensions(width: number, height: number): void {
    this.canvasWidth = width;
    this.canvasHeight = height;
  }

  /**
   * 物理帧更新：更新所有粒子位置并处理边界碰撞
   * Physics tick: Update all particle positions and handle boundary collisions
   */
  update(): void {
    for (const p of this.particles) {
      p.x += p.vx;
      p.y += p.vy;

      // 边界反弹 (boundary bounce)
      if (p.x < 0 || p.x > this.canvasWidth) {
        p.vx *= -1;
        p.x = Math.max(0, Math.min(p.x, this.canvasWidth));
      }
      if (p.y < 0 || p.y > this.canvasHeight) {
        p.vy *= -1;
        p.y = Math.max(0, Math.min(p.y, this.canvasHeight));
      }
    }
  }

  /**
   * 渲染帧：绘制粒子和连线到 Canvas
   * Render frame: Draw particles and connections onto Canvas
   *
   * @param ctx - CanvasRenderingContext2D 渲染上下文
   */
  render(ctx: CanvasRenderingContext2D): void {
    // 清除画布 (clear canvas)
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 1. 绘制粒子间的连线 — 科技感核心 (Draw connections — the tech-feel core)
    for (let i = 0; i < this.particles.length; i++) {
      for (let j = i + 1; j < this.particles.length; j++) {
        const a = this.particles[i];
        const b = this.particles[j];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < this.connectionDistance) {
          // 距离越近，连线越亮 (closer distance = brighter line)
          const alpha = (1 - dist / this.connectionDistance) * 0.35;
          ctx.strokeStyle = `rgba(59, 130, 246, ${alpha})`; // 科技蓝 (tech blue)
          ctx.lineWidth = 0.5;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.stroke();
        }
      }
    }

    // 2. 绘制粒子本体 — 带辉光效果 (Draw particle bodies — with glow)
    for (const p of this.particles) {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(147, 197, 253, ${p.opacity})`; // 浅蓝辉光 (light blue glow)
      ctx.fill();

      // 外层辉光圈 (outer glow ring)
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius * 2.5, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(59, 130, 246, ${p.opacity * 0.15})`;
      ctx.fill();
    }
  }
}
