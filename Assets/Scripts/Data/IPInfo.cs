/// <summary>
/// IP 数据结构：描述一部经典的基本信息。
/// 注意：这里用的是普通 class，不是 ScriptableObject。
/// </summary>
public class IPInfo
{
    public string pinyin;          // 拼音，如 "gongyangzhuan"
    public string displayName;     // 显示名，如 "公羊传"
    public bool isPlayable;        // true = 完整可玩；false = 占位
    public string sceneName;       // 可玩时跳转的场景名（占位时可为空字符串）
    public bool loadAsync;         // true = 进入该关卡时用异步加载（用于较重的 Live2D 关卡）
    public string backgroundImage; // 背景图文件名（暂未使用，预留给后续）
    public string description;     // 一句话介绍
}
