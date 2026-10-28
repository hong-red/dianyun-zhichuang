using System.Collections;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 结局界面：显示已唤醒的经典数量，并返回主菜单。
/// 十三部经典全部集满时，额外显示一张特殊 CG（全屏插画）。
/// </summary>
public class EndingScreen : MonoBehaviour
{
    public Text summaryText;        // 结局总结文字
    public Button backToMenuButton; // 返回主菜单按钮

    [Header("特殊 CG（十三经集满时显示）")]
    [Tooltip("相对 Resources 的路径，无扩展名")]
    public string specialCGPath = "Ending/ending_special_cg";

    void Start()
    {
        int count = GameManager.Instance != null ? GameManager.Instance.CompletedCount() : 0;
        bool allCollected = count >= IPDatabase.GetAllIPs().Length;

        if (allCollected)
        {
            summaryText.text = "十三经齐鸣，遗忘之影消散！\n典籍大陆重现光明——你已集齐全部 " + count + " 部经典。";
            ShowSpecialCG();
        }
        else
        {
            summaryText.text = "你已唤醒 " + count + " 部经典。\n其余经典仍在沉睡中，等待下一位传礼者……";
        }

        backToMenuButton.onClick.AddListener(() => SceneLoader.Load("MainMenu"));
    }

    /// <summary>十三经集满时，在背景之上叠加一张全屏特殊 CG（带淡入）。</summary>
    void ShowSpecialCG()
    {
        Texture2D cg = Resources.Load<Texture2D>(specialCGPath);
        Canvas canvas = FindObjectOfType<Canvas>();
        if (cg == null || canvas == null)
        {
            Debug.LogWarning("[EndingScreen] 找不到特殊 CG：" + specialCGPath + "，仅显示文字结局。");
            return;
        }

        GameObject go = new GameObject("SpecialCG", typeof(RectTransform), typeof(RawImage));
        go.transform.SetParent(canvas.transform, false);
        // 背景(0)、遮罩(1)之上，标题/文字/按钮之下
        go.transform.SetSiblingIndex(2);

        RectTransform rt = (RectTransform)go.transform;
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = Vector2.zero;
        rt.offsetMax = Vector2.zero;

        RawImage img = go.GetComponent<RawImage>();
        img.texture = cg;
        img.color = Color.white;
        img.raycastTarget = false;

        StartCoroutine(FadeIn(img));
    }

    IEnumerator FadeIn(RawImage img)
    {
        Color c = img.color;
        c.a = 0f;
        img.color = c;
        for (float t = 0f; t < 1.2f; t += Time.deltaTime)
        {
            c.a = Mathf.Clamp01(t / 1.2f);
            img.color = c;
            yield return null;
        }
        c.a = 1f;
        img.color = c;
    }
}
