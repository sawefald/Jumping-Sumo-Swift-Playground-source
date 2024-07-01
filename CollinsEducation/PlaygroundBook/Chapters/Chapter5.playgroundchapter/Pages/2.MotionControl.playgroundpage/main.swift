//#-hidden-code

waitDroneConnected()
droneSpeed = 30
startAssessor()

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, MotionEvent, tiltForward, tiltBackward, tiltLeft, tiltRight)
//#-code-completion(identifier, show, MoveDirection, forward, backward, left, right)
//#-code-completion(identifier, show, move(direction:duration:), .)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Control your drone by tilting your iPad.

 You can use your iPad’s accelerometer to create a drone remote control!
 
 First, lock your iPad in landscape mode with the home button on your right. (To do this, swipe down from the top right  of the screen to open the Control Center and tap the Orientation Lock button.) The code below was written for an iPad with this orientation.
 
 Now you’re ready to try it out!  You can update the code to turn left and right the choices are `tiltRight` and `tiltLeft`
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Place your iPad on a flat surface as well. This will help with sensor and data calibration.
 3. When you are ready, tap **Run My Code**.
 4. Grab your iPad and tilt it forward and backward. What do you observe?
*/
// run forever
while true {
    let event = waitNextMotionEvent()
    
    switch event {
    case .tiltForward:
        move(direction: MoveDirection.forward, duration: 1)
    case .tiltBackward:
        move(direction: MoveDirection.backward, duration: 1)
    //#-editable-code Tap to enter code
    //#-end-editable-code
    default:
        break
    }
}

//#-hidden-code
let success = String(
    "### Congratulations!** You managed to understand how the iPad accelerometer works! Now it is time to create a drone remote control using code!!!!!\n\n[**Next Page**](@next)")

let expected: [Assessor.Assessment] = [
    (.move(direction: .forward, duration: nil), [
        String("Tilt your ipad  forward"),
        String("Then you will move backward using `move(direction: MoveDirection.backward, duration: 1)`.")
        ]),
    (.move(direction: .backward, duration: nil), [
        String("Use `move(direction: MoveDirection.backward, duration: 1)` to move backward.")
        ])
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
