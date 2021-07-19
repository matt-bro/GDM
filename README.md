# Github DM

<p align="center">
<img src="https://raw.githubusercontent.com/matt-bro/GDM/main/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202021-05-27%20at%2016.10.51.png" width="225" height="400">
</p>

### Description
A fake Github chat client to test a range of Swift combine features with UIKit.

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
- Should work with Accessibility Sizes

### Screenshots
Under the folder 'Screenshots' you can find screenhots where you can see the app in light/dark mode and other language.

### Concept
Some scribbles under 'Concept'

### Architecture/Technology Choices
- MVVM + Navigators
- Swift Combine
- UIKit
- Storyboard


### Unit Testing
I made some unit tests that should be in the same place as the view models


### Functional Requirements:
- Show a list of users retrieved from any publicly available GitHub user account on the initial screen.
- Make sure to show each user's GitHub handle (i.e., their account name with the '@' prefix) and their profile image on this screen.
- Retrieve the list of users.
- Tapping any of these followers will transition to a direct messaging (DM) screen.
- The user can virtually send/receive messages to/from the follower on the message screen.
- Implement a dummy post and response.
- The follower echoes a message sent by the user after a second.
- The follower’s echo text repeats the user’s message twice, e.g. echo “Hi. Hi.” for message “Hi.”
