using UnityEngine;
using System.Collections;

public class GameControl : MonoBehaviour
{

    enum STEP
    {

        NONE = -1,

        PLAY = 0,       // 游戏中
        CLEAR,          // 清空

        NUM,
    };

    private STEP step = STEP.PLAY;
    private STEP next_step = STEP.NONE;

    private float step_timer = 0.0f;

    // -------------------------------------------------------- //

    public GameObject pazzlePrefab = null;

    public PazzleControl pazzle_control = null;

    private SimpleSpriteGUI finish_sprite = null;
    public Texture finish_texture = null;

    private RetryButtonControl retry_button = null;

    // -------------------------------------------------------- //

    public enum SE
    {

        NONE = -1,

        GRAB = 0,       // 点击拖拽碎片时
        RELEASE,        // 松开碎片时（非正解的情况下）

        ATTACH,         // 松开碎片时（正解的情况下）

        COMPLETE,       // 拼图完成时的音乐

        BUTTON,         // GUI 按钮

        NUM,
    };

    public AudioClip[] audio_clips;

    // -------------------------------------------------------- //

    // Use this for initialization
    void Start()
    {

        this.pazzle_control = (Instantiate(this.pazzlePrefab) as GameObject).GetComponent<PazzleControl>();

        // 设置“重新开始”按钮的绘制顺序
        // （碎片的后方）

        this.retry_button = GameObject.FindGameObjectWithTag("RetryButton").GetComponent<RetryButtonControl>();

        this.retry_button.renderer.material.renderQueue = this.pazzle_control.GetDrawPriorityRetryButton();


        this.finish_sprite = new SimpleSpriteGUI();
        this.finish_sprite.create();
        this.finish_sprite.setTexture(this.finish_texture);
    }

    // Update is called once per frame
    void Update()
    {

        // ---------------------------------------------------------------- //

        this.step_timer += Time.deltaTime;

        // ---------------------------------------------------------------- //
        // 检测状态迁移

        switch (this.step)
        {

            case STEP.PLAY:
                {
                    if (this.pazzle_control.isCleared())
                    {

                        this.next_step = STEP.CLEAR;
                    }
                }
                break;

            case STEP.CLEAR:
                {
                    if (this.step_timer > this.audio_clips[(int)SE.COMPLETE].length + 0.5f)
                    {

                        if (Input.GetMouseButtonDown(0))
                        {

                            Application.LoadLevel("TitleScene");
                        }
                    }
                }
                break;
        }


        // ---------------------------------------------------------------- //
        // 迁移时的初始化

        if (this.next_step != STEP.NONE)
        {

            switch (this.next_step)
            {

                case STEP.CLEAR:
                    {
                        this.retry_button.renderer.enabled = false;
                    }
                    break;
            }

            this.step = this.next_step;
            this.next_step = STEP.NONE;

            this.step_timer = 0.0f;
        }

        // ---------------------------------------------------------------- //
        // 执行处理

        switch (this.step)
        {

            case STEP.PLAY:
                {
                }
                break;
        }
    }
    void OnGUI()
    {
        if (pazzle_control.isDispCleard())
        {

            this.finish_sprite.draw();
        }
    }

    public void playSe(SE se)
    {
        this.audio.PlayOneShot(this.audio_clips[(int)se]);
    }

    // 按下“重新开始”按钮时的处理
    public void OnRetryButtonPush()
    {
        if (!this.pazzle_control.isCleared())
        {

            this.playSe(GameControl.SE.BUTTON);

            this.pazzle_control.beginRetryAction();
        }
    }
}
