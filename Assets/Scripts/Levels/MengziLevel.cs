using UnityEngine;

/// <summary>
/// 孟子关卡：世人把孟子固化为「好辩、性善、民贵」三枚标签，
/// 玩家以真问剥落标签，助孟子直视本真。
/// </summary>
public class MengziLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "mengzi";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "世人说你「好辩」。你为何而辩？",
            options = new string[] { "为胜人之口", "予岂好辩哉？予不得已也", "为博取声名" },
            responses = new string[] { "非也。", "✓ 《孟子·滕文公下》：「予岂好辩哉？予不得已也。」", "非也。" }
        },
        new Round
        {
            question = "你说「性善」。若人性本善，恶从何来？",
            options = new string[] { "恶是后天失养，陷溺其心", "性本无善恶", "性本恶" },
            responses = new string[] { "✓ 《孟子·告子上》：「人性之善也，犹水之就下也。」", "非孟子之论。", "荀子之言，非孟子。" }
        },
        new Round
        {
            question = "你说「民贵君轻」。此语何解？",
            options = new string[] { "民为贵，社稷次之，君为轻", "君为贵，民为轻", "君臣皆贵，民最轻" },
            responses = new string[] { "✓ 《孟子·尽心下》：「民为贵，社稷次之，君为轻。」", "反孟子本义。", "非孟子之论。" }
        }
    };
}
