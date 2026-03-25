/**
 * ProjectDetailPage.ets — 项目详情页 (NavDestination)
 * Project Detail Page as NavDestination.
 *
 * 通过 Navigation + NavPathStack 路由到达。
 * 配合 geometryTransition 实现从卡片到全屏的共享元素英雄转场动画。
 * Spring 弹性曲线 (responsiveSpringMotion) 呈现极致丝滑动效。
 *
 * Accessed via Navigation + NavPathStack routing.
 * Paired with geometryTransition for card-to-fullscreen hero animation.
 * Uses Spring curve (responsiveSpringMotion) for ultra-smooth transitions.
 *
 * 【V2 状态管理】@ComponentV2 + @Local 管理页面内部状态
 */
import { ProjectItem } from '../components/ProjectCard';
import { HapticManager } from '../managers/HapticManager';
import { curves } from '@kit.ArkUI';

@Builder
export function ProjectDetailPageBuilder(name: string, param: Object) {
  ProjectDetailPage({ project: param as ProjectItem })
}

@Entry
@ComponentV2
export struct ProjectDetailPage {
  @Param project: ProjectItem = new ProjectItem('', '', '', '', '', '');

  build() {
    NavDestination() {
      Column() {
        // 顶部渐变色块 — 与卡片主题色一致，营造视觉连续性
        // Top gradient block — matches card theme color for visual continuity
        Column() {
          // 返回按钮区 (Back button area)
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor([Color.White])
              .onClick(() => {
                HapticManager.lightTap();
                // 通过 NavPathStack 返回
                // Navigate back via NavPathStack (handled by parent)
              })
            Blank()
          }
          .width('100%')
          .padding({ top: 12, left: 8, right: 16 })

          Blank()

          // 项目标题 (Project title)
          Column({ space: 8 }) {
            Text(this.project.title)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text(this.project.techStack)
              .fontSize(14)
              .fontColor('#B3FFFFFF')
              .padding({
                left: 10,
                right: 10,
                top: 4,
                bottom: 4
              })
              .border({ width: 1, color: '#4DFFFFFF', radius: 12 })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 24, right: 24, bottom: 24 })
        }
        .width('100%')
        .height('35%')
        .linearGradient({
          angle: 180,
          colors: [
            [this.project.color, 0.0],
            ['#0F172A', 1.0]
          ]
        })
        // 共享元素转场 — ID 与 ProjectCard 匹配
        // Shared element transition — ID matches ProjectCard
        .geometryTransition(this.project.id, { follow: true })
        .transition(TransitionEffect.OPACITY.animation({
          duration: 350,
          curve: curves.springMotion(0.6, 0.9)
        }))

        // 详情内容区 (Detail content area)
        Scroll() {
          Column({ space: 20 }) {
            // 项目简介 (Project description)
            this.SectionCard('项目简介', this.project.description)

            // 项目详情 (Project details)
            this.SectionCard('深入了解', this.project.detail)

            // 技术亮点 (Technical highlights)
            this.SectionCard('技术亮点',
              `基于 ${this.project.techStack} 技术栈构建，采用 ArkUI V2 状态管理范式，实现高性能渲染与极致用户体验。`)
          }
          .padding({
            left: 20,
            right: 20,
            top: 20,
            bottom: 40
          })
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring) // 弹性边缘效果 (spring edge effect)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0F172A') // 暗夜底色 (dark night base)
    }
    .hideTitleBar(true)
  }

  @Builder
  SectionCard(title: string, content: string) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(content)
        .fontSize(14)
        .fontColor('#CCFFFFFF')
        .lineHeight(22)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(20)
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetY: 4 })
  }
}
