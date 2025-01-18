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
//#-code-completion(identifier, show, jump(jumpType:), startAnimation(animation:), ., wait(_:), stopAnimation(), move(direction:), stopMoving())
//#-code-completion(identifier, show, OtherAnimations, flashlights, blinklights, oscillatelights, spin, tap, slowshake, metronome, ondulation, spinposture, spiral, slalom)
//#-code-completion(identifier, show, JumpType, high, long)
//#-code-completion(identifier, show, MoveDirection, left, right, forward, backward)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Challenge:** Perform combo moves.

For the fourth challenge, you will make the drone do some combo moves. You will be using the animate, jump, and move commands you have learned up to now! Create a [function](glossary://function) called `comboMove()`, using the commands.
 
Try starting more than one animation at a time or try moving then performing a jump.  What does the drone let you combine?
 
Be carefull to not send your drone outside its area.
*/
func comboMove() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}
//#-editable-code Tap to enter code

//#-end-editable-code

//#-hidden-code
let success = String(
 "### Congratulations!\nYou achieved your fourth mission!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.allAnyOrder([
            .stopMoving,
            .stopAnimation,
            ]),
         [String("You must perform a move/stop and start/stop an animation.")]),
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code


