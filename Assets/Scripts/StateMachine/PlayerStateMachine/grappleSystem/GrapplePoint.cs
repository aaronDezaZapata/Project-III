using System;
using UnityEngine;
using UnityEngine.UI;

public class GrapplePoint : MonoBehaviour
{
    private static readonly int IsOnRange = Animator.StringToHash("IsOnRange");
    private static readonly int IsOnInitialRange = Animator.StringToHash("IsOnInitialRange");

    [Header("Visual Feedback")]
    [SerializeField] private CanvasImageFollow feedbackImage;
    [SerializeField] private Image _image;
    [SerializeField] private Sprite _keyboardSprite;
    [SerializeField] private Sprite _controllerSprite;

    [Header("Point Info")]
    [SerializeField] private bool _isActive = true;

    private Animator _animator;

    private void Awake()
    {
        _animator = GetComponent<Animator>();
    }

    private void Start()
    {
        var inputHandler = GameManager.Instance?.GetPlayer()?.GetComponent<InputHandler>();
        if (inputHandler != null)
            SetImage(inputHandler.IsUsingGamepad);
    }

    private void OnEnable()
    {
        InputHandler.OnInputDeviceChanged += SetImage;
    }

    private void OnDisable()
    {
        InputHandler.OnInputDeviceChanged -= SetImage;
    }

    public void InitializeGrapple()
    {
        feedbackImage.gameObject.SetActive(true);
        _animator.SetBool(IsOnInitialRange, true);
    }
    
    public void DeactivateGrapple()
    {
        feedbackImage.gameObject.SetActive(false);
        _animator.SetBool(IsOnInitialRange, false);
    }

    public void OnGripEnter()
    {
        _animator.SetBool(IsOnRange, true);
        GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().SetGrapplePoint(this);
        _isActive = true;
    }
    
    public void OnGripExit()
    {
        _animator.SetBool(IsOnRange, false);
        GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().RemoveGrapplePoint(this);
        _isActive = false;
    }
    
    public void PlayerOnGrapple(bool isOnGrapple)
    {
        if (isOnGrapple)
            feedbackImage.gameObject.SetActive(false);
        else
            feedbackImage.gameObject.SetActive(true);
    }

    public void SetImage(bool isController)
    {
        _image.sprite = isController ? _controllerSprite : _keyboardSprite;
    }
}
