using UnityEngine;
using System.Collections;

public class TitleSceneControl : MonoBehaviour {

	// 进行状态
	public enum STEP {

		NONE = -1,

		TITLE = 0,				// 显示标题（等待按钮按下）
		WAIT_SE_END,			// 等待开始音效结束
		FADE_WAIT,				// 等待淡入淡出结束

		NUM,
	};

	private STEP	step = STEP.NONE;
	private STEP	next_step = STEP.NONE;
	private float	step_timer = 0.0f;

	public Texture	TitleTexture = null;			// 标题的纹理
	public Texture	StartButtonTexture = null;			// “开始”的纹理
	private FadeControl	fader = null;					// 淡入淡出控制
	
	// 标题画像
	public float	title_texture_x		=    0.0f;
	public float	title_texture_y		=  100.0f;
	
	// “开始”文字
	public float	start_texture_x		=    0.0f;
	public float	start_texture_y		= -100.0f;
	
	// 按下开始按钮时播放动画的时间
	private static float	TITLE_ANIME_TIME = 0.1f;
	private static float	FADE_TIME = 1.0f;
	
	// -------------------------------------------------------------------------------- //

	void Start () {
		// 不允许玩家操作
		PlayerControl	player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerControl>();
		player.UnPlayable();
		
		// 添加淡入淡出控制
		this.fader = gameObject.AddComponent<FadeControl>();
		//fader	= gameObject.AddComponent();
		this.fader.fade( 1.0f, new Color( 0.0f, 0.0f, 0.0f, 1.0f ), new Color( 0.0f, 0.0f, 0.0f, 0.0f) );
		
		this.next_step = STEP.TITLE;
	}

	void Update ()
	{
		this.step_timer += Time.deltaTime;

		// 检测是否迁移到下一个状态
		switch(this.step) {

			case STEP.TITLE:
			{
				// 鼠标被按下
				//
				if(Input.GetMouseButtonDown(0)) {

					this.next_step = STEP.WAIT_SE_END;
				}
			}
			break;

			case STEP.WAIT_SE_END:
			{
				// 播放SE 结束后淡出
			
				bool	to_finish = true;

				do {

					if(!this.audio.isPlaying) {

						break;
					}

					if(this.audio.time >= this.audio.clip.length) {

						break;
					}

					to_finish = false;

				} while(false);

				if(to_finish) {

					this.fader.fade( FADE_TIME, new Color( 0.0f, 0.0f, 0.0f, 0.0f ), new Color( 0.0f, 0.0f, 0.0f, 1.0f) );
				
					this.next_step = STEP.FADE_WAIT;
				}
			}
			break;
			
			case STEP.FADE_WAIT:
			{
				// 淡入淡出结束后，载入游戏场景后结束
				if(!this.fader.isActive()) 
				{
					Application.LoadLevel("GameScene");
				}
			}
			
			break;
		}

		// 状态变化时的初始化处理

		if(this.next_step != STEP.NONE) {

			switch(this.next_step) {

				case STEP.WAIT_SE_END:
				{
					// 播放开始的SE
					this.audio.Play();
				}
				break;
			}

			this.step = this.next_step;
			this.next_step = STEP.NONE;

			this.step_timer = 0.0f;
		}

		// 各个状态的执行处理

		/*switch(this.step) {

			case STEP.TITLE:
			{
			}
			break;
		}*/

	}

	void OnGUI()
	{	
		GUI.depth = 1;
		
		float	scale	= 1.0f;
		
		if( this.step == STEP.WAIT_SE_END )
		{
			float	rate = this.step_timer / TITLE_ANIME_TIME;
			
			scale = Mathf.Lerp( 2.0f, 1.0f, rate );
		}
		
		TitleSceneControl.drawTexture(this.StartButtonTexture, start_texture_x, start_texture_y, scale, scale, 0.0f, 1.0f);		
		TitleSceneControl.drawTexture(this.TitleTexture, title_texture_x, title_texture_y, 1.0f, 1.0f, 0.0f, 1.0f);		
	}

	public static void drawTexture(Texture texture, float x, float y, float scale_x = 1.0f, float scale_y = 1.0f, float angle = 0.0f, float alpha = 1.0f)
	{
		Vector3		position;
		Vector3		scale;
		Vector3		center;

		position.x =  x + Screen.width/2.0f;
		position.y = -y + Screen.height/2.0f;
		position.z = 0.5f;

		scale.x = scale_x;
		scale.y = scale_y;
		scale.z = 1.0f;

		center.x = texture.width/2.0f;
		center.y = texture.height/2.0f;
		center.z = 0.0f;

		Matrix4x4	matrix = Matrix4x4.identity;

		matrix *= Matrix4x4.TRS(position - center, Quaternion.identity, Vector3.one);

		// 以纹理的中心为基准，执行旋转和缩放
		//
		matrix *= Matrix4x4.TRS( center,           Quaternion.identity, Vector3.one);
		matrix *= Matrix4x4.TRS(Vector3.zero,      Quaternion.AngleAxis(angle, Vector3.forward), scale);
		matrix *= Matrix4x4.TRS(-center,           Quaternion.identity, Vector3.one);

		GUI.matrix = matrix;
		GUI.color  = new Color(1.0f, 1.0f, 1.0f, alpha);

		Rect	rect = new Rect(0.0f, 0.0f, texture.width, texture.height);

		GUI.DrawTexture(rect, texture);
	}
}
