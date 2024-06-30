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
//#-code-completion(identifier, show, move(direction:duration:), .)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Challenge:** Move in a square.

For the first challenge, you will make the drone follow a square path. You will be using all the commands you have learned up to now! Create a [function](glossary://function) called `square()`, using the move commands.
 
You may need to play with how long to turn for to make a 90 degree turn.
*/
func square() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}
//#-editable-code Tap to enter code

//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
 "### Congratulations!\nYou achieved your first mission!\n\n[**Next Page**](@next)",
    comment: "challenge 1 page success")
let expected: [Assessor.Assessment] = [
    (.all([
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil),
            .move(direction: nil, duration: nil)
            ]),
         [NSLocalizedString("You must move & turn in same direction 4 times.", comment: "square hint")]) ]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


