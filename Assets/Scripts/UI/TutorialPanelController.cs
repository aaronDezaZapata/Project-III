using System;
using UnityEngine;

public class TutorialPanelController : MonoBehaviour
{
    #region Variables

    private Animator _animator;
    
    private bool _isOnMove;
    private bool _isOnJump;
    private bool _isOnDoubleJump;
    private bool _isOnPopUp;
    private bool _isOnAbsorb;
    private bool _isOnShooting;
    private bool _isOnGeyser;
    private bool _isOnWhip;
    
    private static readonly int IsOnMove = Animator.StringToHash("isOnMove");
    private static readonly int IsOnJump = Animator.StringToHash("isOnJump");
    private static readonly int IsOnDoubleJump = Animator.StringToHash("isOnDoubleJump");
    private static readonly int IsOnPopUp = Animator.StringToHash("isOnPopUp");
    private static readonly int IsOnAbsorb = Animator.StringToHash("isOnAbsorb");
    private static readonly int IsOnShooting = Animator.StringToHash("isOnShooting");
    private static readonly int IsOnGeyser = Animator.StringToHash("isOnGeyser");
    private static readonly int IsOnWhip = Animator.StringToHash("isOnWhip");

    #endregion

    private void Awake()
    {
        _animator = GetComponent<Animator>();
    }

    private void OnEnable()
    {
        TutorialSectionTrigger.OnSectionEnter += TutorialAnimationState;
    }

    private void OnDisable()
    {
        TutorialSectionTrigger.OnSectionEnter -= TutorialAnimationState;   
    }

    private void TutorialAnimationState(TutorialSection state)
    {
        switch (state)
        {
            case TutorialSection.MOVE:
                MoveAnimationState();
                break;
            case TutorialSection.JUMP:
                JumpAnimationState();
                break;
            case TutorialSection.DOUBLEJUMP:
                DoubleJumpAnimationState();
                break;
            case TutorialSection.POPUP:
                PopUpAnimationState();
                break;
            case TutorialSection.ABSORB:
                AbsorbAnimationState();
                break;
            case TutorialSection.SHOOTING:
                ShootingAnimationState();
                break;
            case TutorialSection.GEYSER:
                GeyserAnimationState();
                break;
            case TutorialSection.WHIP:
                WhipAnimationState();
                break;
        }
    }

    #region Animations

    private void MoveAnimationState()
    {
        _isOnMove = !_isOnMove;
        _animator.SetBool(IsOnMove, _isOnMove);
    }
    
    private void JumpAnimationState()
    {
        _isOnJump = !_isOnJump;
        _animator.SetBool(IsOnJump, _isOnJump);
    }
    
    private void DoubleJumpAnimationState()
    {
        _isOnDoubleJump = !_isOnDoubleJump;
        _animator.SetBool(IsOnDoubleJump, _isOnDoubleJump);
    }
    
    private void PopUpAnimationState()
    {
        _isOnPopUp = !_isOnPopUp;
        _animator.SetBool(IsOnPopUp, _isOnPopUp);
    }
    
    private void AbsorbAnimationState()
    {
        _isOnAbsorb = !_isOnAbsorb;
        _animator.SetBool(IsOnAbsorb, _isOnAbsorb);
    }
    
    private void ShootingAnimationState()
    {
        _isOnShooting = !_isOnShooting;
        _animator.SetBool(IsOnShooting, _isOnShooting);
    }
    
    private void GeyserAnimationState()
    {
        _isOnGeyser = !_isOnGeyser;
        _animator.SetBool(IsOnGeyser, _isOnGeyser);
    }
    
    private void WhipAnimationState()
    {
        _isOnWhip = !_isOnWhip;
        _animator.SetBool(IsOnWhip, _isOnWhip);
    }

    #endregion
}
