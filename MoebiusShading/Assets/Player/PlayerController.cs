using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor.UIElements;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Camera cam;
    public float speed = 2f;
    public float mouseSensitivity;
    private float cameraVerticalRotation = 0;

    private bool lockedCursor = false;

    private void Start()
    {
        setLockedCursor(true);
    }

    private Vector3 velocity;
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            setLockedCursor(!lockedCursor);
        }

        if (lockedCursor)
        {
            float inputX = mouseSensitivity * Input.GetAxis("Mouse X");
            float inputY = mouseSensitivity * Input.GetAxis("Mouse Y");

            cameraVerticalRotation -= inputY;
            cameraVerticalRotation = Mathf.Clamp(cameraVerticalRotation, -90f, 90f);
            cam.transform.localEulerAngles = Vector3.right * cameraVerticalRotation;
            transform.Rotate(Vector3.up,inputX);
            
                
            Vector3 inputForward =  Vector3.forward * Input.GetAxis("Vertical");
            Vector3 inputLateral =  Vector3.right * Input.GetAxis("Horizontal");
            velocity = (inputForward + inputLateral).normalized * speed;
        }

    }

    private void FixedUpdate()
    {
        transform.Translate(velocity * Time.fixedDeltaTime);
    }

    private void setLockedCursor(bool state)
    {
        lockedCursor = state;
        Cursor.visible = state;
        Cursor.lockState = state ? CursorLockMode.Locked : CursorLockMode.None;
    }
}
