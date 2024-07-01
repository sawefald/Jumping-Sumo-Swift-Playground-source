//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

waitDroneConnected()
droneSpeed=30
startAssessor()


//#-code-completion(everything, hide)
//#-code-completion(identifier, show, MoveDirection, forward, backward, right, left)
//#-code-completion(identifier, show, droneSpeed, move(direction:duration:), ., =)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to control speed.
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to change the speed of the drone is

 `droneSpeed = value`

 The [variable](glossary://variable) represents the percentage of the drone max speed: **50** is half speed, **100** is full speed.

 4. Try to move forward 2 seconds at 10%, then backward 2 seconds at 10%
 5. Try again, this time at 80%.
 6. Think about how far you the drone went at the different speeds.
 7. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code


//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to change the speed of your drone!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.speed(nil), [
        String("Use `droneSpeed = value<0..100>` to change the drone speed.")
        ])
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
