using UnityEngine;

/// <summary>
/// 谷梁传关卡：内嵌网页体验《谷梁传》。
/// </summary>
public class GuliangLevel : WebExperienceLevel
{
    protected override string CompletedPinyin => "guliangzhuan";
    protected override string HintMessage => "点击下方按钮，在游戏内体验《谷梁传》";
}
