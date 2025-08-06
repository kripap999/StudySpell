
# StudySpell 

#### Description
StudySpell is a productivity and education app designed to help its users stay motivated and build good study habits through structured focus sessions. It uses Pomodora timers, personalized to-do lists, progress tracking statistics, and soothing Harry Potter-themed ambience to help increase focus. 

### App Evaluation
Category: Productivity, Education

1. Mobile: Mobile is required for Pomodoro reminders and tasks alert notifications, a camera for study sessions, and audio for background music.
2. Story: StudySpell is valuable to students or anyone who likes to complete tasks in an organized way. It builds good study habits and improves productivity.
3. Market: The market is huge for students, adults with office tasks, or anyone who does undisturbed, focused work on a day-to-day basis. 
4. Habit: This app is extremely useful for forming good habits. Students would use it every day to complete their everyday tasks. 
5. Scope: v1 would have a pomodoro timer, a task list, and a daily study log. V2 would add elements like ambient audio playback, animations. V3 introduces a live Study Buddy mode, allowing friends to join timed sessions together for real-time sessions.

### Product Spec
1. #### User Stories (Required and Optional)

##### Required Must-have Stories:
- User can start a Pomodoro session (30-min focus + break).
- After focus session, user receives break suggestion + motivational quote or random fun facts via public API
- User sees total study time.
- Daily planner with calendar integration.
- Add tasks to a to-do list with deadlines.
- Add tasks to a spellbook (to-do list).

Optional Nice-to-have Stories:
- User can configure session/break durations in settings.
- User can register/login (via Firebase/UserDefaults).
- Peaceful ambient music and visuals during study/break.
- Harry Potter aesthetic: sounds, visuals, aesthetics.
- "Study Buddy" mode for live synced sessions with a friend.

 
#### 2. Screen Archetypes

1. Login / Register
- Auth via Firebase/email
- On success, redirect to Focus Feed

2. Focus Screen (Pomodoro Timer)
- Timer with start, pause, and reset
- Animated visual background and music
- When the timer ends, transition to Break Screen


3. Break Screen
- Motivational quote or fun break activity suggestion
- Background ambience 

4. Stats Screen
- Display daily and weekly study totals
- Optional: visual bar chart or graph (Swift Charts / Charts API)

5. Tasks Screen (Spellbook)
- Add/edit/delete tasks
- Mark tasks as complete
- Optional: group by deadline/date

6. Settings Screen
- Adjust session/break durations
- Choose theme (light/dark)
- Toggle sound/notifications


#### 3. Navigation

**Tab Navigation (Tab to Screen)**

- Focus Feed
- Stats Feed
- To-do List Feed
- Settings Feed
- Study Buddy (V3)




Flow Navigation (Screen to Screen)

- Login → Home (Focus)
- Focus session ends → Break screen
- To-do List Tab → Add/Edit Task Screen
- Stats Feed -> Detailed Weekly View (optional)
- Settings → Edit Pomodoro durations



###  Wireframes
<img width="2388" height="1668" alt="IMG_0015" src="https://github.com/user-attachments/assets/f3b15b27-6b36-48b9-8b40-cbb113759e4d" />


[BONUS] Digital Wireframes & Mockups
[BONUS] Interactive Prototype

### Video
<div>
    <a href="https://www.loom.com/share/9f4805c339a34b56b230a21a12f3bbfe">
    </a>
    <a href="https://www.loom.com/share/9f4805c339a34b56b230a21a12f3bbfe">
      <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/9f4805c339a34b56b230a21a12f3bbfe-bb7a4f759de22829-full-play.gif">
    </a>
  </div>

### Schema
[This section will be completed in Unit 9]

### Models
[Add table of models]



### Networking
[Add list of network requests by screen ]
[Create basic snippets for each Parse network request]
[OPTIONAL: List endpoints if using existing API such as Yelp]



