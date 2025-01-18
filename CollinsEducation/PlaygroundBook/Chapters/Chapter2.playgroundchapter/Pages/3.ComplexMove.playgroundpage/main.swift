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
//#-code-completion(identifier, show, move(speed:turn:duration:))
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make complex moves.
  
 We learned the `move()` function, which allows you to move in one direction at a time.
 
 To move in multiple directions at the same time, there is another `move` function that takes all both directions as parameters.
 
 Every [parameter](glossary://parameter) defines the move speed on its axis, and the rotation speed. The drone will move in all specified directions at the same time.
 
 `move(speed:value, turn:value, duration:value)`

  - speed: longitudinal speed in %, positive to move forward, negative to move backward.
  - turn: lateral speed in %, positive to turn right, negative to turn left.

 ````
 move(speed:20, turn:20, duration:2)
 ````
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Try this above command first to see how the drone reacts, before making you own experiment.
 3. When you are ready, hit **Run My Code**.
 */
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = String("### Congratulations!\nYou know how to use the complex move command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.complexMove(nil, duration: nil), [
        String("Try the command `move(speed:20, turn:20, duration:2)`")
        ]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


