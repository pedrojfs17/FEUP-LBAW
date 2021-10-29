# EAP: Architecture Specification and Prototype

Oversee is the new essential web platform for social media management, allowing users to better plan their marketing scheme and see their social performance.

## A7: High-level architecture. Privileges. Web resources specification

The architecture of the web application to develop is documented indicating the catalog of resources and the properties of each resource, including references to the graphical interfaces, and the format of JSON responses. This page presents the documentation for MediaLibrary, including the following operations over data: create, read, update, and delete.

This specification adheres to the OpenAPI standard using YAML.

### 1. Overview

An overview of the web application to implement is presented in this section, where the modules are identified and briefly described. The web resources associated with each module are detailed in the individual documentation of each module. 

|                                                |                                                              |
| ---------------------------------------------- | ------------------------------------------------------------ |
| **M01: Authentication and Individual Profile** | Web resources associated with user authentication and individual profile management, includes the following system features: login/logout, registration, credential recovery, view and edit personal profile information. |
| **M02: Projects**                              | Web resources associated with projects and tasks, includes the following system features: user's projects list and search, create, view, edit and delete a project and its tasks. |
| **M03: Social Media**                          | Web resources associated with social media accounts, includes the following system features: account statistics such as following, like ratio and posts info. |
| **M04: User Administration and Static pages**  | Web resources associated with user management such as view, search and delete users, view and change user information, view user statistics and manage reports and user support tickets. Web resources with static content are associated with this module: landing page, dashboard, search, contact. |

### 2. Permissions

This section defines the permissions used in the modules to establish the conditions of access to resources. 

|         |               |                                        |
| ------- | ------------- | -------------------------------------- |
| **PUB** | Public        | Users without privileges               |
| **USR** | User          | Authenticated Users                    |
| **ACO** | Account Owner | Account Owner                          |
| **RDR** | Reader        | Project Member with reading privileges |
| **EDT** | Editor        | Project Member with editing privileges |
| **OWN** | Owner         | Project Member with owner privileges   |
| **ADM** | Administrator | Administrator                          |

### 3. OpenAPI Specification

OpenAPI specification in YAML format to describe the web application's web resources.

[Open API Specification File](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/blob/master/Artifacts/EAP/a7_openapi.yaml)

[Swagger Documentation](https://app.swaggerhub.com/apis-docs/lbaw2134/Oversee/1.0)

```yaml
openapi: 3.0.0

info:
  version: '1.0'
  title: LBAW Oversee Web API
  description: Web Resources Specification (A7) for Oversee
  
servers:
- url: "http://lbaw2134-prod.fe.up.pt"
  description: "Production server"
  
externalDocs:
  description: "Find more info here."
  url: "https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/home"

tags:
  - name: 'M01: Authentication and Individual Profile'
  - name: 'M02: Projects'
  - name: 'M03: Social Media'
  - name: 'M04: User Administration and Static pages'

paths:

  /sign_in:
    get:
      operationId: R101
      summary: 'R101: Sign In Form'
      description: 'Provide sign in form. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '200':
          description: 'Ok. Show [UI04](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui04-sign-in)'
        '302':
          description: 'Redirect if user is logged in.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Authenticated. Redirect to user dashboard.'
                  value: '/dashboard'
          
    post:
      operationId: R102
      summary: 'R102: Sign In Action'
      description: 'Processes the sign in form submission. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'
 
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
              required:
                - username
                - password
 
      responses:
        '302':
          description: 'Redirect after processing the sign in credentials.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful authentication. Redirect to user dashboard.'
                  value: '/dashboard'
                302Error:
                  description: 'Failed authentication. Redirect to sign in form.'
                  value: '/sign_in'
 
  /logout:
    post:
      operationId: R103
      summary: 'R103: Logout Action'
      description: 'Logout the current authenticated used. Access: ACO, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '302':
          description: 'Redirect after processing logout.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful logout. Redirect to home page.'
                  value: '/'

  /sign_up:
    get:
      operationId: R104
      summary: 'R104: Sign Up Form'
      description: 'Provide new user sign up form. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '200':
          description: 'Ok. Show [UI03](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui03-sign-up)'
        '302':
          description: 'Redirect if user is logged in.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Authenticated. Redirect to user dashboard.'
                  value: '/dashboard'

    post:
      operationId: R105
      summary: 'R105: Sign Up Action'
      description: 'Processes the new user sign up form submission. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                email:
                  type: string
                password:
                  type: string
              required:
                - username
                - email
                - password

      responses:
        '302':
          description: 'Redirect after processing the new user information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful authentication. Redirect to user profile.'
                  value: '/profile'
                302Failure:
                  description: 'Failed authentication. Redirect to sign in form.'
                  value: '/sign_in'

  /profile/{username}:
    get:
      operationId: R106
      summary: 'R106: View User Profile'
      description: 'Show the individual user profile. Access: USR'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: username
          schema:
            type: string
          required: true

      responses:
        '200':
          description: 'Ok. Show [UI14](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui14-profile)'
        '404':
          description: 'Not Found. Show [UI16](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui16-not-found)'
          
    patch:
      operationId: R107
      summary: 'R107: Edit Profile'
      description: 'Edit account information. Access: ACO'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: username
          schema:
            type: string
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                email:
                  type: string
                password:
                  type: string
                company:
                  type: string
                fullname:
                  type: string
                avatar:
                  type: string
                  format: byte
                gender:
                  type: string
                country:
                  type: string

      responses:
        '200':
          description: 'Ok'
        "401":
          description: "Unauthorized"
          
    delete:
      operationId: R108
      summary: 'R108: Delete Account'
      description: 'Delete account. Access: ACO, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'
        
      parameters:
        - in: path
          name: username
          schema:
            type: string
          required: true

      responses:
        '200':
          description: 'Ok'

  /settings:
    get:
      operationId: R109
      summary: 'R109: View Account Settings'
      description: 'Show account settings page. Access: ACO'
      tags:
        - 'M01: Authentication and Individual Profile'

      responses:
        '200':
          description: 'Ok'
        "401":
          description: "Unauthorized"
    
    patch:
      operationId: R110
      summary: 'R110: Edit Account Settings'
      description: 'Edit account settings. Access: ACO'
      tags:
        - 'M01: Authentication and Individual Profile'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                allowNoti:
                  type: boolean
                inviteNoti:
                  type: boolean
                memberNoti:
                  type: boolean
                assignNoti:
                  type: boolean
                waitingNoti:
                  type: boolean
                commentNoti:
                  type: boolean
                reportNoti:
                  type: boolean
                hideCompleted:
                  type: boolean
                simplifiedTasks:
                  type: boolean
                color:
                  type: string

      responses:
        '200':
          description: 'Ok. Show [UI14](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui14-profile)'
        "401":
          description: "Unauthorized"
          
  /avatars/{img}:
    get:
      operationId: R111
      summary: 'R111: Get Avatar'
      description: 'Get avatar image from local storage. Access: USR'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: img
          schema:
            type: string
          required: true

      responses:
        '200':
          description: 'Ok'
        "404":
          description: "Not Found"

  /api/project:
    get:
      operationId: R201
      summary: "R201: Search Projects API"
      description: "Searches for projects and returns the results as JSON. Access: RDR"
      tags:
        - 'M02: Projects'
        
      parameters: 
        - in: query 
          name: query 
          description: String to use for full-text search 
          schema: 
            type: string 
          required: false 
        - in: query 
          name: closed 
          description: Boolean with the closed flag value 
          schema: 
            type: boolean 
          required: false 

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Project'
        '400':
          description: Bad Request
          
    post:
      operationId: R202
      summary: 'R202: Create Project'
      description: 'Processes the project creation form submission. Access: USR'
      tags:
        - 'M02: Projects'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                description:
                  type: string
                due_date:
                  type: integer
              required:
                - name
                - description

      responses:
        '302':
          description: 'Redirect after processing the new project information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful creation. Redirect to project overview.'
                  value: '/project/{id}/overview'
                302Failure:
                  description: 'Failed creation. Redirect to user dashboard.'
                  value: '/dashboard'

  /api/project/{id}:
    get:
      operationId: R203
      summary: 'R203: Get Project Information'
      description: "Get project information as JSON. Access: RDR"
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                $ref: '#/components/schemas/Project'
        "403":
          description: Forbidden
        "404":
          description: Not Found
          
    delete:
      operationId: R204
      summary: 'R204: Leave Project'
      description: 'Leave a project. Access: RDR'
      tags:
        - 'M02: Projects'    
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        
      responses:
        '302':
          description: 'Redirect after processing the leave request.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful. Redirect to user dashboard.'
                  value: '/dashboard'
                302Failure:
                  description: 'Failed. Redirect to user dashboard.'
                  value: '/dashboard'
        "400":
          description: "Bad Request. Must have at least one owner in the project"
        "403":
          description: Forbidden
        "404":
          description: Not Found

  /project/{id}/overview:
    get:
      operationId: R205
      summary: 'R205: View Project Overview'
      description: "Show the project overview page. Access: RDR"
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show [UI09](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui09-project-status)'
        '403':
          description: Forbidden
        '404':
          description: 'Not Found. Show [UI16](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui16-not-found)'

  /project/{id}/status_board:
    get:
      operationId: R206
      summary: 'R206: View Project Status Board'
      description: "Show the project dashboard's status board page. Access: RDR"
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show [UI09](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui09-project-status)'
        '403':
          description: Forbidden
        '404':
          description: 'Not Found. Show [UI16](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui16-not-found)'

  /project/{id}/assignments:
    get:
      operationId: R207
      summary: 'R207: View Project Assignments'
      description: "Show the project dashboard's assignments page. Access: RDR"
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show [UI10](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui10-project-assignments)'
        '403':
          description: Forbidden
        '404':
          description: 'Not Found. Show [UI16](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui16-not-found)'

  /project/{id}/preferences:
    get:
      operationId: R208
      summary: 'R208: View Project Preferences'
      description: "Show the project preferences page. Access: RDR"
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show [UI12](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui12-project-preferences)'
        '403':
          description: Forbidden
        '404':
          description: 'Not Found. Show [UI16](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui16-not-found)'
  
    patch:
      operationId: R209
      summary: 'R209: Update Project'
      description: 'Processes the project settings form submission. Access: OWN'
      tags:
        - 'M02: Projects'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                description:
                  type: string
                due_date:
                  type: integer
      
      responses:
        "200":
          description: Success
        "403":
          description: Forbidden
        "404":
          description: Not Found
  
    delete:
      operationId: R210
      summary: 'R210: Delete Project'
      description: 'Delete project project. Access: OWN'
      tags:
        - 'M02: Projects'    
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        
      responses:
        '302':
          description: 'Redirect after processing the delete project request.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful. Redirect to user dashboard.'
                  value: '/dashboard'
        "403":
          description: Forbidden
        "404":
          description: Not Found

  /api/project/{id}/task:
    get:
      operationId: R211
      summary: "R211: Search Tasks API"
      description: "Searches for tasks and returns the results as JSON. Access: RDR"
      tags:
        - 'M02: Projects'
        
      parameters: 
        - in: path 
          name: id 
          schema: 
            type: integer 
          required: true 
        - in: query 
          name: query 
          description: String to use for full-text search 
          schema: 
            type: string 
          required: false 
        - in: query 
          name: tag 
          description: Tag of the tasks
          schema: 
            type: string 
          required: false 
        - in: query 
          name: status
          description: Status of the tasks
          schema: 
            type: string
            enum: ['Waiting', 'Not Started', 'In Progress', 'Completed']
          required: false

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Task'
        '400':
          description: Bad Request
        "403":
          description: Forbidden
        "404":
          description: Not Found
          
    post:
      operationId: R212
      summary: 'R212: Create Task'
      description: 'Processes the task creation form submission. Access: EDT'
      tags:
        - 'M02: Projects'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                description:
                  type: string
                due_date:
                  type: integer
                task_status:
                  type: string
                parent:
                  type: integer
              required:
                - name

      responses:
        '302':
          description: 'Redirect after processing the new task information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful creation. Redirect to task card.'
                  value: '/project/{id}/overview'
                302Failure:
                  description: 'Failed creation. Redirect to project dashboard.'
                  value: '/project/{id}/overview'
        '400':
          description: Bad Request
        "403":
          description: Forbidden
        "404":
          description: Not Found
  
  /api/project/{id}/task/{task}:
    get:
      operationId: R213
      summary: 'R213: Get Task'
      description: 'Get the task information in JSON. Access: RDR'
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                $ref: '#/components/schemas/Task'
        "403":
          description: Forbidden
        "404":
          description: Not Found
          
    patch:
      operationId: R214
      summary: 'R214: Update Task'
      description: 'Processes the task settings form submission. Access: EDT'
      tags:
        - 'M02: Projects'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
        
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                description:
                  type: string
                due_date:
                  type: integer
                task_status:
                  type: string
      
      responses:
        "200":
          description: Success
        "403":
          description: Forbidden
        "404":
          description: Not Found
          
    delete:
      operationId: R215
      summary: 'R215: Delete Task'
      description: 'Removes task from project. Access: EDT'
      tags:
        - 'M02: Projects'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
        
      responses:
        '302':
          description: 'Redirect after processing the new project information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful delete. Redirect to project overview.'
                  value: '/project/{id}/overview'
                302Failure:
                  description: 'Failed delete. Redirect to project overview.'
                  value: '/project/{id}/overview'
        "403":
          description: Forbidden
        "404":
          description: Not Found

  /api/project/{id}/tag:
    get:
      operationId: R216
      summary: 'R216: Get Tags'
      description: 'Get all project tags in JSON. Access: RDR'
      tags:
        - 'M02: Projects'

      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Tag'
        '400':
          description: Bad Request
        "403":
          description: Forbidden
        "404":
          description: Not Found
    
    post:
      operationId: R217
      summary: 'R217: Create Tag'
      description: 'Processes the tag creation form submission. Access: EDT'
      tags:
        - 'M02: Projects'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                color:
                  type: string
              required:
                - name
                - color

      responses:
        '201':
          description: Success

  /api/project/{id}/tag/{tag}:
    delete:
      operationId: R218
      summary: 'R218: Delete Tag'
      description: 'Removes tag from project. Access: EDT'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: tag
          schema:
            type: integer
          required: true
      
      responses:
        '200':
          description: Success
        "403":
          description: Forbidden
        "404":
          description: Not Found

  /api/project/{id}/invite:
    post:
      operationId: R219
      summary: 'R219: Invite member'
      description: 'Invite a member to a project. Access: OWN'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
          
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                client:
                  type: integer
              required:
                - client
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
  
  /api/project/{id}/invite/{invite}:
    patch:
      operationId: R220
      summary: 'R220: Respond to project invite'
      description: 'Accept or refuse an invite to a project. Access: USR'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: invite
          schema:
            type: integer
          required: true

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                decision:
                  type: boolean
              required:
                - decision
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
          
  /api/project/{id}/task/{task}/tag:
    post:
      operationId: R221
      summary: 'R221: Add a tag'
      description: 'Add a tag to a task. Access: EDT'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
      
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                tag:
                  type: integer
              required:
                - tag
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
          
  /api/project/{id}/task/{task}/subtask:
    post:
      operationId: R222
      summary: 'R222: Add a subtask'
      description: 'Add a subtask to a task. Access: EDT'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                subtask:
                  type: integer
              required:
                - subtask
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
          
  /api/project/{id}/task/{task}/waiting_on:
    post:
      operationId: R223
      summary: 'R223: Add a waiting on'
      description: 'Add a temporal relation between tasks. Access: EDT'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                task:
                  type: integer
              required:
                - task
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
          
  /api/project/{id}/task/{task}/assignment:
    post:
      operationId: R224
      summary: 'R224: Add an assignment'
      description: 'Add an assignment to a task. Access: EDT'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                member:
                  type: integer
              required:
                - member
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"
          
  /api/project/{id}/task/{task}/comment:
    post:
      operationId: R225
      summary: 'R225: Add a comment'
      description: 'Add a comment to a task. Access: RDR'
      tags:
        - 'M02: Projects' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        - in: path
          name: task
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                comment:
                  type: string
                parent:
                  type: integer
              required:
                - comment
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Tag not found"

  /api/account:
    get:
      operationId: R301
      summary: "R301: Search Accounts API"
      description: "Searches for accounts and returns the results as JSON. Access: USR"
      tags:
        - 'M03: Social Media'
        
      parameters: 
        - in: query 
          name: query 
          description: String to use for full-text search 
          schema: 
            type: string 
          required: false 
        - in: query 
          name: socialMedia 
          description: String with the social media website
          schema: 
            type: string
            enum: ['Facebook', 'Instagram', 'Twitter']
          required: false 

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Account'
        '400':
          description: Bad Request
    
    post:
      operationId: R302
      summary: 'R302: Connect Social Media Account'
      description: 'Processes the connection of a new social media account. Access: USR'
      tags:
        - 'M03: Social Media'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                website:
                  type: string
                username:
                  type: string
                accsessToken:
                  type: string
              required:
                - website
                - username
                - accsessToken

      responses:
        '201':
          description: 'Successful creation'

  /api/account/{id}:   
    get:
      operationId: R303
      summary: 'R303: Get Account'
      description: "Get account information as JSON. Access: USR"
      tags:
        - 'M03: Social Media'
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                $ref: '#/components/schemas/Account'
        "403":
          description: Forbidden
        "404":
          description: Not Found
  
    delete:
      operationId: R304
      summary: 'R304: Disconnect Social Media Account'
      description: 'Removes social media account connection. Access: ACO'
      tags:
        - 'M03: Social Media' 
        
      parameters:
        - in: path
          name: id
          schema:
            type: integer
          required: true
        
      responses:
        "200":
          description: "OK"
        "403":
          description: "Forbidden access"
        "404":
          description: "Not found"

  /:   
    get:
      operationId: R401
      summary: 'R401: View Landing Page'
      description: "View landing page. Access: PUB"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI01](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui01-home)'

  /contacts:   
    get:
      operationId: R402
      summary: 'R402: View Contacts Page'
      description: "View contacts page. Access: PUB"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI02](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui02-contacts)'
          
    post:
      operationId: R403
      summary: 'R403: Send Support Ticket Action'
      description: 'Processes the user support form submission. Access: PUB'
      tags:
        - 'M04: User Administration and Static pages'
 
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                email:
                  type: string
                name:
                  type: string
                subject:
                  type: string
                body:
                  type: string
              required:
                - email
                - subject
                - body
                
      responses:
        '302':
          description: 'Redirect after processing the new user support ticket.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful creation. Redirect to home page.'
                  value: '/'

  /dashboard:
    get:
      operationId: R404
      summary: 'R404: View dashboard'
      description: "View search page. Access: USR"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI05](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui05-dashboard)' 

  /search:   
    get:
      operationId: R405
      summary: 'R405: View search page'
      description: "View search page. Access: USR"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI06](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui06-search)'  
          
  /api/search:
    get:
      operationId: R406
      summary: 'R406: Website Search'
      description: "Search in the website. Access: USR"
      tags:
        - 'M04: User Administration and Static pages'     
        
      parameters: 
        - in: query 
          name: query 
          description: String to use for full-text search 
          schema: 
            type: string 
          required: true

      responses:
        '200':
          description: Success
          content: 
            application/json:
              schema:
                type: object
                properties:
                  users:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  projects:
                    type: array
                    items:
                      $ref: '#/components/schemas/Project'
                  tasks:
                    type: array
                    items:
                      $ref: '#/components/schemas/Task'
        '400':
          description: Bad Request

  /admin/users:   
    get:
      operationId: R407
      summary: 'R407: View User Management Page'
      description: "View user management page. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI17](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui17-admin-manage-users)'   
        "403":
          description: "Forbidden access"

  /admin/statistics:   
    get:
      operationId: R408
      summary: 'R408: View Website Statistics Page'
      description: "View website statistics page. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI18](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui18-admin-statistics)'   
        "403":
          description: "Forbidden access"

  /admin/support:   
    get:
      operationId: R409
      summary: 'R409: View User Support Page'
      description: "View user support page. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'      
        
      responses:
        '200':
          description: 'OK. Show [UI19](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/wikis/ER#ui19-admin-user-support)'   
        "403":
          description: "Forbidden access"

components:
  schemas:
    User:
      type: object
      properties: 
        id:
          type: integer
        username:
          type: string
        avatar:
          type: string
          format: byte
  
    Project:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        description:
          type: string
        due_date:
          type: string
        completion:
          type: integer
        users:
          type: array
          items:
            $ref: '#/components/schemas/User'
          
    TaskSummary:
      type: object
      properties: 
        id:
          type: integer
        name:
          type: string
        status:
          type: string
          enum: ['Waiting', 'Not Started', 'In Progress', 'Completed']
          
    Tag:
      type: object
      properties: 
        name:
          type: string
        color:
          type: string
          
    CheckListItem:
      type: object
      properties: 
        name:
          type: string
        completed:
          type: boolean
          
    Comment:
      type: object
      properties: 
        id:
          type: integer
        author:
          $ref: '#/components/schemas/User'
        comment_date:
          type: string
        comment_text:
          type: string
        parent:
          type: integer
            
    Task:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
        description:
          type: string
        due_date:
          type: string
        status:
          type: string
          enum: ['Waiting', 'Not Started', 'In Progress', 'Completed']
        subtasks:
          type: array
          items:
            $ref: '#/components/schemas/TaskSummary'
        waiting_on:
          type: array
          items:
            $ref: '#/components/schemas/TaskSummary'
        assignments:
          type: array
          items:
            $ref: '#/components/schemas/User'
        tags:
          type: array
          items:
            $ref: '#/components/schemas/Tag'
        check_list_items:
          type: array
          items:
            $ref: '#/components/schemas/CheckListItem'
        comments:
          type: array
          items:
            $ref: '#/components/schemas/Comment'
            
    Account: 
      type: object
      properties:
        id:
          type: integer
        username:
          type: string
        social_media:
          type: string
          enum: ['Facebook', 'Instagram', 'Twitter']
        
```

---


## A8: Vertical prototype

The Vertical Prototype includes the implementation of two or more user stories (the simplest) and aims to validate the architecture presented, also serving to gain familiarity with the technologies used in the project.

The implementation is based on the [LBAW Framework](https://git.fe.up.pt/lbaw/template-laravel) and includes work on all layers of the architecture of the solution to implement: user interface, business logic and data access. The prototype implements pages for visualizing, inserting, editing and removing information, as well as functionality for access management and display of error and success messages.

### 1. Implemented Features

#### 1.1. Implemented User Stories

The following table describes the implemented user stories.

| User Story reference | Name              | Priority | Description                                                  |
| -------------------- | ----------------- | -------- | ------------------------------------------------------------ |
| US101                | Home Page         | High     | As a User, I want to access home page, so that I can see a brief website's presentation |
| US102                | Contacts Page     | High     | As a User, I want to access the contacts page, so that I can know how to contact the website |
| US201                | Sign-in           | High     | As a Visitor, I want to authenticate into the system, so that I can access privileged information |
| US202                | Sign-up           | High     | As a Visitor, I want to register myself into the system, so that I can authenticate myself into the system |
| US301                | Log out           | High     | As an Authenticated User, I want to log out of my session, so that I can share the same device with other users. |
| US401                | See projects      | High     | As a Client, I want to see the projects I'm participating in, so that I can work in them. |
| US402                | Create project    | High     | As a Client, I want to create a project, so that I can work in it. |
| US503                | See tasks         | High     | As a Team Member, I want to see tasks inside my projects, so that I can know what is being planned for the project |
| US604                | End Project       | High     | As an Owner, I want to mark a project as finished, so that I can notify all team members that the project is complete |
| US612                | Edit project info | High     | As an Owner, I want to edit a project's information, such as name, description and due date, so that I can keep them up-to-date |
| US801                | Manage Users      | High     | As an Administrator, I want to manage the app's users, so that inactive or unfaithful users can't access the website |

#### 1.2. Implemented Web Resources

The web resources that were implemented in the prototype are described in the next section.

**Module M01: Authentication and Individual Profile**

| Web Resource Reference | URL                                                      |
| ---------------------- | -------------------------------------------------------- |
| R101: Sign In Form     | [/login](http://lbaw2134.lbaw-prod.fe.up.pt/login)       |
| R102: Sign In Action   | POST /login                                              |
| R103: Logout Action    | POST /logout                                             |
| R104: Sign Up Form     | [/register](http://lbaw2134.lbaw-prod.fe.up.pt/register) |
| R105: Sign Up Action   | POST /register                                           |

**Module M02: Projects**

| Web Resource Reference         | URL                                                          |
| ------------------------------ | ------------------------------------------------------------ |
| R202: Search Projects API      | GET /api/project                                             |
| R203: Create Project           | POST /api/project                                            |
| R206: View Project Overview    | [/project/{id}/overview](http://lbaw2134.lbaw-prod.fe.up.pt/project/1/overview) |
| R209: View Project Preferences | [/project/{id}/preferences](http://lbaw2134.lbaw-prod.fe.up.pt/project/1/preferences) |
| R210: Update Project           | PATCH /project/{id}/preferences                              |
| R211: Delete Project           | DELETE /project/{id}/preferences                             |

**Module M04:User Administration and Static Pages**

| Web Resource Reference          | URL                                                          |
| ------------------------------- | ------------------------------------------------------------ |
| R401: View Landing Page         | [/](http://lbaw2134.lbaw-prod.fe.up.pt/)                     |
| R402: View Contacts Page        | [/contacts](http://lbaw2134.lbaw-prod.fe.up.pt/contacts)     |
| R404: View dashboard            | [/dashboard](http://lbaw2134.lbaw-prod.fe.up.pt/dashboard)   |
| R407: View User Management Page | [/admin/users](http://lbaw2134.lbaw-prod.fe.up.pt/admin/users) |

### 2. Prototype

The prototype is available at [lbaw2134.lbaw-prod.fe.up.pt/](http://lbaw2134.lbaw-prod.fe.up.pt/)

**Credentials:**

Admin user: admin | neniplans

Regular user: nenieats | neniplans

The code is available at [https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/tree/master](https://git.fe.up.pt/lbaw/lbaw2021/lbaw2134/-/tree/master)

---

## Revision history

Changes made to the first submission:

1. Added missing user story to ER submission - US612: Edit Project

---

GROUP2134, 03/05/2021

* Gonçalo Alves, up201806451@fe.up.pt (Editor)
* António Bezerra, up201806854@fe.up.pt
* Inês Silva, up201806385@fe.up.pt
* Pedro Seixas, up201806227@fe.up.pt