using UnityEngine;
using System.Collections;

// 提示
//
// 为了不发生旋转，将
// rigidbody -> constraint -> freeze rotation
// 选中
//
// 复制预设
// × Ctrl-C Ctrl-V
// ○ Ctrl-D
//
// 集中统一敌人的碰撞器
//
// 生成无限地图背景的方法
//
// 从GameObject 使用脚本的变量和方法时，
// 可以使用GetComponent<类名>() 的形式
//
// 需要判定是否删除了不需要的实例对象时，
// 可以暂停游戏并在Hierarchy 视图中简单查看
//
// 如果生成的实例要按照 GameObject 类型来进行处理，
// 需要加上 as GameObject
//
// 销毁实例时，不使用Destory(this) 而使用 Destory(this.gameObject)
//
// OnBecameVisible/Invisible() 未被调用
// 当 MeshRender 为无效时（在Inspector 中取消复选框）
// 不会被调用
//
// On*() 未被调用
// 即使方法的名称一致，如果参数的类型不对也不会被调用
// × void OnCollisionEnter(Collider other)
// ○ void OnCollisionEnter(Collision other)
//.

public class PlayerControl : MonoBehaviour {

	// -------------------------------------------------------------------------------- //

	// 声音
	public AudioClip[]	AttackSound;				// 攻击时的声音
	public AudioClip	SwordSound;					// 挥剑的声音
	public AudioClip	SwordHitSound;				// 剑的声音（挥动声音，击中的声音）
	public AudioClip	MissSound;					// 失败时的声音
	public AudioClip	runSound;
	
	public AudioSource	attack_voice_audio;			// 攻撃音.
	public AudioSource	sword_audio;				// 剑的声音（挥动声音，击中的声音）
	public AudioSource	miss_audio;					// 失败时的声音
	public AudioSource	run_audio;
	
	public int			attack_sound_index = 0;		// 下一次发声 AttakSound.

	// -------------------------------------------------------------------------------- //

	// 移动的速度
	private	float	run_speed = 5.0f;

	// 移动速度的最大值 [m/sec]
	public static float	RUN_SPEED_MAX = 20.0f;

	// 移动速度的加速值 [m/sec^2]
	private const float	run_speed_add = 5.0f;

	// 移动速度的减速值 [m/sec^2]
	private const float	run_speed_sub = 5.0f*4.0f;

	// 用于攻击判定的碰撞器
	private	AttackColliderControl	attack_collider = null;

	public SceneControl				scene_control = null;

	// 判断攻击判定进行中的计时器
	// 如果attack_timer > 0.0f 表示攻击中
	private float	attack_timer = 0.0f;

	// 落空后无法攻击的计时器
	// 如果attack_disable_timer > 0.0f 则无法攻击
	private float	attack_disable_timer = 0.0f;

	// 攻击判定的持续时间 [sec]
	private static float	ATTACK_TIME = 0.3f;

	// 攻击判定的持续时间 [sec]
	private static float	ATTACK_DISABLE_TIME = 1.0f;

	private bool	is_running = true;

	private bool	is_contact_floor = false;

	private bool	is_playable		= true;
	
	// 停止的目标位置
	// （在SceneControl.cs 中决定，这里是希望停下来的位置）
	public float	stop_position = -1.0f;

	// 攻击动作的种类
	public enum ATTACK_MOTION {

		NONE = -1,

		RIGHT = 0,
		LEFT,

		NUM,
	};

	public ATTACK_MOTION	attack_motion = ATTACK_MOTION.LEFT;


	// 剑的轨迹特效
	public AnimatedTextureExtendedUV	kiseki_left = null;
	public AnimatedTextureExtendedUV	kiseki_right = null;

	// 击中时的特效
	public ParticleSystem				fx_hit = null;
	
	// 奔跑时的特效
	public ParticleSystem				fx_run = null;

	// 
	public	float	min_rate = 0.0f;
	public	float	max_rate = 3.0f;
	
	// -------------------------------------------------------------------------------- //

	public enum STEP {

		NONE = -1,

		RUN = 0,		// 奔跑 游戏中
		STOP,			// 停止 显示得分时
		MISS,			// 失败 和怪物发生接触时
		NUM,
	};

	public STEP		step			= STEP.NONE;
	public STEP		next_step    	= STEP.NONE;

	// -------------------------------------------------------------------------------- //

	void	Start()
	{
		// 查找用于攻击判定的碰撞器
		this.attack_collider = GameObject.FindGameObjectWithTag("AttackCollider").GetComponent<AttackColliderControl>();

		// 设置用于攻击判定的碰撞器的玩家实例
		this.attack_collider.player = this;

		// 剑的轨迹特效

		this.kiseki_left = GameObject.FindGameObjectWithTag("FX_Kiseki_L").GetComponent<AnimatedTextureExtendedUV>();
		this.kiseki_left.stopPlay();

		this.kiseki_right = GameObject.FindGameObjectWithTag("FX_Kiseki_R").GetComponent<AnimatedTextureExtendedUV>();
		this.kiseki_right.stopPlay();

		// 击中时的特效

		this.fx_hit = GameObject.FindGameObjectWithTag("FX_Hit").GetComponent<ParticleSystem>();
		
		this.fx_run = GameObject.FindGameObjectWithTag("FX_Run").GetComponent<ParticleSystem>();
		//

		this.run_speed = 0.0f;

		this.next_step = STEP.RUN;

		this.attack_voice_audio = this.gameObject.AddComponent<AudioSource>();
		this.sword_audio        = this.gameObject.AddComponent<AudioSource>();
		this.miss_audio         = this.gameObject.AddComponent<AudioSource>();
		
		this.run_audio         	= this.gameObject.AddComponent<AudioSource>();
		this.run_audio.clip		= this.runSound;
		this.run_audio.loop		= true;
		this.run_audio.Play();
	}

	void	Update()
	{
#if false
		if(Input.GetKey(KeyCode.Keypad1)) {
			min_rate -= 0.1f;
		}
		if(Input.GetKey(KeyCode.Keypad2)) {
			min_rate += 0.1f;
		}
		if(Input.GetKey(KeyCode.Keypad4)) {
			max_rate -= 0.1f;
		}
		if(Input.GetKey(KeyCode.Keypad5)) {
			max_rate += 0.1f;
		}
#endif		
		min_rate = Mathf.Clamp( min_rate, 0.0f, max_rate );
		max_rate = Mathf.Clamp( max_rate, min_rate, 5.0f );
		
		// 检测是否迁移到下一个状态
		if(this.next_step == STEP.NONE) {

			switch(this.step) {
	
				case STEP.RUN:
				{
					if(!this.is_running) {
	
						if(this.run_speed <= 0.0f) {
						
							// 停止播放跑步声音和跑步特效
							this.fx_run.Stop();
						
							this.next_step = STEP.STOP;
						}
					}
				}
				break;

				case STEP.MISS:
				{
					if(this.rigidbody.velocity.y < 0.0f) {

						if(this.is_contact_floor) {
						
							// 再次播放跑步的特效
							this.fx_run.Play();
						
							this.rigidbody.useGravity = true;
							this.next_step = STEP.RUN;
						}
					}
				}
				break;
			}
		}
			
		// 状态迁移时的初始化
		if(this.next_step != STEP.NONE) {

			switch(this.next_step) {

				case STEP.STOP:
				{
					Animation	animation = this.transform.GetComponentInChildren<Animation>();

					animation.Play("P_stop");
				}
				break;

				case STEP.MISS:
				{
					// 往斜上方弹开

					Vector3	velocity = this.rigidbody.velocity;

					float	jump_height = 1.0f;

					velocity.x = -2.5f;
					velocity.y = Mathf.Sqrt(2.0f*9.8f*jump_height);
					velocity.z = 0.0f;

					this.rigidbody.velocity = velocity;
					this.rigidbody.useGravity = false;

					this.run_speed = 0.0f;

					Animation	animation = this.transform.GetComponentInChildren<Animation>();

					animation.Play("P_yarare");				
					animation.CrossFadeQueued("P_run");

					//

					this.miss_audio.PlayOneShot(this.MissSound);
				
					// 停止播放奔跑的特效
					this.fx_run.Stop();
				}
				break;
			}

			this.step = this.next_step;

			this.next_step = STEP.NONE;
		}
		
		// 控制跑步声音的音量
		if( this.is_running ){
			this.run_audio.volume = 1.0f;
		}else{
			this.run_audio.volume = Mathf.Max(0.0f, this.run_audio.volume - 0.05f );
		}
		
		// 各个状态的执行

		// ---------------------------------------------------- //
		// 位置

		switch(this.step) {

			case STEP.RUN:
			{
				// ---------------------------------------------------- //
				// 速度
		
				if(this.is_running) {
		
					this.run_speed += PlayerControl.run_speed_add*Time.deltaTime;
		
				} else {
		
					this.run_speed -= PlayerControl.run_speed_sub*Time.deltaTime;
				}
		
				this.run_speed = Mathf.Clamp(this.run_speed, 0.0f, PlayerControl.RUN_SPEED_MAX);
		
				Vector3	new_velocity = this.rigidbody.velocity;
		
				new_velocity.x = run_speed;
		
				if(new_velocity.y > 0.0f) {
		
					new_velocity.y = 0.0f;
				}
		
				this.rigidbody.velocity = new_velocity;
		
				float	rate;
			
				rate	= this.run_speed / PlayerControl.RUN_SPEED_MAX;
				this.run_audio.pitch	= Mathf.Lerp( min_rate, max_rate, rate);

				// ---------------------------------------------------- //
				// 攻击
		
				this.attack_control();

				this.sword_fx_control();

				// ---------------------------------------------------- //
				// 根据是否能进行攻击改变颜色（用于调试）
		
				if(this.attack_disable_timer > 0.0f) {
		
					this.renderer.material.color = Color.gray;
		
				} else {
		
					this.renderer.material.color = Color.Lerp(Color.white, Color.blue, 0.5f);
				}
		
				// ---------------------------------------------------- //
				// 通过“W”键向前方大幅移动（用于调试）
#if UNITY_EDITOR
				if(Input.GetKeyDown(KeyCode.W)) {
		
					Vector3		position = this.transform.position;
		
					position.x += 100.0f*FloorControl.WIDTH*FloorControl.MODEL_NUM;
		
					this.transform.position = position;
				}
#endif
			}
			break;

			case STEP.MISS:
			{
				this.rigidbody.velocity += Vector3.down*9.8f*2.0f*Time.deltaTime;
			}
			break;

		}

		//

		this.is_contact_floor = false;
	}


	void OnCollisionStay(Collision other)
	{
		// 和怪物接触后，减速
		//

		if(other.gameObject.tag == "OniGroup") {

			if(this.step != STEP.MISS) {

				this.next_step = STEP.MISS;

				// 玩家和怪物接触时的处理

				this.scene_control.OnPlayerMissed();

				// 记录下怪物小组和玩家发生了接触

				OniGroupControl	oni_group = other.gameObject.GetComponent<OniGroupControl>();
				
				oni_group.onPlayerHitted();
			}
		}

		// 是否着陆了？
		if(other.gameObject.tag == "Floor") {

			this.is_contact_floor = true;
		}
	}

	// 有时候CollisionStay 也可能不被调用，这里提前设定好
	void OnCollisionEnter(Collision other)
	{
		this.OnCollisionStay(other);
	}


	// -------------------------------------------------------------------------------- //

	// 播放攻击命中的特效
	public void		playHitEffect(Vector3 position)
	{
		this.fx_hit.transform.position = position;

		this.fx_hit.Play();
	}

	// 播放攻击命中的声音
	public void		playHitSound()
	{
		this.sword_audio.PlayOneShot(this.SwordHitSound);
	}

	// 重置“无法攻击”计时器（立刻变为可攻击）
	public void 	resetAttackDisableTimer()
	{
		this.attack_disable_timer = 0.0f;
	}

	// 算出从开始攻击（点击鼠标按键起）经过的时间
	public float	GetAttackTimer()
	{
		return(PlayerControl.ATTACK_TIME - this.attack_timer);
	}

	// 获取外加的速度率（0.0f ～ 1.0f）
	public float	GetSpeedRate()
	{
		float	player_speed_rate = Mathf.InverseLerp(0.0f, PlayerControl.RUN_SPEED_MAX, this.rigidbody.velocity.magnitude);

		return(player_speed_rate);
	}

	// 停止
	public void 	StopRequest()
	{
		this.is_running = false;
	}
	
	// 允许玩家操作
	public void		Playable()
	{
		this.is_playable = true;
	}
	
	// 禁止玩家操作
	public void		UnPlayable()
	{
		this.is_playable = false;
	}
	
	// 玩家是否已停止？
	public bool 	IsStopped()
	{
		bool	is_stopped = false;

		do {

			if(this.is_running) {

				break;
			}

			if(this.run_speed > 0.0f) {

				break;
			}

			//

			is_stopped = true;

		} while(false);

		return(is_stopped);
	}

	// 持续减速时，算出预计的停止位置
	public float CalcDistanceToStop()
	{
		float distance = this.rigidbody.velocity.sqrMagnitude/(2.0f*PlayerControl.run_speed_sub);

		return(distance);
	}

	// -------------------------------------------------------------------------------- //

	// 是否有攻击的输入？
	private bool	is_attack_input()
	{
		bool	is_attacking = false;

		// 如果点击鼠标左键，攻击
		//
		// OnMouseDown() 只有在对象自身被点击时才会被调用
		// 因为这里我们需要在画面的任何位置被点击时都会有反应，
		// 使用Input.GetMouseButtonDown() 
		//
		if(Input.GetMouseButtonDown(0)) {

			is_attacking = true;
		}

		// 用于调试的自动攻击
		if(SceneControl.IS_AUTO_ATTACK) {

			GameObject[] oni_groups = GameObject.FindGameObjectsWithTag("OniGroup");

			foreach(GameObject oni_group in oni_groups) {

				float	distance = oni_group.transform.position.x - this.transform.position.x;
				
				distance -= 1.0f/2.0f;
				distance -= OniGroupControl.collision_size/2.0f;

				// 无视后面存在的物体
				// （虽然这个游戏中是不可能的，但是为了保险起见）
				//
				if(distance < 0.0f) {

					continue;
				}

				// 发生碰撞的预想时间

				float	time_left = distance/(this.rigidbody.velocity.x - oni_group.GetComponent<OniGroupControl>().run_speed);

				// 无视分开的对象
				//
				if(time_left < 0.0f) {

					continue;
				}

				if(time_left < 0.1f) {
				//if(time_left < 0.05f) {

					is_attacking = true;
				}
			}
		}

		return(is_attacking);
	}

	// 攻击控制
	private void	attack_control()
	{
		if(!this.is_playable) {
			return;	
		}
		
		if(this.attack_timer > 0.0f) {

			// 正在进行攻击判定

			this.attack_timer -= Time.deltaTime;

			// 攻击判定结束检测
			if(this.attack_timer <= 0.0f) {

				// 使碰撞器（攻击成功否）的碰撞判定无效
				//
				attack_collider.SetPowered(false);
			}

		} else {

			this.attack_disable_timer -= Time.deltaTime;

			if(this.attack_disable_timer > 0.0f) {

				// 仍旧不可攻击

			} else {

				this.attack_disable_timer = 0.0f;

				if(this.is_attack_input()) {

					// 使碰撞器（攻击成功与否）的攻击判定有效
					//
					attack_collider.SetPowered(true);
		
					this.attack_timer = PlayerControl.ATTACK_TIME;
	
					this.attack_disable_timer = PlayerControl.ATTACK_DISABLE_TIME;

					// 播放攻击动作

					Animation	animation = this.transform.GetComponentInChildren<Animation>();

					// 想对同一个动作从头开始重新播放使，必须先调用一次 stop()
					//animation.Stop();

					// 选择下一个播放的动作
					//
					// 因为要在决定“怪物”飞散的方向时知道“上一个攻击动作”
					// 应该在播放前而非在播放后选择动作
					//
					switch(this.attack_motion) {

						default:
						case ATTACK_MOTION.RIGHT:	this.attack_motion = ATTACK_MOTION.LEFT;	break;
						case ATTACK_MOTION.LEFT:	this.attack_motion = ATTACK_MOTION.RIGHT;	break;
					}

					switch(this.attack_motion) {

						default:
						case ATTACK_MOTION.RIGHT:	animation.CrossFade("P_attack_R", 0.2f);	break;
						case ATTACK_MOTION.LEFT:	animation.CrossFade("P_attack_L", 0.2f);	break;
					}

					// 攻击动作结束后，回到奔跑动作
					animation.CrossFadeQueued("P_run");

					this.attack_voice_audio.PlayOneShot(this.AttackSound[this.attack_sound_index]);

					this.attack_sound_index = (this.attack_sound_index + 1)%this.AttackSound.Length;

					this.sword_audio.PlayOneShot(this.SwordSound);

				}
			}
		}
	}

	// 剑的轨迹特效
	private	void	sword_fx_control()
	{

		do {
		
			if(this.attack_timer <= 0.0f) {
		
				break;
			}
		
			if(this.kiseki_left.isPlaying()) {
		
				break;
			}
		
			Animation					animation = this.transform.GetComponentInChildren<Animation>();
			AnimationState				state;
			AnimatedTextureExtendedUV	anim_player;
		
			switch(this.attack_motion) {
		
				default:
				case ATTACK_MOTION.RIGHT:
				{
					state = animation["P_attack_R"];
					anim_player = this.kiseki_right;
				}
				break;
		
				case ATTACK_MOTION.LEFT:
				{
					state = animation["P_attack_L"];
					anim_player = this.kiseki_left;
				}
				break;
			}
		
			float	start_time    = 2.5f;
			float	current_frame = state.time*state.clip.frameRate;
			
			if(current_frame < start_time) {
			
				break;
			}
		
			anim_player.startPlay(state.time - start_time/state.clip.frameRate);
		
		} while(false);
	}
}
