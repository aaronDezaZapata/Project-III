using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class CanvasImageFollow : MonoBehaviour
{
    [SerializeField] private Transform _camera;
    [SerializeField] private Image _image;

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
