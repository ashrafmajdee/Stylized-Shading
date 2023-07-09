using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Transform playerBody;
    public float speed = 2f;
    public float rotationSpeed = 1f;


    private void Start()
    {
    }

    private Vector3 velocity;
    private float rotation;
    private void Update()
    {

            rotation = rotationSpeed * ((Input.GetKey(KeyCode.Q) ? 1 : 0) + (Input.GetKey(KeyCode.E) ? -1 : 0));
            
            
                
            Vector3 inputForward =  Vector3.forward * Input.GetAxisRaw("Vertical");
            Vector3 inputLateral =  Vector3.right * Input.GetAxisRaw("Horizontal");
            velocity = (inputForward + inputLateral).normalized * speed;


    }

    private void FixedUpdate()
    {
        playerBody.Rotate(Vector3.up,rotation * Time.fixedDeltaTime);
        playerBody.Translate(velocity * Time.fixedDeltaTime);
    }
    
}
