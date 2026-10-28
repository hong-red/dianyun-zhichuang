using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 尚书关卡：先穿越庄园寻找三枚「心灵钥匙」碎片，再与隐居的《尚书》对话，
/// 用真诚说服他重出江湖。前半为收集，后半为三回合说服。
/// </summary>
public class ShangshuLevel : MonoBehaviour
{
    public GameObject[] keyFragments;   // 3 枚心灵钥匙碎片（每个需有 Button）
    public Text countText;              // 显示已找到的钥匙数
    public Button persuadeButton;       // 集齐 3 枚后出现的「说服尚书」按钮
    public GameObject persuasionPanel;  // 说服对话区（含下面 4 个 UI，初始隐藏）
    public Text questionText;
    public Button[] optionButtons;      // 3 个选项
    public Text responseText;
    public Button nextButton;
    public Button backButton;

    private string[] questions =
    {
        "《尚书》：「朝廷已疑我，我为何还要出山？」",
        "《尚书》：「我性格孤傲，只会以直谏招祸。」",
        "《尚书》：「遗忘之影已至，我一人出山，又有何用？」"
    };

    private string[][] options =
    {
        new string[] { "为天下百姓，非为朝廷", "为还你一世清名", "为报周易挚友之情" },
        new string[] { "直谏，正是你无可替代之处", "你可退一步，明哲保身", "治世，正需你这样的诤臣" },
        new string[] { "你不是一人，十三经将聚", "一人先出，众人方随", "若无你，政令谁定？" }
    };

    private string[][] responses =
    {
        new string[] { "尚书神色微动：「天下……百姓。你说的是。」一枚心灵钥匙松动。", "尚书摇头：「清名于我，已如浮云。」但眼中多了一分温度。", "尚书低叹：「他，也难啊……」一枚心灵钥匙松动。" },
        new string[] { "尚书目光一凛：「诤臣不死于诤，死于无诤。」第二枚钥匙松动。", "尚书冷笑：「明哲保身？那便不是我了。」但怒气中透出动摇。", "尚书沉吟：「治世，需诤臣……」第二枚钥匙松动。" },
        new string[] { "「十三经将聚……好。」尚书起身。三枚心灵钥匙齐鸣。", "「我先出山，为众人作引。」尚书起身。三枚心灵钥匙齐鸣。", "「政令无人可定，国将不国。」尚书起身。三枚心灵钥匙齐鸣。" }
    };

    private int collected = 0;
    private int round = 0;

    void Start()
    {
        for (int i = 0; i < keyFragments.Length; i++)
        {
            GameObject captured = keyFragments[i];
            keyFragments[i].GetComponent<Button>().onClick.AddListener(() => CollectKey(captured));
        }

        for (int i = 0; i < optionButtons.Length; i++)
        {
            int idx = i;
            optionButtons[i].onClick.AddListener(() => Choose(idx));
        }

        persuadeButton.onClick.AddListener(StartPersuasion);
        nextButton.onClick.AddListener(Next);
        backButton.onClick.AddListener(LevelFlow.BackToMap);

        persuadeButton.gameObject.SetActive(false);
        persuasionPanel.SetActive(false);
        UpdateCount();
    }

    void CollectKey(GameObject fragment)
    {
        if (fragment == null) return;
        Destroy(fragment);
        collected++;
        UpdateCount();

        if (collected >= 3)
            persuadeButton.gameObject.SetActive(true);
    }

    void UpdateCount()
    {
        if (countText != null)
            countText.text = "已找到心灵钥匙：" + collected + " / 3";
    }

    void StartPersuasion()
    {
        persuadeButton.gameObject.SetActive(false);
        persuasionPanel.SetActive(true);
        round = 0;
        ShowRound(0);
    }

    void ShowRound(int i)
    {
        questionText.text = questions[i];
        for (int k = 0; k < optionButtons.Length; k++)
        {
            optionButtons[k].gameObject.SetActive(true);
            Text label = optionButtons[k].GetComponentInChildren<Text>();
            if (label != null) label.text = options[i][k];
        }
        responseText.text = "";
        nextButton.gameObject.SetActive(false);
    }

    void Choose(int idx)
    {
        responseText.text = responses[round][idx];
        foreach (Button b in optionButtons)
            b.gameObject.SetActive(false);
        nextButton.gameObject.SetActive(true);
    }

    void Next()
    {
        round++;
        if (round >= questions.Length)
        {
            LevelFlow.Complete("shangshu");
            return;
        }
        ShowRound(round);
    }
}
