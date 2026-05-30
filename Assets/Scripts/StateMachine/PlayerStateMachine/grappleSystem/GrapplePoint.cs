using System;
using UnityEngine;

public class GrapplePoint : MonoBehaviour
{
    private static readonly int IsOnRange = Animator.StringToHash("IsOnRange");
    private static readonly int IsOnInitialRange = Animator.StringToHash("IsOnInitialRange");

    [Header("Visual Feedback")]
    [SerializeField] private bool showGizmo = true;
    [SerializeField] private Color gizmoColor = Color.green;
    [SerializeField] private float gizmoRadius = 0.5f;
    [Space(5f)]
    [SerializeField] private CanvasImageFollow feedbackImage;

    [Header("Point Info")]
    [SerializeField] private bool isActive = true;

    public bool IsActive => isActive;
    public Vector3 Position => transform.position;
    
    private Animator _animator;

    private void Awake()
    {
        _animator = GetComponent<Animator>();
    }

    // TODO: REMOVE
    private void OnDrawGizmos()
    {
        if (!showGizmo) return;

        Gizmos.color = isActive ? gizmoColor : Color.gray;
        Gizmos.DrawWireSphere(transform.position, gizmoRadius);
        
        Gizmos.DrawLine(
            transform.position + Vector3.up * gizmoRadius,
            transform.position - Vector3.up * gizmoRadius
        );
        Gizmos.DrawLine(
            transform.position + Vector3.right * gizmoRadius,
            transform.position - Vector3.right * gizmoRadius
        );
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
    }
    
    public void OnGripExit()
    {
        _animator.SetBool(IsOnRange, false);
    }
    
    public void PlayerOnGrapple(bool isOnGrapple)
    {
        if (isOnGrapple)
            feedbackImage.gameObject.SetActive(false);
        else
            feedbackImage.gameObject.SetActive(true);
    }
}
