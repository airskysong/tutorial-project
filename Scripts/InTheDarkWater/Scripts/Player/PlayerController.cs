using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour {


    [System.Serializable]
    public class SpeedValue
    {
        [SerializeField]
        private float max = 10.0f;
        [SerializeField]
        private float step = 0.5f;

        public float current = 1.0f;
        /// <summary>
        /// 变化速度
        /// </summary>
        /// <param name="value"></param>
        public void Change( float value )
        {
            current += value * step;
            current = Mathf.Clamp(current, 0.0f, max);
        }

        public void Stop() { current = 0.0f; }

        public float Rate() { return Mathf.InverseLerp(0.0f, max, current); }
    };
    [SerializeField]
    private SpeedValue speed = new SpeedValue();

    [System.Serializable]
    public class RotationValue
    {
        public Vector3 current = Vector3.zero;
        private float attenuationStart;
        private float attenuationTime = 0.0f;
        private float currentRot;               // 当前的衰减率（attenuationRot/slowdownRot）

        [SerializeField]
        private float max = 30.0f;
        [SerializeField]
        private float blend = 0.8f;
        [SerializeField]
        private float margin = 0.01f;
        [SerializeField]
        private float attenuationRot = 0.2f;    // “未按下按键”时的衰减率
        [SerializeField]
        private float slowdownRot = 0.4f;       // “按下按键，未移动鼠标”时的衰减率

        public void Init()
        {
            currentRot = attenuationTime;
        }

        /// <summary>
        /// 改变旋转量
        /// </summary>
        public void Change(float value)
        {
            // 当鼠标轻微移动时不更新
            // （为了确保不持续移动鼠标将会停止旋转）
            if (-margin < value && value < margin) return;

            // 混合旋转量
            current.y = Mathf.Lerp(current.y, current.y + value, blend);
            if (current.y > max) current.y = max;
            // 重置衰减
            attenuationStart = current.y;
            attenuationTime = 0.0f;
        }
        /// <summary>
        /// 衰减
        /// </summary>
        /// <param name="time">时间变量</param>
        /// <returns>衰减中／不衰减</returns>
        public bool Attenuate(float time)
        {
            if (current.y == 0.0f) return false;
            attenuationTime += time;
            current.y = Mathf.SmoothStep(attenuationStart, 0.0f, currentRot * attenuationTime);
            return true;
        }

        public void BrakeAttenuation() {    currentRot = slowdownRot;   }
        public void UsualAttenuation()
        {
            attenuationTime = (slowdownRot * attenuationTime) / attenuationRot;
            currentRot = attenuationRot;
        }

        public void Stop() { current = Vector3.zero; }
    };
    [SerializeField]
    private RotationValue rot = new RotationValue();

    private Quaternion deltaRot;

    [SerializeField]
    private bool valid = false;

    private Controller controller;
    private MarineSnow marinesnowEffect;
    private TorpedoGenerator torpedo;

	void Start () 
    {
        // MarinSnow的效果依赖于速度。因为会频繁更新因此存储其引用
        GameObject effect = GameObject.Find("Effect_MarineSnow");
        if (effect)  marinesnowEffect = effect.GetComponent<MarineSnow>();
        // 发射鱼类的脚本
        torpedo = GetComponent<TorpedoGenerator>();
    }

    void OnGameStart()
    {
        Debug.Log("OnGameStart");
        valid = true;
        // UI控制器。因为会频繁更新因此存储其引用
        GameObject uiObj = GameObject.Find("/UI/Controller");
        if (uiObj) controller = uiObj.GetComponent<Controller>();
        // 显示控制器
        if (controller) controller.Enable(true);
        rot.Init();
    }

    void OnGameClear()
    {
        InvalidPlayer();
    }

    void OnGameOver()
    {
        InvalidPlayer();

        // 开始沉没
        // 解除轴的固定，让重力生效
        rigidbody.constraints = RigidbodyConstraints.FreezeRotationX | RigidbodyConstraints.FreezeRotationZ;
        rigidbody.useGravity = true;
    }
	
	void FixedUpdate () 
    {
        // 旋转的衰减
        rot.Attenuate(Time.deltaTime);

        if (valid)
        {
            // 发射鱼雷
            if (Input.GetKeyDown(KeyCode.B))
            {
                //Debug.Log("B ender : " + Time.time);
                torpedo.Generate();
            }

            // 拖动中
            if (Input.GetMouseButton(0))
            {
//                Debug.Log("MouseButton");
                // 旋转
                rot.Change(Input.GetAxis("Mouse X"));
                // 加速
                speed.Change(Input.GetAxis("Mouse Y"));
            }

            // 拖动开始
            if (Input.GetMouseButtonDown(0))
            {
//                Debug.Log("MouseDown");
                rot.BrakeAttenuation();
            }
            // 拖动结束
            if (Input.GetMouseButtonUp(0))
            {
                rot.UsualAttenuation();
            }
        }
        // 旋转
        Rotate();
        // 前进
        MoveForward();
	}

    private void InvalidPlayer()
    {
        valid = false;
        speed.Stop();
        rot.Stop();
        if (controller) controller.Enable(false);
    }

    private void Rotate() 
    {
        Quaternion deltaRot = Quaternion.Euler(rot.current * Time.deltaTime);
        rigidbody.MoveRotation(rigidbody.rotation * deltaRot);
        // 开始旋转
        if (controller) controller.SetAngle(transform.localEulerAngles.y);
    }

    private void MoveForward()
    {
        Vector3 vec = speed.current * transform.forward.normalized;
        rigidbody.MovePosition(rigidbody.position + vec * Time.deltaTime);
        // 呈现出速度的变化
        if (marinesnowEffect) marinesnowEffect.SetSpeed(speed.Rate());
    }

    public void AddSpeed(float value) 
    {
        speed.Change( value );
    }

    public float SpeedRate()
    {
        return speed.Rate();
    }

}
