using System.Collections;
using UnityEngine;

public class CreditScroller : MonoBehaviour
{
    [SerializeField] float scrollSpeed = 50f;
    [SerializeField] RectTransform contenedor;
    [SerializeField] RectTransform panel; // arrastra el PanelCreditos aquí

    float startPositionY;
    float endPositionY;
    bool scrolling = false;

    IEnumerator Start()
    {
        yield return null; // espera a que el Content Size Fitter calcule

        startPositionY = contenedor.anchoredPosition.y;
        // el final es cuando todo el contenido ha salido por arriba del panel
        endPositionY = startPositionY + contenedor.rect.height + panel.rect.height;

        Debug.Log($"Start: {startPositionY} | End: {endPositionY} | Height: {contenedor.rect.height}");

        StartCredits();
    }

    public void StartCredits() => scrolling = true;

    void Update()
    {
        if (!scrolling) return;

        contenedor.anchoredPosition += Vector2.up * scrollSpeed * Time.deltaTime;

        if (contenedor.anchoredPosition.y >= endPositionY)
        {
            scrolling = false;
            OnCreditsFinished();
        }
    }

    void OnCreditsFinished()
    {
        Debug.Log("Créditos terminados");
    }

    public void ResetCredits()
    {
        scrolling = false;
        contenedor.anchoredPosition = new Vector2(contenedor.anchoredPosition.x, startPositionY);
    }
}
