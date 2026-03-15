using UnityEngine;

public class HorizontalWaterZone : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        FruitWaterfall fruit = other.GetComponent<FruitWaterfall>();
        if (fruit != null)
        {
            fruit.EnterHorizontalWater();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        FruitWaterfall fruit = other.GetComponent<FruitWaterfall>();
        if (fruit != null)
        {
            fruit.ExitHorizontalWater();
        }
    }
}