using UnityEngine;
using System.Collections;
//简易帧动画实现类
public class SimpleSpriteAnimation: MonoBehaviour {
//Public variables
	public float animationFrameRateSecond=0.2f;
	public int divisionCountX=1;
	public int divisionCountY=1;
//Public methods
	public void BeginAnimation( int fromIndex, int toIndex, bool loop=false ){
		m_currentIndex = m_fromIndex = fromIndex;
		m_toIndex = toIndex;
		m_loop = loop;
		m_frameElapsedTime = 0;
		SetMaterilTextureUV();
	}
	//取得当前的主纹理
	public Texture GetTexture(){
		return renderer.material.GetTexture("_MainTex");
	}
	//取得纹理显示部分的Rect
	public Rect GetUVRect(int frameIndex){
		int frameIndexNormalized=frameIndex;
		if(frameIndex>=divisionCountX*divisionCountY) 
			frameIndexNormalized=frameIndex%(divisionCountX*divisionCountY);
		float posX=((frameIndexNormalized%divisionCountX)/(float)divisionCountX);
		float posY=(1- ((1+(frameIndexNormalized/divisionCountX))/(float)divisionCountY));
		return new Rect( 
			posX, 
			posY, 
			renderer.material.mainTextureScale.x, 
			renderer.material.mainTextureScale.y
		);
	}
	public Rect GetCurrentFrameUVRect(){
		return GetUVRect(m_currentIndex);
	}
	//设置无明确指定时的动画
	public void SetDefaultAnimation( int defaultFromIndex, int defaultToIndex ){
		m_currentIndex = m_fromIndex = m_defaultFromIndex = defaultFromIndex;
		m_toIndex = m_defaultToIndex = defaultToIndex;
	}
	//取得像素宽度
	public float GetWidth(){
		return renderer.material.mainTextureScale.x * renderer.material.GetTexture("_MainTex").width;
	}
	//取得像素高度
	public float GetHeight(){
		return renderer.material.mainTextureScale.y * renderer.material.GetTexture("_MainTex").height;
	}
	//顺序播放动画帧
	public void AdvanceFrame(){
		if(m_fromIndex<m_toIndex){
			if( m_currentIndex <= m_toIndex ){
				m_currentIndex++;
				if( m_toIndex < m_currentIndex ){
					if( m_loop ){
						m_currentIndex=m_fromIndex;
					}
					else{
						m_currentIndex = m_fromIndex = m_defaultFromIndex;
						m_toIndex = m_defaultToIndex;
					}
				}
				SetMaterilTextureUV();
			}
		}
		else{
			if( m_currentIndex >= m_toIndex ){
				m_currentIndex--;
				if( m_toIndex > m_currentIndex ){
					if( m_loop ){
						m_currentIndex=m_fromIndex;
					}
					else{
						m_currentIndex = m_fromIndex = m_defaultFromIndex;
						m_toIndex = m_defaultToIndex;
					}
				}
				SetMaterilTextureUV();
			}
		}
	}
	void Start () {
		renderer.material.mainTextureScale = new Vector2(1.0f/divisionCountX,1.0f/divisionCountY);
	}
	// Update is called once per frame
	void Update () {
		m_frameElapsedTime+=Time.deltaTime;
		if( animationFrameRateSecond < m_frameElapsedTime ){
			m_frameElapsedTime=0;
			AdvanceFrame();
		}
	}
	//根据帧序号设置适当的纹理坐标UV
	void SetMaterilTextureUV(){
		Rect uvRect = GetCurrentFrameUVRect();
		renderer.material.mainTextureOffset=new Vector2(uvRect.x,uvRect.y);
	}
//Private variables
	float m_frameElapsedTime=0;
	int m_fromIndex = 0, m_toIndex = 0;
	int m_defaultFromIndex = 0, m_defaultToIndex = 0;
	bool m_loop = false;
	int m_currentIndex=0;
	
}
