/**
 * ProjectCard.ets — 项目卡片组件 (基于 MVVM + 扁平化设计)
 * Project Card Component with Flat Design and GeometryTransition support.
 *
 * 扁平化重构：采用了纯粹的底层颜色填充、更平滑的圆角，剥离了亚克力与阴影。
 * 物理交互强化：通过 @Local 状态监控 onTouch，结合 springMotion 实现丝滑的按压形变回弹。
 *
 * 【V2 状态管理】@Param 接收数据, @Event 向上发射事件
 */
import { HapticManager } from '../managers/HapticManager';
import { curves } from '@kit.ArkUI';

// 从 ViewModel 引入数据结构，解耦渲染树与模型定义
import { ProjectItem } from '../viewmodel/ProjectViewModel';

@ComponentV2
export struct ProjectCard {
  @Param project: ProjectItem = new ProjectItem('', '', '', '', '', '');
  @Event onCardTap: (item: ProjectItem) => void = () => {};

  // 新增物理按压状态 (Physical press state)
  @Local isPressed: boolean = false;

  build() {
    Column({ space: 8 }) {
      // 顶部亮色装饰条，在纯色背景上用半透明白色形成高对比度极简点缀
      // Top light accent bar, contrasting nicely on the solid colorful background
      Row()
        .width(36)
        .height(4)
        .borderRadius(2)
        .backgroundColor('#66FFFFFF') // 半透明白色 (Semi-transparent white)
        .margin({ bottom: 4 })

      Text(this.project.title)
        .fontSize(18) // 稍微增大字号增强扁平化海报感 (Increase font size slightly)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(this.project.description)
        .fontSize(13)
        .fontColor('#E6FFFFFF') // 提高描述文字纯度 (Increase description purity)
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank() // 撑开空间，将技术标签推到版面底部

      // 技术栈标签 (Tech stack tag)
      Text(this.project.techStack)
        .fontSize(11)
        .fontColor('#CCFFFFFF')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(20)
    .width('100%')
    .height('100%') // 铺页面高度，以被外层 Swiper 和 aspectRatio 完美控制
    // 扁平化美学：采用极具冲击力的大色块进行填充 (Flat aesthetics: large solid colors)
    .backgroundColor(this.project.color) 
    .borderRadius(24) // 增大圆角，看起来更加现代化 (Larger modern border radius)
    // 根据按压状态动态反馈，配合弹簧动画
    .scale({ x: this.isPressed ? 0.94 : 1, y: this.isPressed ? 0.94 : 1 })
    .animation({ duration: undefined, curve: curves.springMotion(0.6, 0.9) })
    // 共享元素转场标识
    .geometryTransition(this.project.id, { follow: true })
    .transition(TransitionEffect.OPACITY.animation({
      duration: 350,
      curve: curves.springMotion(0.6, 0.9)
    }))
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      // 中等按压触觉反馈 (Medium press haptic feedback)
      HapticManager.mediumPress();
      this.onCardTap(this.project);
    })
  }
}
