using UnityEngine;

/// <summary>
/// 周礼关卡：礼域复兴，需重建六官。玩家辨明天、地、春、夏、秋、冬六官职责，
/// 依次任命，终使「六官归位」。
/// </summary>
public class ZhouliLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "zhouli";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "礼域复兴，需重建六官。「总领百官，统御朝政」者，是哪一官？",
            options = new string[] { "天官冢宰", "地官司徒", "春官宗伯" },
            responses = new string[] { "✓ 天官冢宰掌邦治，统百官、均四海。", "地官司徒掌邦教，安民教化，非总领百官。", "春官宗伯掌邦礼，主持祭祀典礼。" }
        },
        new Round
        {
            question = "「掌土地与邦教，安养百姓」者，是哪一官？",
            options = new string[] { "地官司徒", "夏官司马", "秋官司寇" },
            responses = new string[] { "✓ 地官司徒掌邦教，敷五典、扰兆民。", "夏官司马掌邦政，统六师、平邦国。", "秋官司寇掌邦禁，刑邦国、诘奸慝。" }
        },
        new Round
        {
            question = "「掌邦礼，主持祭祀典礼」者，是哪一官？",
            options = new string[] { "春官宗伯", "天官冢宰", "冬官考工记" },
            responses = new string[] { "✓ 春官宗伯掌邦礼，治神人、和上下。", "天官冢宰掌邦治，统百官。", "冬官考工记掌百工，造作器物。" }
        },
        new Round
        {
            question = "「掌邦政，统领六军征战」者，是哪一官？",
            options = new string[] { "夏官司马", "地官司徒", "春官宗伯" },
            responses = new string[] { "✓ 夏官司马掌邦政，统六师、平邦国。", "地官司徒掌邦教，安民教化。", "春官宗伯掌邦礼，主持祭祀。" }
        },
        new Round
        {
            question = "「掌邦禁，刑狱纠察」者，是哪一官？",
            options = new string[] { "秋官司寇", "天官冢宰", "夏官司马" },
            responses = new string[] { "✓ 秋官司寇掌邦禁，刑邦国、诘奸慝。", "天官冢宰掌邦治，统百官。", "夏官司马掌邦政，统六师。" }
        },
        new Round
        {
            question = "「掌百工，造作器物」者，是哪一官？",
            options = new string[] { "冬官考工记", "秋官司寇", "地官司徒" },
            responses = new string[] { "✓ 冬官考工记掌百工，审曲面势、以饬五材。", "秋官司寇掌邦禁，刑狱纠察。", "地官司徒掌邦教，安民教化。" }
        }
    };
}
