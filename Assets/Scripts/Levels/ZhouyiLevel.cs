using UnityEngine;

/// <summary>
/// 周易关卡：观复山八层，历代注本将《周易》撕裂为八片碎片，
/// 玩家逐层调和八种思想，最终「八易归一」。
/// </summary>
public class ZhouyiLevel : DialogueLevelBase
{
    protected override string CompletedPinyin => "zhouyi";

    protected override Round[] Rounds => new Round[]
    {
        new Round
        {
            question = "观复山门，雾起茫茫，无上下左右。八片碎片各据一层。你为何而来？",
            options = new string[] { "为寻一个完整的《周易》", "为让八种思想各归其位", "为问清我自己是谁" },
            responses = new string[] { "山门开。第一层回声：「他们都说懂我，后来，他们为了谁更懂我，打了起来。」你记下自己的初心。" }
        },
        new Round
        {
            question = "第二层·朴拙（郑玄注本）。汉代宫室，礼器森严排列。郑玄问：「祭祀之礼，繁则难行，简则不敬。你当如何？」",
            options = new string[] { "依古礼，三十六步一步不差", "礼之本在敬，不在繁", "先问：这些礼器为何而设" },
            responses = new string[] { "郑玄注本长叹：「我之繁琐，是对礼崩乐坏的恐惧。」" }
        },
        new Round
        {
            question = "第三层·玄思（王弼注本）。竹林虚空，万物流动。王弼的声音若有若无：「得意忘言，可得道乎？」",
            options = new string[] { "追问：言外之意，如何可得？", "意会：道不可言传", "不答，静观万物流动" },
            responses = new string[] { "王弼注本低语：「忘象者，乃得意者也。」他的提示永远抽象，正如流水。" }
        },
        new Round
        {
            question = "第四层·理窟（程朱注本）。宋代书院，万卷藏书自成迷宫。程朱问：「今日格一物，明日格一物，格物可致知否？」",
            options = new string[] { "理在物中，格物即穷理", "理在吾心，何必外求", "读书千卷，自成一体" },
            responses = new string[] { "程朱颔首：「即物而穷其理。」你在书库深处，格出一本被遗忘的书。" }
        },
        new Round
        {
            question = "第五层·权威（阮元《十三经注疏》）。清代官署，匾额高悬。阮元正襟危坐：「注疏之繁，如锁链加身。你如何看待？」",
            options = new string[] { "注疏越多，愈失本义", "注疏是桥，不是锁", "找到他年轻时的《经籍纂诂》手稿" },
            responses = new string[] { "阮元见到手稿，长叹：「原来我早已背叛了我自己。」锁链应声而断。" }
        },
        new Round
        {
            question = "第六层·精工（南宋八行本）。刻书工坊，刀笔如飞。八行本问：「校书刻书，可容一丝错误？」",
            options = new string[] { "一字不苟，务必精校", "留一处错，让后人有迹可循", "尽信书，不如无书" },
            responses = new string[] { "八行本微笑：「刻书如刻心。」你留下一处无伤大雅的讹字，他说这便是「阙疑」。" }
        },
        new Round
        {
            question = "第七层·调和（孔颖达《周易正义》）。唐代朝堂，群臣各执一端。孔颖达问：「众说纷纭，谁是谁非？」",
            options = new string[] { "择一而从", "诸说并存，各安其位", "同时点选三个极端之见" },
            responses = new string[] { "孔颖达苦笑：「《正义》不是没有观点，而是不敢说。」你同时点亮三说，堂中豁然开朗。" }
        },
        new Round
        {
            question = "第八层·孤诣（吕祖谦古周易复原本）。废墟中的祭坛，星空倒悬。吕祖谦问：「最后一层没有标准答案。若天道与你所愿相违，你守何物？」",
            options = new string[] { "守我心之所安", "守万物之悲悯", "不占不卜，凭本心而行" },
            responses = new string[] { "吕祖谦道：「不依占卜，方见本心。」星空归位，八片碎片齐齐发光。" }
        }
    };
}
