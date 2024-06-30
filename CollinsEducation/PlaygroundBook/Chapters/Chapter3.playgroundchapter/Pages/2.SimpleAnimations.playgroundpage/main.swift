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
//#-code-completion(identifier, show, move(), wait(_:))
//#-code-completion(identifier, show, MoveDirection, forward, backward)
//#-code-completion(identifier, show, duration)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to move forward and backward.

 1. steps: Place your drone on a flat surface with enough space around you.

 For this, direction is either `forward` or `backward`.
 
 ````
 move(direction: MoveDirection.forward, duration: 2)
 ````
 The example above will move the drone forward for 2 seconds.

 3. Try to **move forward** for 1 second and **move backward** for 1 second. Remember, you can use the `wait` command if you want.
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code


//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to use the pitch command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.move(direction: .forward, duration: nil), [
        String("First you will move forward using `move(direction: MoveDirection.forward, duration: 1)`."),
        String("Then you will move backward using `move(direction: MoveDirection.backward, duration: 1)`.")
        ]),
    (.move(direction: .backward, duration: nil), [
        String("Use `move(direction: MoveDirection.backward, duration: 1)` to move backward.")
        ]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
