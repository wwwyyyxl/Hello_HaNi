/**
 * ProjectCard.ets — 项目卡片组件 (支持 GeometryTransition 共享元素转场)
 * Project Card Component with GeometryTransition support.
 *
 * 单个项目卡片，承载标题、描述和亚克力毛玻璃效果。
 * 点击时触发触觉反馈并通过 @Event 通知父组件发起路由导航。
 * 使用 geometryTransition(id) 实现共享元素英雄动画。
 *
 * Single project card with title, description, and acrylic blur.
 * Tap triggers haptic and notifies parent via @Event for navigation.
 * Uses geometryTransition(id) for shared-element hero animation.
 *
 * 【V2 状态管理】@Param 接收数据, @Event 向上发射事件
 */
import { HapticManager } from '../managers/HapticManager';
import { curves } from '@kit.ArkUI';

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
  @Trace color: string; // 卡片主题色 (card theme color)

  constructor(id: string, title: string, description: string, detail: string, techStack: string, color: string) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.detail = detail;
    this.techStack = techStack;
    this.color = color;
  }
}

@ComponentV2
export struct ProjectCard {
  @Param project: ProjectItem = new ProjectItem('', '', '', '', '', '');
  @Event onCardTap: (item: ProjectItem) => void = () => {};

  build() {
    Column({ space: 8 }) {
      // 顶部色块装饰条 (Top color accent bar)
      Row()
        .width(36)
        .height(4)
        .borderRadius(2)
        .backgroundColor(this.project.color)
        .margin({ bottom: 4 })

      Text(this.project.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(this.project.description)
        .fontSize(12)
        .fontColor('#B3FFFFFF')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 技术栈标签 (Tech stack tag)
      Text(this.project.techStack)
        .fontSize(10)
        .fontColor('#80FFFFFF')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.Thin) // 亚克力毛玻璃 (acrylic blur)
    .borderRadius(12)
    .shadow({ radius: 10, color: '#2A000000', offsetY: 4 })
    // 共享元素转场标识 — 匹配 ProjectDetailPage 中的 geometryTransition
    // Shared element transition ID — matches geometryTransition in ProjectDetailPage
    .geometryTransition(this.project.id, { follow: true })
    .transition(TransitionEffect.OPACITY.animation({
      duration: 350,
      curve: curves.springMotion(0.6, 0.9)
    }))
    .onClick(() => {
      // 中等按压触觉反馈 (Medium press haptic feedback)
      HapticManager.mediumPress();
      this.onCardTap(this.project);
    })
  }
}
