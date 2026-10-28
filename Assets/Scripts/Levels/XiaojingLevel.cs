using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 孝经关卡：经纶阁中，《孝经》被四面镜子映出四重注本的灵魂。
/// 玩家先选择「跪或不跪」，再依次触碰四面镜子，集齐四字木牌，
/// 终使《孝经》放下偏执，回归「孝之本质，在心不在礼」。
/// </summary>
public class XiaojingLevel : MonoBehaviour
{
    public Button kneelButton;       // 跪下拜见
    public Button questionButton;    // 原地站立，开口发问
    public Button[] mirrorButtons;   // 4 面镜子（原本 / 汉初注 / 唐玄宗注 / 朱子注）
    public Text plaqueText;          // 木牌文字（累计浮现的字）
    public Text responseText;        // 对话反馈
    public Button completeButton;    // 集齐四字后出现的「完成」按钮
    public Button backButton;

    private string[] mirrorLabels = { "原本·色难", "汉初·谏诤", "唐注·顺时", "朱子·辨伪" };
    private string[] mirrorWords = { "色难", "谏诤", "顺时", "辨伪" };
    private string[] mirrorDialogues =
    {
        "「昔年曾子问孝，孔子曰『色难』——孝，本是对亲人体贴，而非强装恭敬。」木牌浮现「色难」二字。",
        "「父有过，当谏诤！一味顺从，是陷亲于不义！」木牌浮现「谏诤」二字。",
        "「孝者，承先启后，既要敬亲，亦要顺时势而变。」木牌浮现「顺时」二字。",
        "「圣人之言，需辨真伪！后世注疏强加之意，非《孝经》本旨。」木牌浮现「辨伪」二字。"
    };

    private bool kneeled;
    private int mirrorsTouched = 0;
    private string plaque = "";

    void Start()
    {
        kneelButton.onClick.AddListener(() => ChooseStance(true));
        questionButton.onClick.AddListener(() => ChooseStance(false));

        for (int i = 0; i < mirrorButtons.Length; i++)
        {
            int idx = i;
            Text label = mirrorButtons[i].GetComponentInChildren<Text>();
            if (label != null) label.text = mirrorLabels[i];
            mirrorButtons[i].onClick.AddListener(() => TouchMirror(idx));
        }

        completeButton.onClick.AddListener(() => LevelFlow.Complete("xiaojing"));
        backButton.onClick.AddListener(LevelFlow.BackToMap);

        // 初始状态：只显示「跪 / 不跪」两个选择
        foreach (Button b in mirrorButtons)
            b.gameObject.SetActive(false);
        completeButton.gameObject.SetActive(false);
        responseText.text = "";
        plaqueText.text = "";
    }

    void ChooseStance(bool didKneel)
    {
        kneeled = didKneel;
        kneelButton.gameObject.SetActive(false);
        questionButton.gameObject.SetActive(false);

        plaque = didKneel ? "" : "问";
        plaqueText.text = plaque;
        responseText.text = didKneel
            ? "你跪下了。《孝经》化身眼皮微抬，四面镜子的虚影同时后退半步，镜光变暗。"
            : "你站立发问。《孝经》化身身体一震，四面镜子的虚影同时前倾，镜光变亮。";

        foreach (Button b in mirrorButtons)
            b.gameObject.SetActive(true);
    }

    void TouchMirror(int idx)
    {
        if (!mirrorButtons[idx].gameObject.activeSelf) return;

        // 木牌累积浮字
        plaque = plaque.Length == 0 ? mirrorWords[idx] : plaque + " · " + mirrorWords[idx];
        plaqueText.text = plaque;
        responseText.text = mirrorDialogues[idx];
        mirrorButtons[idx].gameObject.SetActive(false);
        mirrorsTouched++;

        if (mirrorsTouched >= mirrorButtons.Length)
        {
            responseText.text = kneeled
                ? "你得了孝之「形」，却未丢质疑之心——真正的孝，从不是放弃思考的顺从。孝之本质，在心不在礼。"
                : "「变者，《易》之宗；真者，《孝》之本。」四面镜子碎裂，光点随你而行。";
            completeButton.gameObject.SetActive(true);
        }
    }
}
