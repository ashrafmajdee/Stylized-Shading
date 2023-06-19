using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MaterialScaler : MonoBehaviour
{
    public float scale;
    public MeshRenderer meshRenderer;
    
    // Start is called before the first frame update

    void Start()
    {
        meshRenderer.material = new Material(MaterialManager.instance.shader);
    }

    // Update is called once per frame

    void Update()
    {
        meshRenderer.material.SetTextureScale("_MainTex", new Vector2(scale, scale));
        meshRenderer.material.SetTexture("_MainTex", MaterialManager.instance.hatchingTexture);
    }
}
