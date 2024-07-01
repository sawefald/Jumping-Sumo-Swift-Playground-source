//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

waitDroneConnected()
droneSpeed = 30
startAssessor()

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, startAnimation(animation:), ., wait(_:), stopAnimation())
//#-code-completion(identifier, show, OtherAnimation, flashlights, blinklights, oscillatelights, spin, tap, slowshake, metronome, ondulation, spinposture, spiral, slalom)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make a conditional animation.
 
 We learned the `animate()` function, which allows you to do a single animation.
 
 We also have another function `startAnimation()` that will allows you to run an animation indefinitely, until you tell the drone to stop with a `stopAnimation()` command. This is usefull when you are using conditional statements in your program, for example.
 
 Remember, the drone will move until you send the `stopAnimation` command. So use it carefully!
 
 There are several animations avaialable: `flashlights`, `blinklights`, `oscillatelights`, `spin`, `tap`, `slowshake`, `metronome`, `ondulation`, `spinposture`, `spiral`, `slalom`
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Try to **startAnimation** like blinkinglights, **wait** for 2 seconds, and **stopAnimation**.
 3. When you are ready, hit **Run My Code**, using Step Though. See how the `startAnimation` command returns immediately after execution!
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to use the conditional animations command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.stopAnimation, [String("Use the stopAnimation command")]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
