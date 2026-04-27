using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UIHoverEffect : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [Header("Scale")]
    public Vector3 normalScale = Vector3.one;
    public Vector3 hoverScale = new Vector3(1.08f, 1.08f, 1f);

    [Header("Position")]
    public Vector2 normalAnchoredPos;
    public Vector2 hoverOffset = new Vector2(10f, -4f);

    [Header("Color")]
    public Image targetImage;
    public Color normalColor = Color.white;
    public Color hoverColor = new Color(1.1f, 1.1f, 1.1f, 1f);

    [Header("Speed")]
    public float speed = 10f;

    private RectTransform rectTransform;
    private Vector3 targetScale;
    private Vector2 targetPos;

    void Awake()
    {
        rectTransform = GetComponent<RectTransform>();

        if (targetImage == null)
            targetImage = GetComponent<Image>();

        normalAnchoredPos = rectTransform.anchoredPosition;
        targetScale = normalScale;
        targetPos = normalAnchoredPos;

        if (targetImage != null)
            targetImage.color = normalColor;
    }

    void Update()
    {
        rectTransform.localScale = Vector3.Lerp(
            rectTransform.localScale,
            targetScale,
            Time.unscaledDeltaTime * speed
        );

        rectTransform.anchoredPosition = Vector2.Lerp(
            rectTransform.anchoredPosition,
            targetPos,
            Time.unscaledDeltaTime * speed
        );

        if (targetImage != null)
        {
            targetImage.color = Color.Lerp(
                targetImage.color,
                IsHovering() ? hoverColor : normalColor,
                Time.unscaledDeltaTime * speed
            );
        }
    }

    private bool hovering = false;

    public void OnPointerEnter(PointerEventData eventData)
    {
        hovering = true;
        targetScale = hoverScale;
        targetPos = normalAnchoredPos + hoverOffset;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        hovering = false;
        targetScale = normalScale;
        targetPos = normalAnchoredPos;
    }

    private bool IsHovering()
    {
        return hovering;
    }
}
