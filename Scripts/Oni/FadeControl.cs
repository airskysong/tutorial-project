using UnityEngine;
using System.Collections;

public class FadeControl : MonoBehaviour
{
    private	Texture2D texture;			// 淡入淡出处理使用的纹理

    private float	timer;				// 当前的时间
	private float	fadeTime;			// 淡入淡出需要的时间
	private	Color	colorStart;			// 淡入淡出开始时的颜色
	private	Color	colorTarget;		// 淡入淡出结束时的颜色
	
    void Awake()
    {
		this.texture		= new Texture2D(1, 1);
		this.timer			= 0.0f;
		this.fadeTime		= 0.0f;
		this.colorStart		= new Color( 0.0f, 0.0f, 0.0f, 0.0f );
		this.colorTarget	= new Color( 0.0f, 0.0f, 0.0f, 0.0f );
    }
    
 	void	Update()
	{
		this.timer += Time.deltaTime;
	}
	
	void OnGUI()
    {
		float	rate;
		
		if( fadeTime == 0.0f )
		{
			rate = 1.0f;
		}
		else
		{
			rate = this.timer / this.fadeTime;
		}
		Color	color = Color.Lerp( this.colorStart, this.colorTarget, rate );
		
		if( color.a <= 0.0f )
		{
			return;
		}
		
		GUI.depth = 0;
		
        this.texture.SetPixel(0, 0, color);
        this.texture.Apply();
        
        GUI.DrawTexture(new Rect(0, 0, Screen.width, Screen.height), this.texture);
    }
    
    void OnApplicationQuit()
    {
        Destroy(texture);
    }
	
	public void fade( float time, Color start, Color target )
	{
		this.fadeTime		= time;
		this.timer			= 0.0f;
		this.colorStart		= start;
		this.colorTarget	= target;
	}
	
	public bool isActive()
	{
		return ( this.timer > this.fadeTime ) ? false : true;
	}
}