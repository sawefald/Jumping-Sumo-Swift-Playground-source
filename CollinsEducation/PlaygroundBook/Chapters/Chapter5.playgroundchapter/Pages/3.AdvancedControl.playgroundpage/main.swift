//#-hidden-code

waitDroneConnected()
droneSpeed = 30
startAssessor()

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, MotionEvent, tiltForward, tiltBackward, tiltLeft, tiltRight, shakeUp, shakeDown, flat)
//#-code-completion(identifier, show, MoveDirection, forward, backward, left, right)

//#-code-completion(identifier, show, Animation, spin, tap, slowshake, metronome, ondulation, spinposture, spiral, slalom)
//#-code-completion(identifier, show, JumpType, high, long)
//#-code-completion(identifier, show, jump(jumpType:),animate(animation:), move(direction:), .)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Advanced control using the accelerometer

 You can use your iPad’s accelerometer to create a drone remote control!
 
 First, lock your iPad in landscape mode with the home button on your right. (To do this, swipe down from the top right  of the screen to open the Control Center and tap the Orientation Lock button.) The code below was written for an iPad with this orientation.
 
 Lets do some advanced moves when you tilt the iPad, try using the move without a duration on each tilt and flat to stop.  Try doing a jump on shakeUp and a spin animation on shakeDown
 
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
        move(direction: MoveDirection.forward)
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
    (.jump(jumpType: nil), [
        String("Try shaking up/down")
        ])
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
