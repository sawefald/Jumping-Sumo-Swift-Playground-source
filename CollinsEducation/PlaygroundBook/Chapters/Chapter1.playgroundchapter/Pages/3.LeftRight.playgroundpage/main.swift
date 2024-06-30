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
//#-code-completion(identifier, show, MoveDirection, left, right)
//#-code-completion(identifier, show, move(direction:duration:), .)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to turn left and right.

 1. steps: Place your drone on a flat surface with enough space around you.
 2. You will use the same command you just learned:

 `move(direction: MoveDirection, duration: value)`

 For this, direction is either `left` or `right`.
 
 ````
 move(direction: MoveDirection.left, duration: 2)
 ````
 The example above will move the drone left for 2 seconds.

 3. Try to **move left** for 1 second and **move right** for 1 second.
 
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code


//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to turn the drone!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.move(direction: .right, duration: nil), [
        String("First you will turn right using `move(direction: MoveDirection.right, duration: 1)`."),
        String("Then you will turn left using `move(direction: MoveDirection.left, duration: 1)`.")
        ]),
    (.move(direction: .left, duration: nil), [
        String("Use `move(direction: MoveDirection.left, duration: 1)` to turn left.")
        ]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


