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
//#-code-completion(identifier, show, move(speed:turn:duration:), .)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Challenge:** Move in a circle.

For the second challenge, you will make the drone follow a circle path. You will be using the complex move you have learned up to now! Create a [function](glossary://function) called `circle()`, using the move commands.
 
You may need to play with speed percentages to see how to make the circle.
*/
func circle() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}
//#-editable-code Tap to enter code

//#-end-editable-code

//#-hidden-code
let success = String(
 "### Congratulations!\nYou achieved your second mission!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.all([
            .complexMove(nil, duration: nil),
            ]),
         [String("You must perform a complex move.")]) ]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


