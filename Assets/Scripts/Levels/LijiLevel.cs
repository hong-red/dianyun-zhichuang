using UnityEngine;

/// <summary>
/// 礼记关卡：阐发礼之义理。面对具体伦理困境，从《大学》《中庸》中寻找调和之道，
/// 终使「通经致用」。
/// </summary>
public class LijiLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "liji";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "父亲偷了邻家的羊，为子者该举报，还是隐瞒？",
            options = new string[] { "举报，法大于情", "隐瞒，亲亲为大", "隐而不纵：私下劝父归还改过" },
            responses = new string[] { "失之过刚。", "失之偏私。", "✓ 《中庸》云「发而皆中节谓之和」——亲亲与守法可两全。" }
        },
        new Round
        {
            question = "家贫，祭祀从简，还是铺张以彰诚敬？",
            options = new string[] { "从简，俭者礼之本", "铺张，以彰诚敬", "废止，形式不重要" },
            responses = new string[] { "✓ 《礼记》云「礼，与其奢也，宁俭」。", "奢则僭，非礼之本。", "礼不可废，俭而不废方为道。" }
        },
        new Round
        {
            question = "时代变迁，礼当恪守古制，还是因时损益？",
            options = new string[] { "恪守古制，不可轻变", "礼时为大，可因时损益", "弃礼从新，全盘更张" },
            responses = new string[] { "泥古而不知变。", "✓ 《礼记·礼器》云「礼，时为大」——礼当随时而宜。", "弃本而失其根。" }
        }
    };
}
