using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 对话式关卡基类：一轮一轮展示「问题 + 若干选项 + 回应」，全部完成后过关。
/// 适合以「问与答 / 抉择 / 思辨」为核心的关卡（周易、周礼、仪礼、礼记、论语、尔雅、孟子等）。
///
/// 每个子类只需提供两样东西：
///   CompletedPinyin —— 过关时标记的 IP 拼音；
///   Rounds          —— 全部轮次的内容（问题、选项、回应）。
///
/// Round.responses 若只给 1 条，则所有选项共用同一条回应；否则按选项下标各取一条。
/// </summary>
public abstract class DialogueLevelBase : MonoBehaviour
{
    /// <summary>一轮对话：一个问题 + 若干选项 + 每条选项对应的回应。</summary>
    public class Round
    {
        public string question;
        public string[] options;
        public string[] responses;
    }

    public Text questionText;         // 问题文字
    public Text responseText;         // 回应文字
    public Text progressText;         // 进度文字（可选，如「第 1 / 8 重」）
    public Button[] optionButtons;    // 选项按钮（子物体需有 Text）
    public Button nextButton;         // 选完后出现的「继续」按钮
    public Button backButton;         // 返回地图按钮（可留空）

    protected abstract string CompletedPinyin { get; }
    protected abstract Round[] Rounds { get; }

    private int current;

    void Start()
    {
        for (int i = 0; i < optionButtons.Length; i++)
        {
            int idx = i;
            optionButtons[i].onClick.AddListener(() => Choose(idx));
        }

        nextButton.onClick.AddListener(Next);
        if (backButton != null)
            backButton.onClick.AddListener(LevelFlow.BackToMap);

        responseText.text = "";
        nextButton.gameObject.SetActive(false);
        ShowRound(0);
    }

    void ShowRound(int i)
    {
        Round r = Rounds[i];
        current = i;

        questionText.text = r.question;
        if (progressText != null)
            progressText.text = "第 " + (i + 1) + " / " + Rounds.Length + " 重";

        for (int k = 0; k < optionButtons.Length; k++)
        {
            bool has = k < r.options.Length;
            optionButtons[k].gameObject.SetActive(has);
            if (has)
            {
                Text label = optionButtons[k].GetComponentInChildren<Text>();
                if (label != null) label.text = r.options[k];
            }
        }

        responseText.text = "";
        nextButton.gameObject.SetActive(false);
    }

    void Choose(int idx)
    {
        Round r = Rounds[current];
        string resp = "";
        if (r.responses != null && r.responses.Length > 0)
        {
            if (r.responses.Length == 1)
                resp = r.responses[0];
            else if (idx < r.responses.Length)
                resp = r.responses[idx];
        }
        responseText.text = resp;

        foreach (Button b in optionButtons)
            b.gameObject.SetActive(false);
        nextButton.gameObject.SetActive(true);
    }

    void Next()
    {
        if (current + 1 >= Rounds.Length)
        {
            LevelFlow.Complete(CompletedPinyin);
            return;
        }
        ShowRound(current + 1);
    }
}
