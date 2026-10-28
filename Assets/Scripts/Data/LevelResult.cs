/// <summary>
/// 关卡结果：记录某一关完成后的结果。
/// </summary>
public class LevelResult
{
    public string pinyin;   // 关卡对应的 IP 拼音
    public bool success;    // 是否过关
    public string message;  // 结果文案

    public LevelResult(string pinyin, bool success, string message)
    {
        this.pinyin = pinyin;
        this.success = success;
        this.message = message;
    }
}
