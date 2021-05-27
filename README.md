# Github DM

### Description
Dear Developer, here you will find my implementation of the coding challenge.
It is hard to explain my thought process in a readme, so I hope we will have the chance to have some discussions :)

### How to use
Tested with
- XCode 12.3
- Swift 5.3

No dependencies, the project should just run.

### Features
- Offline ready
- Loads follower images
- Profile View and switch user
- Sending messages pushes the follower in the list to top
- Localized UI (English, German, Japanese)
- Light & Dark Mode

### Screenshots
Under the folder 'Screenshots' you can find screenhots where you can see the app in light/dark mode and other language.

### Architecture/Technology Choices
- MVVM + Navigators
- Swift Combine
- UIKit
- Storyboard

Why MVVM + Navigators?
1. First of all as you said we wan't to avoid massive view controllers. MVVM gives us some nice seperation between the viewcontroller and a viewmodel and therefore allows us to test our implementation easily.
2. The iOS community seems to embrace MVVM the most and also the new SwiftUI seems to do so. Therefore we can rely on a lot of community support.
3. I once saw your team writing a blog post on MVVM and also assume that the team would be most comfortable with it
4. Navigation is a big and important part that can get messy very quick. With defined navigators, we can directly see from code where navigation is supposed to go and also how the next views get set up.
It also seperates again a part away and allows us to split work better between devs.

Why Combine?
Often MVVM goes hand in hand with one of the more popular reactive frameworks (RxSwift, ReactiveCocoa).
Since libraries are not allowed I thought to use combine with UIKit.
While this approach works, there is a lot of bindings missing in UIKit and need to be extended which is quite tedious.
Also the documentation is not as detailed as one might wish.
In its current state I would probably not use it as bigger strategy to move forward and use one of the more popular libraries (if the tradeoff in regards to build time/bundle size/maintance would be fine).

### Unit Testing
I made some unit tests that should be in the same place as the view models

### Considerations
- Storyboards - Due to time constraints I have used one storyboard. In real projects I would either use a lot of seperated storyboards or generally setup the UI completely in code.
- Chat UI - I made a quick implementation of a Chat UI with a TableView and a normal TextView as input which just gets pushed up by constraints. In a prod App this would need strongly to be changed to a CollectionView (for layout flexibility) and a proper AccessoryView subclass for handling input/keyboard/layout properly.


### Functional Requirements:
