# Contributions:

## Ankit  (Release 25%, Overall 25%)
### Alpha
- Implemented the Home Screen of the App
- Began working on the Create Meeting screen
- Created the layout for a basic settings and friends/groups screen
### Beta
- Home screen refined to load events from firebase and sort based on status (accepted, declined, etc)
- Home screen cards refined to have dynamic buttons based on status
- Handeled Formatting and comparing event Dates of Events
- Immplimented Create Meeting screen
- Immplimented View for seeing trails on existing events
- Popup View modals created (but not integrated)

## Bo (Release 25%, Overall 25%)
### Alpha
- Created and configured Firebase project
- Added Firebase logic for login/register functionality (paired w/ William)
- Added segues for login/register/homepage (paired w/ William)
### Beta
- Implemented adding to Firebase DB when an event is created
- Implemented fetching from Firebase DB when viewing events on the home screen
- Helped William debug issues with settings screen

## William (Release 25%, Overall 25%)
### Alpha
- Reconfigured login and register components to fit Firebase functionality
- Added Firebase logic for login/register functionality (paired w/ Bo)
- Added segues for login/register/homepage (paired w/ Bo)
### Beta
- Implement settings screen with username and displaynames
- Set up storing profile pictures with Firebase Storage and saving the endpoint in Firebase Database
- Set up changing profile pictures with gallery or camera

## Lorenzo (Release 25%, Overall 25%)
### Alpha
- Implemented login screen
- Implemented register screen
- Added auto-login functionality
- Added basic map screen
### Beta
- Implemented user class + view model to pull user data from Firebase
- Minimap created for each event based on chosen event location
- Database schema altered to include latitude/longitude data for setting map region
- Sample display of map directions created

# Differences:
- We added a page for creating and viewing events which was not mentioned in our original proposal  
- The Firebase backend is setup which we did not mention creating in the proposal
- We ended up not having a navigation bar since we didn’t get to some of our stretch goals that we set out to do in this phase. So it wouldn’t make sense to have a nav bar with just the home screen on it.
- The “Maps page” we referred to in Alpha ended up splitting into three different map views with unique functionality, taking up much more time than anticipated. The views included a searchable map view for event creation, a minimap based on event location, and a view displaying all users’ locations attending an event.
- We did not get to creating the friends and groups view, however the backend is set up and the frontend adds all users of the app for events.
- The “core hangout functionality” we referred to in the proposal didn’t make much sense to include in one bullet point because of the number of completed elements needed. For an event to fully work, the backend, location retrieval, notifications, and friends/groups elements would all need to be 100% done.
- Cleaning up the UI was part of final release but the main screens are already refined.
