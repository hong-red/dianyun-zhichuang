using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 全局管理器（单例）：在场景切换间保存游戏状态。
/// 挂在 MainMenu 场景里的一个空物体上，通过 DontDestroyOnLoad 跨场景保留。
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    // 已唤醒（过关）的 IP 拼音列表
    private List<string> completedIPs = new List<string>();
    // 关卡结果列表
    private List<LevelResult> results = new List<LevelResult>();

    void Awake()
    {
        // 保证单例：如果已存在一份，就销毁新来的这一份
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    /// <summary>保证从任意关卡场景直接 Play（不经过 MainMenu）时也有 GameManager，否则「返回地图」记不了过关。</summary>
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void EnsureGameManagerExists()
    {
        if (Instance == null)
        {
            GameObject go = new GameObject("GameManager");
            go.AddComponent<GameManager>();
        }
    }

    /// <summary>标记某个 IP 已唤醒（过关）。</summary>
    public void MarkCompleted(string pinyin)
    {
        if (!completedIPs.Contains(pinyin))
        {
            completedIPs.Add(pinyin);
            results.Add(new LevelResult(pinyin, true, "已唤醒"));
        }
    }

    /// <summary>某个 IP 是否已唤醒。</summary>
    public bool IsCompleted(string pinyin)
    {
        return completedIPs.Contains(pinyin);
    }

    /// <summary>已唤醒的 IP 数量。</summary>
    public int CompletedCount()
    {
        return completedIPs.Count;
    }

    /// <summary>获取全部关卡结果。</summary>
    public List<LevelResult> GetAllResults()
    {
        return results;
    }
}
