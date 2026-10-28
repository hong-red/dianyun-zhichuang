using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 左传关卡：史简阁·编年迷宫。将散乱的竹简按《春秋》鲁国十二公世系
/// （隐、桓、庄、闵、僖、文、宣、成、襄、昭、定、哀）依次点选归位。
/// </summary>
public class ZuozhuanLevel : MonoBehaviour
{
    public Button[] gongButtons;   // 12 个竹简按钮（运行时打乱显示，子物体需有 Text）
    public Text promptText;        // 当前应寻哪位鲁公
    public Text feedbackText;      // 点选反馈
    public Button backButton;

    private static readonly string[] order =
    {
        "隐公", "桓公", "庄公", "闵公", "僖公", "文公",
        "宣公", "成公", "襄公", "昭公", "定公", "哀公"
    };

    private int expected = 0;

    void Start()
    {
        // 打乱竹简的显示顺序，让玩家按世系点选
        string[] shuffled = (string[])order.Clone();
        for (int i = shuffled.Length - 1; i > 0; i--)
        {
            int j = Random.Range(0, i + 1);
            string tmp = shuffled[i];
            shuffled[i] = shuffled[j];
            shuffled[j] = tmp;
        }

        for (int i = 0; i < gongButtons.Length; i++)
        {
            string gong = shuffled[i];
            Button btn = gongButtons[i];
            Text label = btn.GetComponentInChildren<Text>();
            if (label != null) label.text = gong;
            btn.onClick.AddListener(() => OnClick(gong, btn));
        }

        backButton.onClick.AddListener(LevelFlow.BackToMap);
        feedbackText.text = "";
        UpdatePrompt();
    }

    void OnClick(string gong, Button btn)
    {
        if (expected >= order.Length) return;

        if (gong == order[expected])
        {
            btn.interactable = false;   // 归位，标记为已就位
            expected++;
            feedbackText.text = gong + " 归位。";

            if (expected >= order.Length)
            {
                feedbackText.text = "鲁国十二公世系排定，《春秋》编年归序！";
                LevelFlow.Complete("zuozhuan");
            }
            else
            {
                UpdatePrompt();
            }
        }
        else
        {
            feedbackText.text = "时序未对——当前应寻「" + order[expected] + "」。";
        }
    }

    void UpdatePrompt()
    {
        if (promptText != null)
            promptText.text = "请依《春秋》世系，点选第 " + (expected + 1) + " 位鲁公";
    }
}
