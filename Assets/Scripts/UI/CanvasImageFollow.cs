using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class CanvasImageFollow : MonoBehaviour
{
    [SerializeField] private Image _image;
    
    private Transform _camera;

    private void Awake()
    {
        if (Camera.main != null) _camera = Camera.main.transform;
    }

    private void Start()
    {
        Material mat = Instantiate(_image.material);
        mat.SetInt("unity_GUIZTestMode", (int)CompareFunction.Always);
        _image.material = mat;
    }

    void LateUpdate()
    {
        transform.LookAt(transform.position + _camera.forward);
    }
}
