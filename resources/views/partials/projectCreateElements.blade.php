<div class="offcanvas offcanvas-end" tabindex="-1" id="createTask" aria-labelledby="createTaskLabel">
  <div class="offcanvas-header">
    <h5 id="createTaskLabel">Create Task</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    Create task
    {{-- TODO --}}
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
