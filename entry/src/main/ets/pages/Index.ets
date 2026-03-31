/**
 * Index.ets — 极客个人名片首页 (Navigation 根容器 · 满血重构版)
 * Geek Personal Card Homepage (Navigation Root · Full-blooded Refactoring Version)
 *
 * 四维度沉浸式全感官交互架构:
 * 1. Canvas 粒子流动效背景 (Particle Flow Background)
 * 2. Sensor 裸眼 3D 视差 (Parallax 3D via Accelerometer)
 * 3. Audio & Haptics 全感官联动 (Audio + Haptic Feedback)
 * 4. Navigation + GeometryTransition 英雄转场 (Hero Transition)
 *
 * 【V2 状态管理】全面使用 @ComponentV2, @Local, @Param, @Event
 * 【架构规范】企业级模块化 — Managers / Components / Pages / Utils 分层
 * 【API 12】废弃 router，全面拥抱 Navigation + NavPathStack
 */
import { common } from '@kit.AbilityKit';

// Managers — 底层服务单例 (Low-level service singletons)
import { AudioManager } from '../managers/AudioManager';
import { HapticManager } from '../managers/HapticManager';
import { SensorManager } from '../managers/SensorManager';

// Components — UI 组件层 (UI component layer)
import { ParticleBackground } from '../components/ParticleBackground';
import { ProfileSection } from '../components/ProfileSection';
import { SkillTags } from '../components/SkillTags';
import { ProjectCard } from '../components/ProjectCard';
import { ProjectItem, ProjectViewModel } from '../viewmodel/ProjectViewModel';
import { ProjectDetailPageBuilder } from '../pages/ProjectDetailPage';

// Swiper 动画状态模型，用于响应 customContentTransition (Swiper animation state model)
@ObservedV2
class SwiperCardStyle {
  @Trace scale: number = 1.0;
  @Trace transX: number = 0.0;
  @Trace opacity: number = 1.0;
  @Trace zIndex: number = 1;
}


@Entry
@ComponentV2
struct Index {
  /**
   * 使用 @Local 替代 V1 的 @State — 状态生命周期仅局限于组件内部
   * @Local replaces V1's @State — state lifecycle strictly within component
   */
  @Local isShowSheet: boolean = false;
  // Parallax offset — driven by SensorManager's @Trace properties
  @Local sensorOffsetX: number = 0;
  @Local sensorOffsetY: number = 0;
  // 接收 customContentTransition 下发的实时绘制参数 (Live rendering params from Swiper)
  @Local swiperStyles: SwiperCardStyle[] = [];
  // 视差偏移 — 从 SensorManager 的 @Trace 属性驱动
  // Navigation 路由栈 (Navigation path stack)
  private navPathStack: NavPathStack = new NavPathStack();
  // 底层服务单例引用 (Low-level service singleton references)
  private sensorMgr: SensorManager = SensorManager.getInstance();
  private audioMgr: AudioManager = AudioManager.getInstance();
  // ViewModel (MVVM 架构接入层, MVVM Integration Layer)
  // 传感器同步定时器 (Sensor sync timer)
  private sensorSyncTimer: number = -1;
  // 通过单例进行视图解耦，提供极佳的响应和复用 (ViewModel singleton pattern)
  private projectVM: ProjectViewModel = ProjectViewModel.getInstance();

  /**
   * 生命周期: 组件即将挂载
   * Lifecycle: Component about to appear
   * 初始化传感器和音频服务
   */
  aboutToAppear(): void {
    // 根据数据预初始化 Swiper 样式数组 (Pre-initialize swiper styles array based on data)
    this.swiperStyles = this.projectVM.projects.map(() => new SwiperCardStyle());

    // 1. 启动加速度计传感器 — 驱动视差 3D 效果
    // Start accelerometer sensor — drives parallax 3D effect
    this.sensorMgr.start();

    // 定时从 SensorManager 同步偏移量到 @Local
    // Sync offset from SensorManager to @Local periodically
    this.sensorSyncTimer = setInterval(() => {
      this.sensorOffsetX = this.sensorMgr.offsetX;
      this.sensorOffsetY = this.sensorMgr.offsetY;
    }, 33); // ~30fps 同步

    // 2. 初始化背景音频 (如 rawfile 中存在音频文件)
    // Initialize background audio (if audio file exists in rawfile)
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.audioMgr.init(context, 'bgm_ambient.mp3');
    } catch (e) {
      // 静默降级：没有音频文件时不影响主流程
      // Silent degradation: no audio file does not affect main flow
      console.debug(`[Index] Audio init skipped: ${e}`);
    }
  }

  /**
   * 生命周期: 组件即将销毁
   * Lifecycle: Component about to disappear
   * 释放所有底层资源
   */
  aboutToDisappear(): void {
    if (this.sensorSyncTimer !== -1) {
      clearInterval(this.sensorSyncTimer);
    }
    this.sensorMgr.stop();
    this.audioMgr.release();
  }

  build() {
    // Navigation 根容器 — 彻底废弃老旧的 router 机制
    // Navigation root — completely replaces the legacy router mechanism
    Navigation(this.navPathStack) {
      // Stack 容器: 底层粒子背景 + 主内容 + FAB
      // Stack container: particle bg (bottom) + main content + FAB (top)
      Stack({ alignContent: Alignment.BottomEnd }) {

        // ====== 第1层: Canvas 粒子流动效背景 ======
        // Layer 1: Canvas particle flow animated background
        ParticleBackground()

        // ====== 第2层: 主内容 (带视差) ======
        // Layer 2: Main content (with parallax)
        Scroll() {
          Column({ space: 24 }) {
            // 沉浸式头部 (Profile Section) — 视差偏移最大
            ProfileSection({
              offsetX: this.sensorOffsetX,
              offsetY: this.sensorOffsetY
            })

            // 能力标签区 (Skill Tags) — 中等视差
            SkillTags({
              offsetX: this.sensorOffsetX,
              offsetY: this.sensorOffsetY
            })

            // 项目经历瀑布流 (Projects Waterfall)
            this.ProjectsWaterfall()
          }
          .width('100%')
          .padding({
            top: 48,
            left: 16,
            right: 16,
            bottom: 80
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        // ====== 第3层: FAB 悬浮按钮 ======
        // Layer 3: Floating Action Button
        this.ContactFAB()
      }
      .width('100%')
      .height('100%')
    }
    .navDestination(this.pageMap)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    // 原生半模态交互 (BindSheet)
    .bindSheet(this.isShowSheet, this.ContactSheet(), {
      height: '33%',
      dragBar: true,
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.Thick, // 亚克力面板
      showClose: false,
      onDisappear: () => {
        this.isShowSheet = false;
      }
    })
  }

  /**
   * 路由映射 — 将路径名映射到对应的 NavDestination Builder
   */
  @Builder
  pageMap(name: string, param: ESObject) {
    if (name === 'ProjectDetailPage') {
      ProjectDetailPageBuilder(name, param as Object)
    }
  }

  /**
   * 项目经历瀑布流 (Projects Waterfall)
   */
  @Builder
  ProjectsWaterfall() {
    Column({ space: 16 }) {
      Text('作品集展示 (Projects)')
        .fontSize(20) // 扁平化风格加粗加大标题 (larger font for flat design)
        .fontWeight(FontWeight.Bolder)
        .fontColor(Color.White)
        .width('100%')
        .translate({ x: this.sensorOffsetX * 0.4, y: this.sensorOffsetY * 0.4 })
        .animation({ duration: 100, curve: Curve.Smooth })

      // ==========================================
      // 【高阶重构: 景深推压 叠层滑动】
      // Depth Parallax Stacked Carousel via Swiper
      // ==========================================
      Swiper() {
        ForEach(this.projectVM.projects, (item: ProjectItem, index: number) => {
          ProjectCard({
            project: item,
            onCardTap: (project: ProjectItem) => {
              this.navPathStack.pushPath({
                name: 'ProjectDetailPage',
                param: project
              }, {
                animated: true
              });
            }
          })
            .width('100%')
            .height('100%') // 铺满 Swiper Item 框
            // 应用来自于代理转换的响应式样式 (Apply reactive styles from transition proxy)
            .scale({ x: this.swiperStyles[index]?.scale ?? 1, y: this.swiperStyles[index]?.scale ?? 1 })
            .translate({ x: this.swiperStyles[index]?.transX ?? 0, y: 0 })
            .opacity(this.swiperStyles[index]?.opacity ?? 1)
            .zIndex(this.swiperStyles[index]?.zIndex ?? 1)
        }, (item: ProjectItem) => item.id)
      }
      .width('95%') // 稍稍留边，更有质感
      .height(280) // 黄金分割卡片高度
      .itemSpace(0)
      .loop(true) // 关闭首尾循环以达到绝对贴合手法的抽卡推压
      .effectMode(EdgeEffect.Spring)
      .indicator(false) // 隐藏原生小白点指示器，因为我们依赖景深本身作为物理反馈
      .cachedCount(2) // ★性能优化: MVVM预渲染防掉帧
      .customContentTransition({
        timeout: 1000,
        transition: (proxy: SwiperContentTransitionProxy) => {
          let pos = proxy.position;
          let idx = proxy.index;
          if (!this.swiperStyles[idx]) {
            return;
          }

          let scale = 1.0;
          let transX = 0;
          let opacity = 1.0;
          let zIndex = 1;

          if (pos <= 0) {
            // == 前景页面（滑出视窗左侧）==
            transX = 0;
            scale = 1.0;
            opacity = 1.0;
            zIndex = 100;
          } else {
            // == 叠加层页（排在后方等待滑入的卡片）==
            // 抵消原生横向排列的位移，使它们折叠在一起
            let offset = -pos * proxy.mainAxisLength;

            // 为每张叠在后面的卡片保留 25px 的可见边缘，制造层级感
            let visibleEdge = 25 * pos;
            transX = offset + visibleEdge;

            // 背后的卡片缩放及透明
            scale = 1 - (0.05 * pos);
            opacity = 1 - (0.2 * pos);
            zIndex = 100 - Math.ceil(pos * 10);
          }

          // 更新响应式状态 (Update reactive state)
          this.swiperStyles[idx].scale = scale;
          this.swiperStyles[idx].transX = transX;
          this.swiperStyles[idx].opacity = opacity;
          this.swiperStyles[idx].zIndex = zIndex;
        }
      })
    }
    .width('100%')
  }

  /**
   * 联系悬浮按钮 (Contact FAB)
   */
  @Builder
  ContactFAB() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.phone'))
        .fontSize(24)
        .fontColor([Color.White])
    }
    .width(56)
    .height(56)
    .backgroundColor('#0A59F7')
    .shadow({ radius: 16, color: '#660A59F7', offsetY: 6 })
    .margin({ right: 24, bottom: 36 })
    // FAB 也有微弱视差偏移 — 悬浮层感
    // FAB also has subtle parallax — floating layer feel
    .translate({ x: this.sensorOffsetX * 1.5, y: this.sensorOffsetY * 1.5 })
    .animation({ duration: 80, curve: Curve.Smooth })
    .onClick(() => {
      HapticManager.mediumPress();
      this.isShowSheet = true;
    })
  }

  /**
   * 联系方式半模态面板 (Contact Sheet)
   */
  @Builder
  ContactSheet() {
    Column({ space: 16 }) {
      Text('你好，我是哈尼 👋')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 16 })

      Text('对极致体验有着偏执的追求，期待与您交流。')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))

      // 微信二维码 — 原生 QRCode 组件
      // WeChat QR code — native QRCode component
      QRCode('WeChat: HaNi_Geek_Coder')
        .width(120)
        .height(120)
        .color('#000000')
        .backgroundColor(Color.White)
        .padding(8)
        .borderRadius(12)
        .margin({ top: 8, bottom: 8 })

      Button('一键复制邮箱')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .backgroundColor('#0A59F7')
        .width('60%')
        .shadow({ radius: 8, color: '#4D0A59F7', offsetY: 4 })
        .onClick(() => {
          HapticManager.success();
          // TODO: 集成系统剪贴板 pasteboard 能力
          // TODO: Integrate system clipboard pasteboard capability
        })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
  }
}
