<div class="offcanvas offcanvas-start" tabindex="-1" id="createTask" aria-labelledby="createTaskLabel">
  <div class="offcanvas-header">
    <h5 id="createTaskLabel">Create Task</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="create-task">
      <h3>Create Task</h3>
      <form class="d-flex flex-column create-form validate-form" id="createTaskForm" data-href="/api/project/{{ $project->id }}/task" data-on-submit="addTaskElement" data-validate-function="validateCreateTaskForm" novalidate>
        @csrf

        <label for="inputTaskName" class="form-label">Name <span class="text-muted">*</span></label>
        <input id="inputTaskName" type="text" class="form-control" name="name" aria-label="Task name" required aria-describedby="inputTaskNameFeedback">
        <div id="inputTaskNameFeedback" class="invalid-feedback"></div>

        <label for="inputTaskDescription" class="form-label">Description</label>
        <input id="inputTaskDescription" type="text" class="form-control" name="description" aria-label="Task description">

        <label for="inputTaskDueDate" class="form-label">Due Date</label>
        <input id="inputTaskDueDate" type="date" class="form-control" name="due_date" aria-label="Task due date" aria-describedby="inputTaskDueDateFeedback">
        <div id="inputTaskDueDateFeedback" class="invalid-feedback"></div>

        <label for="inputTaskParent" class="form-label">Subtask of</label>
        <select class="form-select" name="parent" aria-label="Task parent select">
          <option selected value="">None</option>
          @foreach ($project->tasks as $task)
            <option value="{{$task->id}}">{{$task->name}}</option>
          @endforeach
        </select>

        <button type="submit" class="btn btn-outline-secondary flex-grow-1 mt-3">Add</button>
      </form>
    </section>
  </div>
</div>

<div class="offcanvas offcanvas-start" tabindex="-1" id="createTag" aria-labelledby="createTagLabel">
  <div class="offcanvas-header">
    <h5 id="createTagLabel">Tags</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="create-tag">
      <h3>Create Tag</h3>
      <form class="d-flex flex-column create-form validate-form" id="createTagForm" data-href="/api/project/{{ $project->id }}/tag" data-on-submit="addTagElement" data-validate-function="validateCreateTagForm" novalidate>
        @csrf

        <label for="inputTagName" class="form-label">Name <span class="text-muted">*</span></label>
        <input id="inputTagName" type="text" class="form-control" name="name" aria-label="Tag name" required aria-describedby="inputNameFeedback">
        <div id="inputNameFeedback" class="invalid-feedback"></div>

        <label for="inputTagColor" class="form-label">Color <span class="text-muted">*</span></label>
        <input id="inputTagColor" type="color" class="form-control" style="height: 2em" name="color" title="Tag color" required>
        <button type="submit" class="btn btn-outline-secondary flex-grow-1 mt-3">Add</button>
      </form>
    </section>
    <hr class="my-4">
    <section id="project-tags">
      <h3>Delete Tag</h3>
      <h6 class="text-muted">Click on the tags you wish to remove</h6>
      @foreach($project->tags as $tag)
        @include('partials.deleteTag', ['tag' => $tag])
      @endforeach
    </section>
  </div>
</div>

<div class="offcanvas offcanvas-end" tabindex="-1" id="addMembers" aria-labelledby="addMembersLabel" data-project="{{$project->id}}">
  <div class="offcanvas-header">
    <h5 id="addMembersLabel">Members</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="add-member">
      <h3>Add member</h3>
        <div class="input-group mb-3">
          <input id="searchMembers" name="query" type="text" class="form-control"
                 placeholder="Username or Email"
                 aria-label="Find Members" aria-describedby="button-search">

          <button class="btn btn-outline-secondary" type="button" id="button-search-members" data-href="/profile?project={{$project->id}}"><i
              class="bi bi-search"></i></button>
        </div>
        <div class="d-flex justify-content-center my-3 d-none" id="membersSpinner">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
        <div id="members" class="">
        </div>
        <div class="d-block">
          <h6>Added Members</h6>
          <div id="added-members"></div>
        </div>
    </section>
  </div>
</div>

