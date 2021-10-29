# ER:Requirements Specification Component

Oversee is the new essential web platform for social media management, allowing users to better plan their marketing scheme and see their social performance.

## A1: Oversee

This project intends to specify, develop and promote a system available through the web for the management of social media marketing campaigns.

With the increasing influence of social media, we think it would be useful for individual content creators or marketing teams to plan and evaluate their social media impact. Our clients will be able to manage their projects, from marketing campaigns to individual posts, in an organized manner and evaluate their performance in the platforms they are posting to.

We believe a simple design is very effective when using a planning platform. Therefore, we will invest in an intuitive design for our platform. To achieve this, the user will be presented with a simple dashboard that contains all of his projects, either created by or assigned to him. Upon selecting a project, the user can create the necessary tasks and additionally, subtasks. If the user needs to plan sequential tasks, he may do so with our timeline feature.
The user will also have at his disposal tags and collaborator assignments, so that project administrators can easily know each type of tasks within the project and who is working on them. These features will also allow any user to filter through tasks, based on tag or assigned personnel.
Our clients can make use of a search bar that not only allows them to search for a project or tasks they are assigned to, but also other configurations within the web app, such as their profile page.
We will also make sure the user experience isn't affected by the device that our client uses, by adopting a responsive design.

Although all users will be presented with an introductory page, explaining the aim of our platform, only those with an account will be able to edit their projects or check their social performance.
Users will be categorized according to their permissions. Team members are users that are a part of a project. Readers are all team members that have reading privileges. Editors are team members that are able to manage tasks. Owners are team members that are allowed to invite users to their project and manage the team members' access and roles in each project.

---

## A2: Actors and User stories

This artifact contains the description of the actors of the system and their respective user stories.

### 1. Actors

![Actors Diagram](https://i.imgur.com/rJ5BvN3.png)

|Actors|Description|Examples|
|:---:|:---:|:---:|
|User|Generic user that accesses the website|n/a|
|Visitor|Unauthenticated user that has access to public information, such as the main page|n/a|
|Client|Authenticated user, that has access to his projects|nenieats|
|Team Member|Authenticated user, that is part of a project|nenieats|
|Owner|Authenticated user that is owner of a project and has team management privileges|nenieats|
|Editor|Authenticated user that has editing privileges to a project|nenieats|
|Reader|Authenticated user that has reading and commenting privileges to a project|nenieats|
|Administrator|Authenticated user that is responsible for the management of users and supervision of the web app|admin|
|OAuth API|External OAuth API that can be used to register or authenticate into the system|Google, Facebook, Instagram, Twitter|
|Statistics API|External API that can be used to analyze a user's statistics|Facebook, Instagram, Twitter|

Table 1: Actor's description

### 2. User Stories

#### 2.1. User

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US101|Home Page|High|As a User, I want to access home page, so that I can see a brief website's presentation|
|US102|Contacts Page|High|As a User, I want to access the contacts page, so that I can know how to contact the website|

Table 2: User's user stories

#### 2.2. Visitor

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US201|Sign-in|High|As a Visitor, I want to authenticate into the system, so that I can access privileged information|
|US202|Sign-up|High|As a Visitor, I want to register myself into the system, so that I can authenticate myself into the system|
|US203|Sign-up using external API|Low|As a Visitor, I want to register a new account linked to my Google account, so that I can access privileged information|
|US204|Sign-in using external API|Low|As a Visitor, I want to sign-in through my Google account, so that I can authenticate myself into the system|

Table 3: Visitor's user stories

#### 2.3. Authenticated User

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US301|Log out|High|As an Authenticated User, I want to log out of my session, so that I can share the same device with other users|
|US311|See Profiles|High|As an Authenticated User, I want to see Client's profiles, so that I can see more details about them|
|US321|Edit Account|High|As an Authenticated User, I want to edit my account, so that I can change my password|
|US322|Delete account|High|As an Authenticated User, I want to delete my account, so that I no longer share my information with the platform|
|US331|Recover password|High|As an Authenticated User, I want to recover my password, so that I am not locked out of my account|

Table 4: Authenticated User's user stories

#### 2.4. Client

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US401|See projects|High|As a Client, I want to see the projects I'm participating in, so that I can work in them|
|US402|Create project|High|As a Client, I want to create a project, so that I can work in it|
|US403|Join team|High|As a Client, I want to join a team, so that I can participate on the project|
|US411|Edit Profile|High|As a Client, I want to edit my profile, so that I can keep it updated|
|US412|Search|Medium|As a Client, I want to be able to search the entire platform, so that I can find my projects/tasks, other users and even settings easily|
|US421|Change Settings|Medium|As a Client, I want to change my settings, so that I can customize my user experience|
|US431|Social Media|Low|As a Client, I want to be able to connect my social media accounts to my account, so that I can get in-platform statistics about how my social media account is going|
|US441|Submit support tickets|Low|As a Client, I want to submit support tickets, so that I can get help with problems I may have with the platform|
|US442|Report Client|Low|As a Client, I want to report other Clients, so that I can notify the administrator of a client's inappropriate profile or actions|
|US451|Receive Notifications|Low|As a Client, I want to receive notifications, so that I can keep up with my projects and reports|

Table 5: Client's user stories

#### 2.5. Team Member

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US501|See project info|High|As a Team Member, I want to see basic information about the project I am in, it's members and their roles.|
|US502|Leave project|High|As a Team Member, I want to leave a project I'm participating in, so that I can stop working in it|
|US503|See tasks|High|As a Team Member, I want to see tasks inside my projects, so that I can know what is being planned for the project|
|US504|Filter tasks|High|As a Team Member, I want to search tasks filtered by tag inside a project, so that I can easily find specific tasks|
|US511|Status Board|Medium|As a Team Member, I want to see the status of the tasks, so that I can see the tasks that need to be worked on|
|US512|Comment|Medium|As a Team Member, I want to comment on tasks, so that I can express my point of view or ask a question|
|US521|Check statistics using external API|Low|As a Team Member, I want to see the statistics of the project I'm working or worked on, so that I can analyze its performance|

Table 6: Team Member's user stories

#### 2.6. Owner

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US601|Add team members|High|As an Owner, I want to add team members to my project specifying their access privileges, so that they can access and/or edit them according to the given permissions|
|US602|Change team members' permissions|High|As an Owner, I want to change the other team members' access permissions, so that I can allow readers to become editors and vice-versa|
|US603|Remove team members|High|As an Owner, I want to remove team members, so that I can remove their access to my project|
|US604|End Project|High|As an Owner, I want to mark a project as finished, so that I can notify all team members that the project is complete|
|US605|Edit project info|High|As an Owner, I want to edit a project's information, such as name, description and due date, so that I can keep them up-to-date|
|US606|Reopen Project|Medium|As an Owner, I want to reopen a project, so that I can notify all team members that the previously completed project has the need for expansion|
|US611|Remove Comments|Low|As an Owner, I want to remove comments, so that I can delete unnecessary or inappropriate comments|


Table 7: Owner's user stories

#### 2.7. Editor

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US701|Create Task|High|As an Editor, I want to create a task indicating its properties (name, tags, due date, assignments, etc.), so that it can be seen by other team members|
|US702|Edit Task|High|As an Editor, I want to edit a task, so that it is up-to-date|
|US703|Remove Task|High|As an Editor, I want to remove a task, so that I can remove unnecessary tasks|
|US704|Add Subtasks|High|As an Editor, I want to add tasks to another task, so that I can specify additional steps to complete a task|
|US705|Dependency between tasks|Medium|As an Editor, I want to create tasks dependent on other ones, so that I can see what tasks should be completed before I can complete another one|
|US706|Checklist|Medium|As an Editor, I want to create a checklist within a task, so that I can specify small tasks needed to complete a task|

Table 8: Editor's user stories

#### 2.8. Administrator

|Identifier|Name|Priority|Description|
|:---:|:---:|:---:|:---:|
|US801|Manage Users|High|As an Administrator, I want to manage the app's users, so that inactive or unfaithful users can't access the website|
|US802|User statistics|Medium|As an Administrator, I want to see statistics about the app's users, like the total number of users and demographic information|
|US803|Add Administrator|Medium|As an Administrator, I want to be able to add administrators to the app, so that I can have a team managing the platform|
|US811|User support|Low|As an Administrator, I want to answer user questions about the app, so that I can know if something is not working and help users|
|US812|Review reported users|Low|As an Administrator, I want to be able to review users that have been reported for infringing the service's rules, so that I can act accordingly to the users' behavior|

Table 9: Administrator's user stories


### 3. Supplementary Requirements

This annex contains business rules, technical requirements and other non-functional requirements on the project.

#### 3.1. Business rules

|Identifier|Name|Description|
|:---:|:---:|:---:|
|BR01|Deleted Client|When a Client deletes his account, his actions(completed tasks, comments, etc…) will be associated to an anonymous Client|
|BR02|Deadline|The deadline for an active task must be greater than the creation date of the task|
|BR03|Reply to own comment|The Editor can reply to his own comments, similar to a thread system|
|BR04|Completed tasks|When all subtasks are marked as complete, the parent task is automatically marked as complete|
|BR05|Access to project|A project is only visible by team members|

#### 3.2. Technical requirements

|Identifier|Name|Description|
|:---:|:---:|:---:|
|TR01|Availability|The system must be available 99 percent of the time in each 24-hour period|
|TR02|Accessibility|The system must ensure that everyone can access the pages, regardless of whether they have any handicap or not, or the Web browser they use|
|TR03|Usability|The system should be simple and easy to use|
|TR04|Performance|The system should have response times shorter than 2s to ensure the user's attention|
|TR05|Web Application|The system should be implemented as a Web application with dynamic pages (HTML5, JavaScript, CSS3 and PHP)|
|TR06|Portability|The server-side system should work across multiple platforms (Linux, macOS, etc.)|
|TR07|Database|The PostgreSQL 9.13 database management system must be used|
|TR08|Security|The system shall protect information from unauthorized access through the use of an authentication and verification system|
|TR09|Robustness|The system must be prepared to handle and continue operating when runtime errors occur|
|TR10|Scalability|The system must be prepared to deal with the growth in the number of users and their actions|
|TR11|Ethics|The system must respect the ethical principles in software development (for example, the password must be stored encrypted to ensure that only the owner knows it)|

The most important technical requirements are:
- Accessibility, so that our platform's usage isn't limited by either technical issues or physical capabilities.
- Security, as it is crucial not only for the business' viability, but also for the peace of mind of our users and to keep the web safe as a whole.
- Ethics, because software interacts with society and therefore we believe it is important for it to be guided by good principles that ensure it improves life for everyone.


#### 3.3. Restrictions

|Identifier|Name|Description|
|:---:|:---:|:---:|
|C01|Deadline|The system should be ready to use at the end of the semester|


---


## A3: User Interface Prototype

This artefact's main goals are: previewing the user interface of the web app, specify multiple interactions between the user and the interface and identify the previously described user requirements.

It is divided in four subsections: an overview of the interface with common features; the architecture of the web app, from the view of a user, also known as a sitemap; interactions between the user and the interface, organized as sequences of screens, also known as wireflows; interfaces of various pages of the web app.

### 1. Interface and common features

Oversee is a project management web application based on HTML5, JavaScript and CSS. The user interface was implemented using the [Bootstrap 5](https://getbootstrap.com/docs/5.0/getting-started/introduction/) framework.

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Dashboard Desktop](https://i.imgur.com/VeZtwoL.png) | ![Homepage Mobile](https://i.imgur.com/tjuRU5Q.png)|

Legend:
1. Logo
2. Navbar
3. Content

This figure illustrates some features common to the core pages of the application:
- A responsive design that adapts well to screens of all sizes, from 4k to small phone screens.
- A thoughtful use of color to situate and guide the user's action, like highlighting buttons that are clickable and the current tab the user is in.
- A simple and familiar interface that uses elements from other popular, "tried and tested", project management solutions to eliminate or diminish the platform's learning curve.

### 2. Sitemap

Below is a sitemap highlighting the relationship between the website's different pages.

![SiteMap](https://i.imgur.com/7ldwUX8.png)


### 3. Storyboards

Wireflows are presented to represent some main interactions with the system using a sequence of interfaces and explaining how navigation is done between them. 

![Landing](https://i.imgur.com/ZuHzeCx.png)
Figure 1: Wireflow centered on the unauthenticated user's options


![Admin](https://i.imgur.com/Mg3pCH5.png)
Figure 2: Wireflow centered on the admin's options


![Dashboard](https://i.imgur.com/nfO9LYb.jpg)
Figure 3: Wireflow centered on the dashboard actions


![Create Project](https://i.imgur.com/MysCgPx.png)
Figure 4: Wireflow centered on the creation of a project


![Project](https://i.imgur.com/KFEPdif.jpg)
Figure 5: Wireflow centered on the project page actions


![Profile](https://i.imgur.com/IH2JBii.png)

Figure 6: Wireflow centered on the profile actions


![Social Media](https://i.imgur.com/sGsWBGj.jpg)

Figure 7: Wireflow centered on the social media accounts


[Invision Freehand Project](https://projects.invisionapp.com/freehand/document/7NLN9mKUE)


### 4. Interfaces

The following interfaces represent the main features of the web app and are ordered by relevance. These interfaces help to preview the features and behavior of the final product's different screens, both their desktop (left) and mobile (right) versions.

#### UI01: Home

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![HomePage Desktop](https://i.imgur.com/Tz0UrGh.png) | ![HomePage Mobile](https://i.imgur.com/2OB9RLr.png)
|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/

#### UI02: Contacts

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Contacts Desktop](https://i.imgur.com/uECo9OW.png) | ![Contacts Mobile](https://i.imgur.com/bnoOumd.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/contacts.php

#### UI03: Sign up

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Sign up Desktop](https://i.imgur.com/u2MwhRG.png) | ![Sign up Mobile](https://i.imgur.com/VY3rh1v.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/sign_up.php

#### UI04: Sign in

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Sign in Desktop](https://i.imgur.com/J0vn7pH.png) | ![Sign in Mobile](https://i.imgur.com/wsO5dfe.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/sign_in.php

#### UI05: Dashboard

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Dashboard Desktop](https://i.imgur.com/O85KGuN.png) | ![Homepage Mobile](https://i.imgur.com/dTBwrV6.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/dashboard.php

#### UI06: Search

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Dashboard Desktop](https://i.imgur.com/obiEh8U.png) | ![Homepage Mobile](https://i.imgur.com/M7mIKzs.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/search.php

#### UI07: Project overview

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Overview Desktop](https://i.imgur.com/VWr1b0g.png) | ![Overview Mobile](https://i.imgur.com/iiuWnX3.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_overview.php

#### UI08: Task

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Task Desktop](https://i.imgur.com/hDxJPEh.png) | ![Task Mobile](https://i.imgur.com/FRjcaeE.png)
|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_overview.php

#### UI09: Project status

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Status Desktop](https://i.imgur.com/b3ZSwuO.png) | ![Status Mobile](https://i.imgur.com/suxEWpE.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_status.php

#### UI10: Project assignments

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Assignments Desktop](https://i.imgur.com/vYlpWAj.png) | ![Assignments Mobile](https://i.imgur.com/CAKHWKq.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_assignments.php

#### UI11: Project statistics

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Statistics Desktop](https://i.imgur.com/TOuavHm.png) | ![Statistics Mobile](https://i.imgur.com/gkB9eRS.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_statistics.php

#### UI12: Project preferences

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Preferences Desktop](https://i.imgur.com/AcW7jUG.png) | ![Preferences Mobile](https://i.imgur.com/v8RQEZ4.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/project_settings.php

#### UI13: Create Project

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Create Project Desktop](https://i.imgur.com/nvcVTmd.png) | ![Create Project Mobile](https://i.imgur.com/MJsyHaP.png)|
|![Create Project Desktop](https://i.imgur.com/xhbUeuj.png)|![Create Project Mobile](https://i.imgur.com/PEt81na.png)|
|![Create Project Desktop](https://i.imgur.com/b96rqug.png)|![Create Project Mobile](https://i.imgur.com/Wn8xGwf.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/dashboard.php

#### UI14: Profile

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Profile Desktop](https://i.imgur.com/g5voCMx.png) | ![Profile Mobile](https://i.imgur.com/UZMv61P.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/profile.php

#### UI15: Settings

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Settings Desktop](https://i.imgur.com/nGHo2g2.png) | ![Settings Mobile](https://i.imgur.com/eRuP3EI.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/settings.php

#### UI16: Not found

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![404 Desktop](https://i.imgur.com/uc1yKUY.png) | ![404 Mobile](https://i.imgur.com/PQTiDe2.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/404.php

#### UI17: Admin Manage Users

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Manage users Desktop](https://i.imgur.com/AeXlWqY.png) | ![Manage users Mobile](https://i.imgur.com/cNqtXN4.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/admin_dashboard.php

#### UI18: Admin Statistics

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![Admin Statistics Desktop](https://i.imgur.com/TuURbTf.png) | ![Admin Statistics Mobile](https://i.imgur.com/zoaz2qr.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/admin_dashboard.php

#### UI19: Admin User Support

|Desktop             |  Mobile|
|:-------------------------:|:-------------------------:|
|![User Support Desktop](https://i.imgur.com/hjDGgex.png) | ![User Support Mobile](https://i.imgur.com/UoWZCdB.png)|

http://lbaw2134-piu.lbaw-prod.fe.up.pt/admin_dashboard.php

---

## Revision history

Changes made to the first submission:

* Added US for Checklist
* Added US for Recovering Password
* Modified Timeline -> Status Board
* Fixed US identifiers
* Changed Social Media and Statistics using API priority (impossible with new GDPR rules)

***
GROUP2134, 15/02/2021

* Gonçalo Alves, up201806451@fe.up.pt (Editor)
* António Bezerra, up201806854@fe.up.pt
* Inês Silva, up201806385@fe.up.pt
* Pedro Seixas, up201806227@fe.up.pt