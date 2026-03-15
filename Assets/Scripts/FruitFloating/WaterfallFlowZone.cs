using UnityEngine;

public class WaterfallFlowZone : MonoBehaviour
{
    public Vector3 flowDirection = new Vector3(0, -1, 0);
    public float flowStrength = 10f;

    private void OnTriggerEnter(Collider other)
    {
        FruitWaterfall fruit = other.GetComponent<FruitWaterfall>();
        if (fruit != null)
        {
            fruit.EnterVerticalFlow(flowDirection, flowStrength);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        FruitWaterfall fruit = other.GetComponent<FruitWaterfall>();
        if (fruit != null)
        {
            fruit.ExitVerticalFlow();
        }
    }
}