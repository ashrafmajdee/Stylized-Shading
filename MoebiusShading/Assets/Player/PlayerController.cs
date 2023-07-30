using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Animator animator;
    public Transform playerCamera;
    public float speed = 2f;
    public float cameraRotationSpeed = 1f;
    public float playerRotationSpeed = 10f;

    

    private Vector3 velocity;
    private float cameraRotation;
    private bool isMoving = false;
    private void Update()
    {

            cameraRotation = cameraRotationSpeed * ((Input.GetKey(KeyCode.Q) ? 1 : 0) + (Input.GetKey(KeyCode.E) ? -1 : 0));

            Vector3 lookDir = transform.position - playerCamera.position;
            Vector3 lookForward = new Vector3(lookDir.x, 0,lookDir.z).normalized;
            Vector3 lookSide = -Vector3.Cross(lookForward, Vector3.up);
                
            
            
            Vector3 inputForward =  lookForward * Input.GetAxisRaw("Vertical");
            Vector3 inputLateral =  lookSide * Input.GetAxisRaw("Horizontal");
            
            velocity = (inputForward + inputLateral).normalized * speed;

            isMoving = Mathf.Abs(velocity.x) > 0 || Mathf.Abs(velocity.z) > 0;
            animator.SetBool("isMoving", isMoving);
            

    }

    private void FixedUpdate()
    {
        playerCamera.RotateAround(transform.position,Vector3.up,cameraRotation * Time.fixedDeltaTime);
        transform.Translate(velocity * Time.fixedDeltaTime);
        if (isMoving)
        {
            Quaternion to = Quaternion.LookRotation(velocity, Vector3.up);
            Quaternion from = animator.transform.localRotation;
            animator.transform.localRotation = Quaternion.RotateTowards(from,to,playerRotationSpeed);
        }
        
    }
    
}
