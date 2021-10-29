# PA: Product and Presentation

Oversee is the new essential web platform for social media management, allowing users to better plan their marketing scheme and see their social performance.

## A9: Product

This project intends to specify, develop and promote a system available through the web for the management of social media marketing campaigns.

With the increasing influence of social media, we think it would be useful for individual content creators or marketing teams to plan their social media. Our clients will be able to manage their projects, from marketing campaigns to individual posts, in an organized manner.

We believe a simple design is very effective when using a planning platform. Therefore, we will invest in an intuitive design for our platform. To achieve this, the user will be presented with a simple dashboard that contains all of his projects, either created by or assigned to him. Upon selecting a project, the user can create the necessary tasks and, additionally, subtasks. If the user needs to plan sequential tasks, he may do so. The user will also have at his disposal tags and collaborator assignments, so that project administrators can easily know each type of tasks within the project and who is working on them. These features will also allow any user to filter through tasks, based on tag or assigned personnel. Our clients can make use of a search bar that not only allows them to search for a project or tasks they are assigned to, but also other configurations within the web app, such as their profile page. We will also make sure the user experience isn't affected by the device that our client uses, by adopting a responsive design.

Although all users will be presented with an introductory page, explaining the aim of our platform, only those with an account will be able to edit their projects or check their social performance. Users will be categorized according to their permissions. Team members are users that are a part of a project. Readers are all team members that have reading privileges. Editors are team members that are able to manage tasks. Owners are team members that are allowed to invite users to their project and manage the team members' access and roles in each project.

### 1. Installation

Source code can be found [here](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/tree/master)
To run the Docker Container:

```docker
composer install

docker build -t lbaw2134/lbaw2134 .

docker run -it -p 8000:80 -e DB_DATABASE="lbaw2134" -e DB_USERNAME="lbaw2134" -e DB_PASSWORD="MG660546" lbaw2134/lbaw2134

# You can now open https://localhost:8000 to see the web app
```

### 2. Usage

The link to the final product is the following: http://lbaw2134.lbaw-prod.fe.up.pt  

#### 2.1. Administration Credentials

URL: [Administration](http://lbaw2134.lbaw-prod.fe.up.pt/admin/users)

| Username | Password |
| -------- | -------- |
| admin    | neniplans |

#### 2.2. User Credentials

| Type          | Username   | Password  |
| ------------- | ---------- | --------- |
| basic account | nenieats   | neniplans |
| news editor   | pedgojodge | neniplans |

### 3. Application Help

For each page, there is a help button to explain to the user what he can find and do in that page.
For example, see the button in the bottom left corner of the [dashboard](http://lbaw2134.lbaw-prod.fe.up.pt/dashboard) (log-in with "pedgojodge" beforehand).

### 4. Input Validation

User input is validated in both client-side and server-side.
For client-side, when creating a project, the "name" and "description" are both required inputs. For server-side, also when creating a project, besides checking if both the inputs above-mentioned are not null, it also checks their type, using the "validate" method of Laravel.

### 5. Check Accessibility and Usability

[Accessibility](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/accessibility_checklist.pdf) & [Usability](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/usability_checklist.pdf) checklists can be seen in by clicking the links.

In accessibility:
- Some forms do not have a submit button, since it would ruin the design and user experience. For example, when adding a checklist item, the user simply clicks enter, after writing the new item.


### 6. HTML & CSS Validation

[HTML](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/html_validation.pdf) & [CSS](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/css_validation.pdf) validation can be seen by clicking the links.

### 7. Revisions to the Project

Unfortunately, we couldn't use the social media APIs we wanted to. Due to the GDPR, the Instagram and Facebook APIs were not able to provide the data necessary for the statistical analysis that we wanted, as we would have needed to verify our web app identity.

### 8. Implementation Details

#### 8.1. Libraries Used

[Bootstrap](https://getbootstrap.com/) and [Laravel](https://laravel.com/) were the common libraries used for the project.
We also used [Select2](https://select2.org/) for a better user experience with a select box. E.g, when a user is selecting tags of a task, [inside a task](http://lbaw2134.lbaw-prod.fe.up.pt/project/48/overview) (log-in with "pedgojodge" beforehand).

#### 8.2 User Stories

|US Identifier|Name|Priority|Team members|State|
|:---:|:---:|:---:|:---:|:---:|
|US101|Home Page|High|**Gonçalo Alves**|100%|
|US102|Contacts Page|High|**Gonçalo Alves**|100%|
|US201|Sign-in|High|**Pedro Seixas**|100%|
|US202|Sign-up|High|**António Bezerra**|100%|
|US301|Log out|High|**Pedro Seixas**|100%|
|US311|See Profiles|High|**Inês Silva**|100%|
|US321|Edit Account|High|**António Bezerra**|100%|
|US322|Delete account|High|**Pedro Seixas**|100%|
|US331|Recover Password|High|**Pedro Jorge**|100%|
|US401|See projects|High|**Gonçalo Alves**|100%|
|US402|Create project|High|**Inês Silva**|100%|
|US403|Join team|High|**Gonçalo Alves**|100%|
|US411|Edit Profile|High|**António Bezerra**|100%|
|US501|See project info|High|**Inês Silva**|100%|
|US502|Leave project|High|**Pedro Seixas**|100%|
|US503|See tasks|High|**Inês Silva**|100%|
|US504|Filter tasks|High|**Gonçalo Alves**|100%|
|US601|Add team members|High|**Inês Silva**|100%|
|US602|Change team members' permissions|High|**Pedro Seixas**|100%|
|US603|Remove team members|High|**Pedro Seixas**|100%|
|US604|End Project|High|**Gonçalo Alves**|100%|
|US605|Edit project info|High|**António Bezerra**|100%|
|US701|Create Task|High|**Inês Silva**|100%|
|US702|Edit Task|High|**Gonçalo Alves**|100%|
|US703|Remove Task|High|**Gonçalo Alves**|100%|
|US704|Add Subtasks|High|**Gonçalo Alves**|100%|
|US801|Manage Users|High|**António Bezerra**|100%|
|US412|Search|Medium|**Gonçalo Alves**|100%|
|US431|Change Settings|Medium|**Pedro Seixas**|100%|
|US511|Status Board|Medium|**Pedro Seixas**|100%|
|US512|Comment|Medium|**Inês Silva**|100%|
|US606|Reopen Project|Medium|**António Bezerra**|100%|
|US705|Dependency between tasks|Medium|**Gonçalo Alves**|100%|
|US706|Checklist|Medium|**Gonçalo Alves**|100%|
|US802|User statistics|Medium|**Inês Silva**|100%|
|US803|Add Administrator|Medium|**António Bezerra**|100%|
|US203|Sign-up using external API|Low|**Pedro Seixas**|100%|
|US204|Sign-in using external API|Low|**Pedro Seixas**|100%|

---

<div style="page-break-after: always; break-after: page;"></div>

## A10: Presentation

### 1. Product presentation

This project intends to specify, develop and promote a system available through the web for the management of social media marketing campaigns.

Upon selecting a project, the user can create the necessary tasks and, additionally, subtasks. If the user needs to plan sequential tasks, he may do so. The user will also have at his disposal tags and collaborator assignments, so that project administrators can easily know each type of tasks within the project and who is working on them. These features will also allow any user to filter through tasks, based on tag or assigned personnel.

The link to the final product is the following: http://lbaw2134.lbaw-prod.fe.up.pt  

### 2. Video presentation

![Screenshot](https://i.imgur.com/dXrObLl.png)
[Video Link](https://drive.google.com/file/d/1BMOtI02fLOmuFWdpSSbvRocWeC4ODenZ/view?usp=sharing)

---

## Revision history

No changes made.

---

GROUP2134, 11/06/2021

* Gonçalo Alves, up201806451@fe.up.pt
* António Bezerra, up201806854@fe.up.pt
* Inês Silva, up201806385@fe.up.pt
* Pedro Seixas, up201806227@fe.up.pt (Editor)