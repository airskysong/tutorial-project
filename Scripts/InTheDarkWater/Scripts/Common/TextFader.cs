using UnityEngine;
using System.Collections;

/// <summary>
/// 文字的淡入淡出
/// </summary>
public class TextFader : MonoBehaviour {

    [SerializeField]
    private float waitTime = 0.05f;
    [SerializeField]
    private float fadeTime = 3.0f;
    [SerializeField]
    private float maxAlpha = 1.0f;
    [SerializeField]
    private float minAlpha = 0.0f;

    private float fromValue = 0.0f;
    private float toValue   = 1.0f;
    private Color baseColor;

	void Start () 
    {
        if (guiText) baseColor = new Color(guiText.material.color.r, guiText.material.color.g, guiText.material.color.b, guiText.material.color.a);
	}

    // 开始淡出
    void OnTextFadeOut()
    {
        if (!guiText) return;
        Debug.Log("OnTextFadeOut");
        fromValue = maxAlpha;
        toValue = minAlpha;
        // 通过协程执行淡入淡出
        StartCoroutine("Fade", fadeTime);
    }

    // 开始淡入
    void OnTextFadeIn()
    {
        if (!guiText) return;
        Debug.Log("OnTextFadeIn");
        fromValue = minAlpha;
        toValue = maxAlpha;
        // 通过协程执行淡入淡出
        StartCoroutine("Fade", fadeTime);
    }

    private IEnumerator Fade(float duration)
    {
        // 淡入淡出
        float currentTime = 0.0f;
        while (duration > currentTime)
        {
            float alpha = Mathf.Lerp(fromValue, toValue, currentTime/duration);
            guiText.material.color = new Color(baseColor.r, baseColor.g, baseColor.b, alpha);
            // 更新时间
            yield return new WaitForSeconds(waitTime);
            currentTime += waitTime;
        }
        // 淡入淡出执行结束的通知
        SendMessage("OnEndTextFade", SendMessageOptions.DontRequireReceiver);
    }
}
