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
import { ProjectCard, ProjectItem } from '../components/ProjectCard';

// Pages — NavDestination 页面 (NavDestination pages)
import { ProjectDetailPageBuilder } from '../pages/ProjectDetailPage';

@Entry
@ComponentV2
struct Index {
  /**
   * 使用 @Local 替代 V1 的 @State — 状态生命周期仅局限于组件内部
   * @Local replaces V1's @State — state lifecycle strictly within component
   */
  @Local isShowSheet: boolean = false;

  // Navigation 路由栈 (Navigation path stack)
  private navPathStack: NavPathStack = new NavPathStack();

  // 底层服务单例引用 (Low-level service singleton references)
  private sensorMgr: SensorManager = SensorManager.getInstance();
  private audioMgr: AudioManager = AudioManager.getInstance();

  // 视差偏移 — 从 SensorManager 的 @Trace 属性驱动
  // Parallax offset — driven by SensorManager's @Trace properties
  @Local sensorOffsetX: number = 0;
  @Local sensorOffsetY: number = 0;

  // 传感器同步定时器 (Sensor sync timer)
  private sensorSyncTimer: number = -1;

  // 项目数据源 (Project data source)
  @Local projects: ProjectItem[] = [
    new ProjectItem(
      'project_harmony',
      'HarmonyOS 元服务',
      '基于最新 API 12 手搓的高性能极客名片项目，体验原生交互与秒开。',
      '这是一款面向高级开发岗位面试展示的 HarmonyOS 元服务，采用全新的 ArkUI V2 状态管理范式，展现了对底层渲染、传感器联动和系统服务的深度掌控。项目特色包括：Canvas 粒子动效背景、重力感应视差交互、GeometryTransition 英雄转场动画、以及 AVPlayer 背景音频等企业级技术实践。',
      'ArkUI V2 · API 12 · Canvas',
      '#3B82F6' // 蓝色 (Blue)
    ),
    new ProjectItem(
      'project_eco',
      '原生鸿蒙生态',
      '深入实践 ArkUI V2 状态管理、WaterFlow 瀑布流及底层渲染机制。',
      '深度参与鸿蒙原生生态建设，在多个垂直领域实现了从 0 到 1 的技术攻坚。涵盖 WaterFlow 瀑布流高性能渲染、Navigation 路由架构设计、系统级传感器服务接入等核心技术点。',
      'WaterFlow · Navigation · Sensor',
      '#F97316' // 橙色 (Orange)
    ),
    new ProjectItem(
      'project_ai',
      'AI 智能体助手',
      '结合大模型能力，打造下一代智能化用户体验与极客作品集展示。',
      '融合大语言模型推理能力与 HarmonyOS 原生交互体验，构建了一套智能化的用户交互系统。支持语音识别、实时对话、以及基于上下文的智能推荐，展现了 AI 与端侧协同的前沿技术探索。',
      'LLM · ASR · HarmonyOS',
      '#22C55E' // 绿色 (Green)
    ),
  ];

  /**
   * 生命周期: 组件即将挂载
   * Lifecycle: Component about to appear
   * 初始化传感器和音频服务
   */
  aboutToAppear(): void {
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
          .padding({ top: 48, left: 16, right: 16, bottom: 80 })
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
    Column({ space: 12 }) {
      Text('作品集展示 (Projects)')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        // 文字也有微弱视差 (text also has subtle parallax)
        .translate({ x: this.sensorOffsetX * 0.4, y: this.sensorOffsetY * 0.4 })
        .animation({ duration: 100, curve: Curve.Smooth })

      WaterFlow() {
        Repeat<ProjectItem>(this.projects)
          .each((obj) => {
            FlowItem() {
              ProjectCard({
                project: obj.item,
                onCardTap: (item: ProjectItem) => {
                  // GeometryTransition 英雄转场：推入详情页
                  // Hero transition: push to detail page
                  this.navPathStack.pushPath({
                    name: 'ProjectDetailPage',
                    param: item
                  }, {
                    animated: true
                  });
                }
              })
            }
          })
          .key((item: ProjectItem) => item.id)
      }
      .columnsTemplate('1fr 1fr') // 两列瀑布流 (two-column waterfall)
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(320) // 固定高度避免 Scroll 内部布局冲突
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
