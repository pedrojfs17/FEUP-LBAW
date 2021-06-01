@push('scripts')
  <script src="{{ asset('js/taskFilter.js') }}" defer></script>
@endpush

<div class="modal fade" id="taskFilterModal" tabindex="-1" aria-labelledby="tasksFilterModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Task Filters</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
          <form data-id="taskFilter" id="taskFilter" data-href="/api/project/{{$project->id}}/task">
            <label for="tag-selection">Tags</label>
            <select class="form-control tag-selection" multiple="multiple" name="tag" id="tag-selection">
              @foreach ($project->tags as $tag)
                <option value="{{$tag->id}}">{{$tag->name}}</option>
              @endforeach
            </select>
            <label for="assignees-selection">Assignees</label>
            <select class="form-control assignee-selection" multiple="multiple" name="assignees" id="assignees-selection">
              @foreach ($project->teamMembers as $teamMember)
                <option value="{{$teamMember->id}}">{{$teamMember->account->username}}</option>
              @endforeach
            </select>

            <hr>

            <h6 class="text-muted">Due Date</h6>

            <label for="filterTasksBeforeDate">Before</label>
            <input class="form-control" id="filterTasksBeforeDate" type="date" name="before_date">

            <label for="filterTasksAfterDate">After</label>
            <input class="form-control" id="filterTasksAfterDate" type="date" name="after_date">

            <button type="submit" class="d-none"></button>
          </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-success" data-bs-dismiss="modal" id="filterSubmit">Filter</button>
      </div>
    </div>
  </div>
</div>

