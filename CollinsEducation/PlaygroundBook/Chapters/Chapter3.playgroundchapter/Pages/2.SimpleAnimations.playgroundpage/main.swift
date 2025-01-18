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
//#-code-completion(identifier, show, animate(animation:), .)
//#-code-completion(identifier, show, Animations, spin, tap, slowshake, metronome, ondulation, spinposture, spiral, slalom)
//#-end-hidden-code

/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to animate your drone

 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to perform a simple animation of the drone is

 `animate(animation: Animations)`

 The [animation](glossary://animation) is the type of activity the drone will do on its own once commanded.

 For this, animations are `spin`, `tap`, `slowshake`, `metronome`, `ondulation`, `spintoposture`, `spiral`, and `slalom`
 
 ````
 animate(animation: Animations.spin)
 ````
 The example above will have the drone perform a spin animation.

 3. Try the **spin animation** followed by the **slowshake animation**.
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code


//#-hidden-code
let success = String(
    "### Congratulations!\nYou know how to use the animate command!\n\n[**Next Page**](@next)")
let expected: [Assessor.Assessment] = [
    (.animate(animation: .spin), [
        String("First you will do a spin animation `animate(animation: Animations.spin)`."),
        String("Then you will do a slowshake animation `animate(animation: Animations.slowshake)`.")
        ]),
    (.animate(animation: .slowshake), [
        String("Use `animate(animation: Animations.slowshake)` to do a slowshake animation.")
        ])
]
checkAssessment(expected:expected, success: success)
//#-end-hidden-code
