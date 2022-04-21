using UnityEngine;
using System.Collections;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
//用于控制游戏的状态迁移的管理类
public class PhaseManager : MonoBehaviour {
	public string currentPhase{
		get{ return m_currentPhase; }
	}
	public GameObject[] guiList;
	// Use this for initialization
	void Start () {
		m_musicManager   = GameObject.Find("MusicManager").GetComponent<MusicManager>();
		m_scoringManager = GameObject.Find("ScoringManager").GetComponent<ScoringManager>();
	}
	
	// Update is called once per frame
	void Update () {
		switch (currentPhase){
		case "Play" :
			if( m_musicManager.IsFinished() ){
				SetPhase("GameOver");
			}
			break;
		}
	}
	public void SetPhase(string nextPhase){
		switch(nextPhase){
		//开始菜单
		case "Startup":
			DeactiveateAllGUI();
			ActivateGUI("StartupMenuGUI");
			break;
		//说明
		case "OnBeginInstruction":
			DeactiveateAllGUI();
			ActivateGUI("InstructionGUI");
			ActivateGUI("OnPlayGUI");
			break;
		//主体游戏
		case "Play":
		{
			DeactiveateAllGUI();
			ActivateGUI("OnPlayGUI");
			//从csv读取音乐数据
			TextReader textReader
				= new StringReader(
					System.Text.Encoding.UTF8.GetString((Resources.Load("SongInfo/songInfoCSV") as TextAsset).bytes )
				);
			SongInfo songInfo = new SongInfo();
			SongInfoLoader loader=new SongInfoLoader();
			loader.songInfo=songInfo;
			loader.ReadCSV(textReader);
			m_musicManager.currentSongInfo = songInfo;

			foreach (GameObject audience in GameObject.FindGameObjectsWithTag("Audience"))
			{
				audience.GetComponent<SimpleActionMotor>().isWaveBegin = true;
			}
			//事件（舞台演出等）开始
			GameObject.Find("EventManager").GetComponent<EventManager>().BeginEventSequence();
			//开始得分评价
			m_scoringManager.BeginScoringSequence();
			//开始绘制旋律的时间序列
			OnPlayGUI onPlayGUI = GameObject.Find("OnPlayGUI").GetComponent<OnPlayGUI>();
			onPlayGUI.BeginVisualization();
			onPlayGUI.isDevelopmentMode = false;
			//开始演奏
			m_musicManager.PlayMusicFromStart();
		}
			break;
		case "DevelopmentMode":
		{
			DeactiveateAllGUI();
			ActivateGUI("DevelopmentModeGUI");
			ActivateGUI("OnPlayGUI");
			//从csv读取音乐数据
			TextReader textReader
				= new StringReader(
					System.Text.Encoding.UTF8.GetString((Resources.Load("SongInfo/songInfoCSV") as TextAsset).bytes )
				);
			SongInfo songInfo = new SongInfo();
			SongInfoLoader loader=new SongInfoLoader();
			loader.songInfo=songInfo;
			loader.ReadCSV(textReader);
			m_musicManager.currentSongInfo = songInfo;

			foreach (GameObject audience in GameObject.FindGameObjectsWithTag("Audience"))
			{
				audience.GetComponent<SimpleActionMotor>().isWaveBegin = true;
			}
			//事件（舞台演出等）开始
			GameObject.Find("EventManager").GetComponent<EventManager>().BeginEventSequence();
			//开始评价得分
			m_scoringManager.BeginScoringSequence();
			//开始绘制旋律时序图
			OnPlayGUI onPlayGUI = GameObject.Find("OnPlayGUI").GetComponent<OnPlayGUI>();
			onPlayGUI.BeginVisualization();
			onPlayGUI.isDevelopmentMode = true;
			//开始绘制develop模式下的专用GUI时序图
			GameObject.Find("DevelopmentModeGUI").GetComponent<DevelopmentModeGUI>().BeginVisualization();
			//开始演奏
			m_musicManager.PlayMusicFromStart();
		}
			break;
		case "GameOver":
		{
			DeactiveateAllGUI();
			ActivateGUI("ShowResultGUI");
			ShowResultGUI showResult = GameObject.Find("ShowResultGUI").GetComponent<ShowResultGUI>();
			//显示保存得分的信息
			Debug.Log( m_scoringManager.scoreRate );
			Debug.Log(ScoringManager.failureScoreRate);
			if (m_scoringManager.scoreRate <= ScoringManager.failureScoreRate)
			{
				showResult.comment = showResult.comment_BAD;
				GameObject.Find("Vocalist").GetComponent<BandMember>().BadFeedback();
				
			}
			else if (m_scoringManager.scoreRate >= ScoringManager.excellentScoreRate)
			{
				showResult.comment = showResult.comment_EXCELLENT;
				GameObject.Find("Vocalist").GetComponent<BandMember>().GoodFeedback();
				GameObject.Find("AudienceVoice").GetComponent<AudioSource>().Play();
			}
			else
			{
				showResult.comment = showResult.comment_GOOD;
				GameObject.Find("Vocalist").GetComponent<BandMember>().GoodFeedback();
			}
		}
			break;
		case "Restart":
		{
			Application.LoadLevel("Main");
		}
			break;
		default:
			Debug.LogError("unknown phase: " + nextPhase);
			break;
		}//end of switch

		m_currentPhase = nextPhase;
	}
	private void DeactiveateAllGUI(){
		foreach( GameObject gui in guiList ){
			gui.active = false;
		}
	}
	private void ActivateGUI(string guiName)
	{
		foreach (GameObject gui in guiList)
		{
			if (gui.name == guiName) gui.active = true;
		}
	}
	//private Variables
	MusicManager m_musicManager;
	ScoringManager m_scoringManager;
	string m_currentPhase = "Startup";
}
