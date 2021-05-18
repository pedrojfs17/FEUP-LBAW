<div class="offcanvas offcanvas-end" tabindex="-1" id="createTask" aria-labelledby="createTaskLabel">
  <div class="offcanvas-header">
    <h5 id="createTaskLabel">Create Task</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="create-task">
      <h3>Create Task</h3>
      <form class="d-flex flex-column create-form" data-href="/api/project/{{ $project->id }}/task" data-on-submit="addTaskElement">
        @csrf
        <label>Name
          <input type="text" class="form-control" name="name" aria-label="Task name">
        </label>
        <label class="flex-grow-1 my-2">Description
          <input type="text" class="form-control" name="description" title="Task description">
        </label>
        <label class="flex-grow-1 my-2">Due date
          <input type="date" class="form-control" name="due_date" title="Due date">
        </label>
        <label class="flex-grow-1 my-2">Subtask of
          <select class="form-select" aria-label="Task parent select">
            <option selected>None</option>
            @foreach ($project->tasks as $task)
            <option value="{{$task->id}}">{{$task->name}}</option>
            @endforeach
          </select>
        </label>
        <button type="submit" class="btn btn-outline-secondary flex-grow-1 mt-3">Add</button>
      </form>
    </section>
  </div>
</div>

<div class="offcanvas offcanvas-end" tabindex="-1" id="createTag" aria-labelledby="createTagLabel">
  <div class="offcanvas-header">
    <h5 id="createTagLabel">Tags</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="create-tag">
      <h3>Create Tag</h3>
      <form class="d-flex flex-column create-form" data-href="/api/project/{{ $project->id }}/tag" data-on-submit="addTagElement">
        @csrf
        <label>Name
          <input type="text" class="form-control" name="name" aria-label="Tag name">
        </label>
        <label class="flex-grow-1 my-2">Color
          <input type="color" class="form-control" style="height: 2em" name="color" title="Tag color">
        </label>
        <button type="submit" class="btn btn-outline-secondary flex-grow-1 mt-3">Add</button>
      </form>
    </section>
    <hr class="my-4">
    <section id="project-tags">
      <h3>Delete Tag</h3>
      <h6 class="text-muted">Click on the tags you wish to remove</h6>
      @foreach($project->tags as $tag)
        <p class="delete-tag delete-button d-inline-block m-0 my-1 py-1 px-3 px-sm-2 rounded text-bg-check" type="button" data-href="/api/project/{{ $project->id }}/tag/{{ $tag->id }}" style="background-color: {{ $tag->color }}">
          <small class="d-none d-sm-inline-block">{{ $tag->name }}</small>
        </p>
      @endforeach
    </section>
  </div>
</div>

<div class="offcanvas offcanvas-end" tabindex="-1" id="addMembers" aria-labelledby="addMembersLabel">
  <div class="offcanvas-header">
    <h5 id="addMembersLabel">Members</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="add-member">
      <h3>Add member</h3>
        <div class="input-group mb-3">
          <input id="searchMembersInvite" name="query" type="text" class="form-control"
                 placeholder="Username or Email"
                 aria-label="Find Members" aria-describedby="button-search">

          <button class="btn btn-outline-secondary" type="button" id="button-search-members-invite"><i
              class="bi bi-search"></i></button>
        </div>
        <div class="d-flex justify-content-center my-3 d-none" id="membersInviteSpinner">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
        <div id="members-invite" class="">
        </div>
        <div class="d-block">
          <h6>Added Members</h6>
          <div id="added-members-invite"></div>
        </div>
    </section>
  </div>
</div>

