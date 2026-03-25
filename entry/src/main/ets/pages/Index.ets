import { util } from "@kit.ArkTS";

// 需求1标注推送消息：（你好AI，在这里加上，我会查阅在提交）

/**
 * 采用 ArkUI V2 状态管理范式。
 * @ObservedV2 和 @Trace 提供细粒度、深层次的状态监听。
 * 相较于 V1，可以大幅减少不必要的全量组件刷新和深层 Proxy 开销，提升性能。
 *
 * V2 State Management: @ObservedV2 and @Trace provide fine-grained reactivity.
 * Compared to V1, it avoids full-tree re-renders and proxy overhead, optimizing performance.
 */
@ObservedV2
class ProjectItem {
  @Trace id: string = util.generateRandomUUID(true);
  @Trace title: string;
  @Trace description: string;

  constructor(title: string, description: string) {
    this.title = title;
    this.description = description;
  }
}

@Entry
@ComponentV2
struct Index {
  /**
   * 使用 @Local 替代 V1 的 @State，状态生命周期仅局限于组件内部。
   * Using @Local replaces @State from V1, confining state strictly to the local component.
   */
  @Local projects: ProjectItem[] = [
    new ProjectItem(
      "HarmonyOS 元服务",
      "基于最新 API 12 手搓的高性能极客名片项目，体验原生交互与秒开。",
    ),
    new ProjectItem("原生鸿蒙生态", "深入实践 ArkUI V2 状态管理、WaterFlow 瀑布流及底层渲染机制。"),
    new ProjectItem("AI 智能体助手", "结合大模型能力，打造下一代智能化用户体验与极客作品集展示。"),
  ];

  build() {
    // 使用 Stack 容器将主内容与底部的悬浮按钮（FAB）分离
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 24 }) {
        // 1. 沉浸式头部 (Profile Section)
        this.ProfileSection()

        // 2. 能力标签区 (Skill Tags)
        this.SkillTags()

        // 3. 项目经历瀑布流 (Projects Waterfall)
        this.ProjectsWaterfall()
      }
      .width("100%")
      .height("100%")
      .padding({ top: 40, left: 16, right: 16 })
      // 原生内置颜色背景，完美适配系统暗黑/明亮模式
      .backgroundColor($r("sys.color.background_primary"))

      // 4. 底层联系悬浮按钮 (Contact FAB)
      this.ContactFAB()
    }
    .width("100%")
    .height("100%");
  }

  @Builder
  ProfileSection() {
    Column({ space: 12 }) {
      // 头部占位区
      Stack() {
        Circle({ width: 88, height: 88 }).fill("#0A59F7") // 鸿蒙蓝 (HarmonyOS Blue)

        // 使用原生的 SymbolGlyph 具有极高渲染效率。它利用系统底层矢量图渲染，避免了外部位图(Bitmap)带来的内存与 IO 开销。
        // Native SymbolGlyph uses vector graphics natively rendered by the system, avoiding memory overhead of bitmaps.
        SymbolGlyph($r("sys.symbol.person"))
          .fontSize(48)
          .fontColor([Color.White])
      }

      Text("哈尼 (HaNi)")
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("sys.color.font_primary"))
      Text("高级 HarmonyOS 开发工程师 | 极客")
        .fontSize(14)
        .fontColor($r("sys.color.font_secondary"))
    }
    .width("100%")
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  SkillTags() {
    Flex({ wrap: FlexWrap.Wrap }) {
      this.SkillTagItem($r("sys.symbol.space_1"), "ArkUI V2", "#0A59F7")
      this.SkillTagItem($r("sys.symbol.bolt"), "ArkTS", "#FF5500")
      this.SkillTagItem($r("sys.symbol.cube_and_arrow_down"), "元服务", "#00A854")
      this.SkillTagItem($r("sys.symbol.paperplane"), "性能极致", "#722ED1")
    }.width("100%");
  }

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
    .padding({
      left: 10,
      right: 10,
      top: 6,
      bottom: 6
    })
    .margin({ right: 8, bottom: 8 })
    .border({ width: 1, color: color, radius: 16 })
    .backgroundColor($r("sys.color.background_secondary"));
  }

  @Builder
  ProjectsWaterfall() {
    Column({ space: 12 }) {
      Text("作品集展示 (Projects)")
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("sys.color.font_primary"))
        .width("100%")
      WaterFlow() {
        // 使用 V2 范式的 Repeat 替代旧版 ForEach，实现高性能渲染机制
        Repeat<ProjectItem>(this.projects)
          .each((obj) => {
            FlowItem() {
              Column({ space: 8 }) {
                Text(obj.item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r("sys.color.font_primary"))
                Text(obj.item.description)
                  .fontSize(12)
                  .fontColor($r("sys.color.font_secondary"))
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .padding(16)
              .width("100%")
              .backgroundColor($r("sys.color.background_primary"))
              .borderRadius(12)
              .shadow({ radius: 10, color: "#0D000000", offsetY: 4 })
              .onClick(() => {
                // TODO: 预留路由跳转逻辑占位
                // Router placeholder for navigating to project details
                // router.pushUrl({ url: 'pages/ProjectDetail' })
              })
            };
          })
          .key((item: ProjectItem) => item.id)
      }
      .columnsTemplate("1fr 1fr")
      // 瀑布流两列布局
      .columnsGap(12)
      .rowsGap(12)
      .width("100%")
      .layoutWeight(1)
    }
    // 占满剩余可用空间
    .width("100%")
    .layoutWeight(1);
  }

  @Builder
  ContactFAB() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r("sys.symbol.phone"))
        .fontSize(24)
        .fontColor([Color.White])
    }
    .width(56)
    .height(56)
    .backgroundColor("#0A59F7")
    .shadow({ radius: 12, color: "#4D0A59F7", offsetY: 6 })
    .margin({ right: 24, bottom: 36 })
    .onClick(() => {
      // TODO: 弹出联系方式（可配合 BindSheet 或 CustomDialog）
    });
  }
}
