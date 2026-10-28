using UnityEngine;

/// <summary>
/// 尔雅关卡：万物失名、草木错位。玩家以精准命名匡正名物，
/// 终使「名物归位」。
/// </summary>
public class EryaLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "erya";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "「采采芣苢，薄言采之」——《诗经》所咏，此草是？",
            options = new string[] { "芣苢（车前草）", "卷耳", "薇" },
            responses = new string[] { "✓ 芣苢，即车前草。《尔雅》正名「芣苢」。", "卷耳是另一种草，「采采卷耳」另有其篇。", "薇是野菜，「言采其薇」另有其篇。" }
        },
        new Round
        {
            question = "「采采卷耳，不盈顷筐」——此草是？",
            options = new string[] { "卷耳", "芣苢", "薇" },
            responses = new string[] { "✓ 卷耳，可入药，今名苍耳。", "芣苢即车前草，非卷耳。", "薇是野豌豆，非卷耳。" }
        },
        new Round
        {
            question = "「陟彼南山，言采其薇」——此草是？",
            options = new string[] { "薇（野豌豆）", "芣苢", "卷耳" },
            responses = new string[] { "✓ 薇，即野豌豆，伯夷、叔齐采薇而食。", "芣苢即车前草，非薇。", "卷耳即苍耳，非薇。" }
        },
        new Round
        {
            question = "「关关雎鸠，在河之洲」——雎鸠属于？",
            options = new string[] { "水鸟", "猛禽", "走兽" },
            responses = new string[] { "✓ 雎鸠为水鸟，挚而有别，故以兴淑女君子。", "雎鸠非猛禽。", "雎鸠非走兽。" }
        },
        new Round
        {
            question = "「父曰考，母曰妣」——这是《尔雅》哪一篇的分类？",
            options = new string[] { "释亲", "释天", "释宫" },
            responses = new string[] { "✓ 《尔雅·释亲》释亲属称谓：父曰考，母曰妣。", "释天释天文时令。", "释宫释宫室建筑。" }
        }
    };
}
