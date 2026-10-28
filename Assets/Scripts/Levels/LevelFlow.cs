using UnityEngine;

/// <summary>
/// 关卡通用流程：标记过关并返回大地图，或单纯返回地图。
/// 抽出来统一处理，避免每个关卡各写一遍 MarkCompleted + Load。
/// </summary>
public static class LevelFlow
{
    /// <summary>标记某个 IP 已唤醒，然后返回大地图。</summary>
    public static void Complete(string pinyin)
    {
        if (GameManager.Instance != null)
            GameManager.Instance.MarkCompleted(pinyin);
        SceneLoader.Load("WorldMap");
    }

    /// <summary>不标记过关，直接返回大地图（未完成时也可离开）。</summary>
    public static void BackToMap()
    {
        SceneLoader.Load("WorldMap");
    }
}
