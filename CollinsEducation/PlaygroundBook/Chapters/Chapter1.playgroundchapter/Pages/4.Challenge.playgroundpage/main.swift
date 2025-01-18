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
//#-code-completion(identifier, show, move(direction:duration:), .)
//#-code-completion(identifier, show, MoveDirection, forward, backward, right, left)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Challenge:** Move in a pattern.

For the first challenge, you will make the drone move in a pattern return to it's starting point. You will be using all the commands you have learned up to now! Create a [function](glossary://function) called `pattern()`, using the move commands.
 
You must move at least 4 times to be successful.
 
You may need to play with how long to turn to return to your starting position.
*/
func pattern() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}
//#-editable-code Tap to function name

//#-end-editable-code

//#-hidden-code
let success = String(
 "### Congratulations!\nYou achieved your first mission!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.allAnyOrder([
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            ]),
         [String("You must move and turn 4 times to complete your pattern.")]) ]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


