using UnityEngine;

/// <summary>
/// 公羊传关卡：内嵌 Open-LLM-VTuber 的网页前端（Live2D + 对话 + TTS 全套），
/// 直接用 WebView 加载 localhost，不另做原生接入。
/// </summary>
public class GongyangLevel : WebExperienceLevel
{
    protected override string CompletedPinyin => "gongyangzhuan";
    protected override string HintMessage => "点击下方按钮，在游戏内体验《公羊传》";
}
