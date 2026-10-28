using UnityEngine;

/// <summary>
/// 论语关卡：以「礼、乐、射、御、书、数」六艺为脉络，
/// 与《论语》一问一答，终使「六艺贯通」。
/// </summary>
public class LunyuLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "lunyu";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "礼·揖让。《论语》：「你揖我让，谁先谁后？」",
            options = new string[] { "我先，敬主人", "您先，尊长者", "不知先后，故让" },
            responses = new string[] { "敬在先后之外。", "尊在揖让之中。", "让，礼之主也。克己复礼，克此先后之执。" }
        },
        new Round
        {
            question = "乐·弦歌。《论语》：「《诗》三百，一言以蔽之，曰……」",
            options = new string[] { "思无邪", "和为贵", "温柔敦厚" },
            responses = new string[] { "✓ 「《诗》三百，一言以蔽之，曰：思无邪。」", "「和为贵」出自《论语·学而》，论礼之用。", "「温柔敦厚」出自《礼记·经解》，论诗教。" }
        },
        new Round
        {
            question = "射·投壶。射礼之要，在何？",
            options = new string[] { "中的为上", "揖让而升，下而饮", "力贯金石" },
            responses = new string[] { "君子之争，不在中的。", "✓ 「君子无所争，必也射乎！揖让而升，下而饮。」", "此非礼射之旨。" }
        },
        new Round
        {
            question = "御·轼车。驾车之礼，「车中」当如何？",
            options = new string[] { "不内顾，不亲指", "登车四顾，纵观风景", "疾驰以先至" },
            responses = new string[] { "✓ 「升车，必正立执绥，车中不内顾。」", "失礼，升车当正立执绥。", "非礼也。" }
        },
        new Round
        {
            question = "书·漆书。《论语》：「述而不作」，何解？",
            options = new string[] { "只转述，不创作", "信而好古，不自作聪明", "只口传，不著书" },
            responses = new string[] { "非此解。", "✓ 「述而不作，信而好古」——传承而不妄造。", "非此解。" }
        },
        new Round
        {
            question = "数·洛书。有人问以蓍草占卜吉凶，孔子会如何？",
            options = new string[] { "为之一占", "务民之义，敬鬼神而远之", "斥为迷信" },
            responses = new string[] { "非夫子所为。", "✓ 「务民之义，敬鬼神而远之，可谓知矣。」", "非夫子之态。" }
        }
    };
}
