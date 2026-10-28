using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 诗经关卡：收集「风、雅、颂」三片诗魂碎片，唤醒《诗经》，
/// 净化被遗忘之影污染的情丝花海。每个碎片物体需有 Button 组件。
/// </summary>
public class ShijingLevel : MonoBehaviour
{
    public GameObject[] fragments;   // 3 片诗魂（风·关雎 / 雅·鹿鸣 / 颂·清庙）
    public Text countText;           // 显示已收集数量
    public Text hintText;            // 每收集一片时浮现的《诗经》提示
    public Button backButton;        // 返回地图按钮（未完成时也可返回）

    // 与 fragments 一一对应的诗名与提示
    private string[] poemNames = { "风·《关雎》", "雅·《鹿鸣》", "颂·《清庙》" };
    private string[] poemHints =
    {
        "「关关雎鸠，在河之洲」——风之灵，起于民歌。",
        "「呦呦鹿鸣，食野之苹」——雅之灵，和于礼乐。",
        "「於穆清庙，肃雍显相」——颂之灵，敬于宗庙。"
    };

    private int collected = 0;

    void Start()
    {
        for (int i = 0; i < fragments.Length; i++)
        {
            GameObject captured = fragments[i];
            int index = i;
            fragments[i].GetComponentInChildren<Text>().text = poemNames[i];
            fragments[i].GetComponent<Button>().onClick.AddListener(() => CollectFragment(captured, index));
        }

        backButton.onClick.AddListener(LevelFlow.BackToMap);
        if (hintText != null) hintText.text = "";
        UpdateCount();
    }

    void CollectFragment(GameObject fragment, int index)
    {
        if (fragment == null) return;
        Destroy(fragment);
        collected++;
        if (hintText != null) hintText.text = poemHints[index];
        UpdateCount();

        if (collected >= 3)
        {
            if (hintText != null) hintText.text = "风、雅、颂三灵齐聚，情丝花海重焕光华！";
            LevelFlow.Complete("shijing");
        }
    }

    void UpdateCount()
    {
        if (countText != null)
            countText.text = "已集诗魂：" + collected + " / 3（风·雅·颂）";
    }
}
