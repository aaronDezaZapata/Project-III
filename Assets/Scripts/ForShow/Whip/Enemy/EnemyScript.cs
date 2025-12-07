using UnityEngine;

public class EnemyScript : MonoBehaviour
{
    private bool isStunned = false;

    public void Stun(bool state)
    {
        isStunned = state;
        if (isStunned)
        {
            Debug.Log(gameObject.name + " está aturdido!");
        }
        else
        {
            
            Debug.Log(gameObject.name + " se recuperó.");
        }
    }

    // Detectar colisión cuando es lanzado
    void OnCollisionEnter(Collision collision)
    {
        
        if (isStunned && collision.relativeVelocity.magnitude > 5f)
        {
            
            if (collision.gameObject.CompareTag("Enemy"))
            {
                Destroy(collision.gameObject); 
                Destroy(this.gameObject);      
            }
            else
            {
                
                Stun(false);
            }
        }
    }
}
