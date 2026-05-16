using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInkColorSystem : MonoBehaviour
{
    private PlayerStateMachine _player;
    private Dictionary<Color, Type> _colorToStateDic;
    private Coroutine _fillCoroutine;
    private float _fillSpeed = 5f;

    private void Awake()
    {
        _player = GetComponent<PlayerStateMachine>();

        _colorToStateDic = new Dictionary<Color, Type>
        {
            { Color.red,   typeof(PlayerRedState)   },
            { Color.green, typeof(PlayerGreenState) },
            { Color.blue,  typeof(PlayerBlueState)  },
            { Color.white, typeof(PlayerWhiteState) }
        };
    }

    public void RotateColors()
    {
        var mat = _player.MatPlayer.material;

        Color tempColor = mat.GetColor("_ColorA");
        float tempFill  = mat.GetFloat("_FillA");

        mat.SetColor("_ColorA", mat.GetColor("_ColorB"));
        mat.SetFloat("_FillA",  mat.GetFloat("_FillB"));

        mat.SetColor("_ColorB", mat.GetColor("_ColorC"));
        mat.SetFloat("_FillB",  mat.GetFloat("_FillC"));

        mat.SetColor("_ColorC", tempColor);
        mat.SetFloat("_FillC",  tempFill);

        CheckAndSwitchColorState();
    }

    public void StartFill(Color newColor)
    {
        var mat = _player.MatPlayer.material;

        if (ColorsAreClose(mat.GetColor("_ColorA"), newColor) && mat.GetFloat("_FillA") > 0.01f && mat.GetFloat("_FillA") < 0.999f)
        {
            if (_fillCoroutine != null) StopCoroutine(_fillCoroutine);
            _fillCoroutine = StartCoroutine(FillRoutine("_FillA"));
            return;
        }
        if (ColorsAreClose(mat.GetColor("_ColorB"), newColor) && mat.GetFloat("_FillB") > 0.01f && mat.GetFloat("_FillB") < 0.999f)
        {
            if (_fillCoroutine != null) StopCoroutine(_fillCoroutine);
            _fillCoroutine = StartCoroutine(FillRoutine("_FillB"));
            return;
        }
        if (ColorsAreClose(mat.GetColor("_ColorC"), newColor) && mat.GetFloat("_FillC") > 0.01f && mat.GetFloat("_FillC") < 0.999f)
        {
            if (_fillCoroutine != null) StopCoroutine(_fillCoroutine);
            _fillCoroutine = StartCoroutine(FillRoutine("_FillC"));
            return;
        }

        float fillA = mat.GetFloat("_FillA");
        float fillB = mat.GetFloat("_FillB");
        float fillC = mat.GetFloat("_FillC");

        if (fillA < 0.1f)
        {
            mat.SetColor("_ColorA", newColor);
            mat.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else if (fillB < 0.1f)
        {
            mat.SetColor("_ColorB", mat.GetColor("_ColorA"));
            mat.SetFloat("_FillB", mat.GetFloat("_FillA"));
            mat.SetColor("_ColorA", newColor);
            mat.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else if (fillC < 0.1f)
        {
            mat.SetColor("_ColorC", mat.GetColor("_ColorB"));
            mat.SetFloat("_FillC", mat.GetFloat("_FillB"));
            mat.SetColor("_ColorB", mat.GetColor("_ColorA"));
            mat.SetFloat("_FillB", mat.GetFloat("_FillA"));
            mat.SetColor("_ColorA", newColor);
            mat.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else
        {
            mat.SetColor("_ColorC", mat.GetColor("_ColorB"));
            mat.SetFloat("_FillC", mat.GetFloat("_FillB"));
            mat.SetColor("_ColorB", mat.GetColor("_ColorA"));
            mat.SetFloat("_FillB", mat.GetFloat("_FillA"));
            mat.SetColor("_ColorA", newColor);
            mat.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
    }

    private void StartFillRoutine(string fillProperty)
    {
        if (_fillCoroutine != null) StopCoroutine(_fillCoroutine);
        _fillCoroutine = StartCoroutine(FillRoutine(fillProperty));
        CheckAndSwitchColorState();
    }

    private IEnumerator FillRoutine(string fillProperty)
    {
        var mat = _player.MatPlayer.material;
        while (mat.GetFloat(fillProperty) < 1f)
        {
            float newFill = Mathf.Clamp01(mat.GetFloat(fillProperty) + Time.deltaTime * _fillSpeed);
            mat.SetFloat(fillProperty, newFill);
            yield return null;
        }

        CheckAndSwitchColorState();
    }

    public void UseColor(float reduceFill)
    {
        var mat = _player.MatPlayer.material;
        if (mat.GetFloat("_FillC") >= 0.1f)
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillC"));
        else if (mat.GetFloat("_FillB") >= 0.1f)
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillB"));
        else if (mat.GetFloat("_FillA") >= 0.1f)
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillA"));
    }

    private IEnumerator EmptyColorRoutine(float reduceFill, string fillProperty)
    {
        var mat = _player.MatPlayer.material;
        float targetFill = mat.GetFloat(fillProperty) - reduceFill;

        if (targetFill < 0.1f)
            targetFill = 0f;

        while (mat.GetFloat(fillProperty) > targetFill)
        {
            float currentFill = mat.GetFloat(fillProperty) - reduceFill * Time.deltaTime * 5f;

            if (currentFill < targetFill)
                currentFill = targetFill;

            mat.SetFloat(fillProperty, currentFill);
            yield return null;
        }

        CheckAndSwitchColorState();
    }

    public void CheckAndSwitchColorState()
    {
        var mat = _player.MatPlayer.material;

        if (mat.GetFloat("_FillC") >= 0.1f) { SwitchToStateByColor(mat.GetColor("_ColorC")); return; }
        if (mat.GetFloat("_FillB") >= 0.1f) { SwitchToStateByColor(mat.GetColor("_ColorB")); return; }
        if (mat.GetFloat("_FillA") >= 0.1f) { SwitchToStateByColor(mat.GetColor("_ColorA")); return; }

        _player.SwitchState(typeof(PlayerWhiteState));
    }

    private void SwitchToStateByColor(Color c)
    {
        Type targetState = null;

        foreach (var kvp in _colorToStateDic)
        {
            if (ColorsAreClose(kvp.Key, c))
            {
                targetState = kvp.Value;
                break;
            }
        }

        if (targetState == null)
        {
            AudioManager.Instance?.SetInkState(InkStateType.Base);
            _player.SwitchState(typeof(PlayerWhiteState));
            return;
        }

        Type currentState = _player.GetCurrentState().GetType();

        if (currentState == targetState) return;
        if (targetState == typeof(PlayerRedState)   && currentState == typeof(PlayerShootingState)) return;
        if (targetState == typeof(PlayerGreenState) && currentState == typeof(PlayerWhipState))     return;
        if (targetState == typeof(PlayerBlueState)  && currentState == typeof(PlayerGeyserState))   return;

        UpdateInkAudioForState(targetState);
        _player.SwitchState(targetState);
    }

    private bool ColorsAreClose(Color a, Color b)
    {
        float t = 0.05f;
        return Mathf.Abs(a.r - b.r) <= t &&
               Mathf.Abs(a.g - b.g) <= t &&
               Mathf.Abs(a.b - b.b) <= t &&
               Mathf.Abs(a.a - b.a) <= t;
    }

    private void UpdateInkAudioForState(Type targetState)
    {
        if      (targetState == typeof(PlayerWhiteState)) AudioManager.Instance?.SetInkState(InkStateType.Base);
        else if (targetState == typeof(PlayerRedState))   AudioManager.Instance?.SetInkState(InkStateType.Red);
        else if (targetState == typeof(PlayerBlueState))  AudioManager.Instance?.SetInkState(InkStateType.Blue);
        else if (targetState == typeof(PlayerGreenState)) AudioManager.Instance?.SetInkState(InkStateType.Green);
    }
}
