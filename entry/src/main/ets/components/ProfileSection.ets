/**
 * ProfileSection.ets — 沉浸式头部个人资料组件
 * Immersive Profile Header Section Component.
 *
 * 从 Index.ets 中提取为独立可复用组件。
 * 接收视差偏移量 (@Param) 实现重力感应 3D 悬浮效果。
 *
 * Extracted from Index.ets as a standalone reusable component.
 * Receives parallax offset via @Param for gravity-driven 3D float effect.
 *
 * 【V2 状态管理】@Param 用于父组件单向数据传递
 */

@ComponentV2
export struct ProfileSection {
  /**
   * 视差偏移量 — 由父组件传入的传感器数据驱动
   * Parallax offsets — driven by sensor data passed from parent
   */
  @Param offsetX: number = 0;
  @Param offsetY: number = 0;

  build() {
    Column({ space: 12 }) {
      // 头像占位区 — 鸿蒙蓝圆形 + 原生矢量人形图标
      // Avatar placeholder — HarmonyOS blue circle + native vector person icon
      Stack() {
        Circle({ width: 88, height: 88 })
          .fill('#0A59F7') // 鸿蒙蓝 (HarmonyOS Blue)
          .shadow({ radius: 20, color: '#660A59F7', offsetY: 8 }) // 蓝色辉光阴影 (blue glow shadow)

        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(48)
          .fontColor([Color.White])
      }
      // 头像区视差偏移 — 更大的偏移幅度营造前景悬浮感
      // Avatar parallax: larger offset for foreground float effect
      .translate({ x: this.offsetX * 1.2, y: this.offsetY * 1.2 })
      .animation({ duration: 100, curve: Curve.Smooth })

      Text('哈尼 (HaNi)')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .translate({ x: this.offsetX * 0.8, y: this.offsetY * 0.8 })
        .animation({ duration: 100, curve: Curve.Smooth })

      Text('高级 HarmonyOS 开发工程师 | 极客')
        .fontSize(14)
        .fontColor('#B3FFFFFF')
        .translate({ x: this.offsetX * 0.5, y: this.offsetY * 0.5 })
        .animation({ duration: 100, curve: Curve.Smooth })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
