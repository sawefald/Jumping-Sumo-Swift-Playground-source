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
//#-code-completion(identifier, show, move(direction:), ., wait(_:), stopMoving())
//#-code-completion(identifier, show, MoveDirection, left, right, forward, backward)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make a conditional move.
 
 We learned the `move()` function, which allows you to move in one or multiple directions during a certain duration of time.
 
 We also have another `move()` function that will allows you to move indefinitely, until you tell the drone to stop with a `stopMoving()` command. This is usefull when you are using conditional statements in your program, for example.
 
 Remember, the drone will move until you send the `stopMoving` command. So use it carefully!
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Try to **move** in a direction, **wait** for 2 seconds, and **stopMoving**.
 3. When you are ready, hit **Run My Code**, using Step Though. See how the `move` command returns immediately after execution!
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to use the conditional move command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.stopMoving, [String("Use the stopMove command")]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
