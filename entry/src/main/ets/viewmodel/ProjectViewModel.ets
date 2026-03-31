/**
 * ProjectViewModel.ets - MVVM 模式下的数据管理层
 * 隔离了视图 (View) 与数据状态 (Model)，提供极致的响应式与可复用性。
 * 【V2 状态管理】全面采用 @ObservedV2 与 @Trace 分级观测。
 */

/**
 * 项目数据模型 — 细粒度追踪
 * Project data model with fine-grained tracking
 */
@ObservedV2
export class ProjectItem {
  @Trace id: string;
  @Trace title: string;
  @Trace description: string;
  @Trace detail: string;
  @Trace techStack: string;
  @Trace color: string; // 扁平化主色块颜色 (Flat theme color)

  constructor(id: string, title: string, description: string, detail: string, techStack: string, color: string) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.detail = detail;
    this.techStack = techStack;
    this.color = color;
  }
}

/**
 * 视图聚合模型
 * aggregates states and logic for the Project showcase area
 */
@ObservedV2
export class ProjectViewModel {
  private static instance: ProjectViewModel;

  @Trace projects: ProjectItem[] = [];

  private constructor() {
    this.loadData();
  }

  // 单例模式，保证全局数据唯一性 (Singleton ensures global state uniqueness)
  public static getInstance(): ProjectViewModel {
    if (!ProjectViewModel.instance) {
      ProjectViewModel.instance = new ProjectViewModel();
    }
    return ProjectViewModel.instance;
  }

  // 模拟从本地或服务器装载数据
  private loadData() {
    this.projects = [
      new ProjectItem(
        'project_harmony',
        'HarmonyOS 元服务',
        '基于最新 API 12 手搓的高性能极客名片项目，体验原生交互与秒开。',
        '这是一款面向高级开发岗位面试展示的 HarmonyOS 元服务，采用全新的 ArkUI V2 状态管理范式，展现了对底层渲染、传感器联动和系统服务的深度掌控。项目特色包括：Canvas 粒子动效背景、重力感应视差交互、GeometryTransition 英雄转场动画、以及 AVPlayer 背景音频等企业级技术实践。',
        'ArkUI V2 · API 12 · Canvas',
        '#3B82F6' // 蓝色 (Blue) - 大面积纯色渲染
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
  }
}
