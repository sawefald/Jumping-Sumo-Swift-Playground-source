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
//#-code-completion(identifier, show, jump(jumpType:), .)
//#-code-completion(identifier, show, JumpType, high, long)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to animate your drone

 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to perform jump with the drone is

 `jump(jumpType: JumpType)`

 The [jump](glossary://jump) is the type of activity the drone will do on its own once commanded.

 For this, jumps are `high` or `long`.
 
 ````
 jump(jumpType: JumpType.long)
 ````
 The example above will have the drone perform a long jump.

 3. Try the **long jump** followed by the **high jump**.
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code


//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to use the jump command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.jump(jumpType: .long), [
        String("First you will do a long jump `jump(jumpType: JumpType.long)`."),
        String("Then you will do a high jump `jump(jumpType: JumpType.high)`.")
        ]),
    (.jump(jumpType: .high), [
        String("Use `jump(jumpType: JumpType.high)`` to do a high jump")
        ])
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
