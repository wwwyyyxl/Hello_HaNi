/**
 * SkillTags.ets — 能力标签区组件 (带触觉反馈)
 * Skill Tags Section Component with Haptic Feedback.
 *
 * 使用 Flex 自动换行布局展示技能标签。
 * 每个标签点击时触发线性马达微震动反馈。
 * 使用原生 backgroundBlurStyle 营造亚克力悬浮感。
 *
 * Flex wrap layout for skill tags display.
 * Each tag tap triggers linear motor micro-vibration feedback.
 * Native backgroundBlurStyle for acrylic floating effect.
 *
 * 【V2 状态管理】@ComponentV2 + @Param 接收视差数据
 */
import { HapticManager } from '../managers/HapticManager';

@ComponentV2
export struct SkillTags {
  @Param offsetX: number = 0;
  @Param offsetY: number = 0;

  @Builder
  SkillTagItem(icon: Resource, text: string, color: string) {
    Row({ space: 6 }) {
      SymbolGlyph(icon)
        .fontSize(14)
        .fontColor([color])
      Text(text)
        .fontSize(12)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .margin({ right: 8, bottom: 8 })
    .border({ width: 1, color: color, radius: 16 })
    .backgroundColor(Color.Transparent)
    .backgroundBlurStyle(BlurStyle.Thin) // 亚克力悬浮 (acrylic float)
    .onClick(() => {
      // 轻触触觉反馈 — 清脆的机械段落感
      // Light tap haptic feedback — crisp mechanical click feel
      HapticManager.lightTap();
    })
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      this.SkillTagItem($r('sys.symbol.space_1'), 'ArkUI V2', '#3B82F6')
      this.SkillTagItem($r('sys.symbol.bolt'), 'ArkTS', '#F97316')
      this.SkillTagItem($r('sys.symbol.cube_and_arrow_down'), '元服务', '#22C55E')
      this.SkillTagItem($r('sys.symbol.paperplane'), '性能极致', '#A855F7')
    }
    .width('100%')
    // 标签区视差 — 中等偏移幅度
    // Tag area parallax — medium offset amplitude
    .translate({ x: this.offsetX * 0.6, y: this.offsetY * 0.6 })
    .animation({ duration: 100, curve: Curve.Smooth })
  }
}
