using UnityEngine;

/// <summary>
/// 仪礼关卡：重形式与仪节，玩家按正确时序完成冠、婚、祭三礼，终使「正名定分」。
/// </summary>
public class YiliLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "yili";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "士冠礼，成人加冠的正确时序是？",
            options = new string[] { "筮日→筮宾→三加→命字", "三加→筮日→筮宾→命字", "筮宾→筮日→命字→三加" },
            responses = new string[] { "✓ 先占吉日、择正宾，再三加冠，最后命字成礼。", "时序颠倒：筮日、筮宾应在加冠之前。", "时序未对：三加应在命字之前。" }
        },
        new Round
        {
            question = "士昏礼「六礼」：纳采、问名之后，紧接着是？",
            options = new string[] { "纳吉", "纳征", "请期" },
            responses = new string[] { "✓ 六礼顺序：纳采、问名、纳吉、纳征、请期、亲迎。", "纳征在纳吉之后。", "请期在纳征之后。" }
        },
        new Round
        {
            question = "祭祀之前，古人必先洁净身心，称为？",
            options = new string[] { "斋戒", "灌礼", "奠献" },
            responses = new string[] { "✓ 「斋戒沐浴，则可以祀上帝」——先洁净身心，方敢事神。", "灌礼是祭祀中的降神之仪，非事前洁净。", "奠献是祭祀中的献祭环节。" }
        }
    };
}
