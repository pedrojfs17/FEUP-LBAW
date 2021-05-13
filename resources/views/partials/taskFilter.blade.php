@push('scripts')
  <script src="{{ asset('js/tooltip.js') }}" defer></script>
  <script src="{{ asset('js/filter.js') }}" defer></script>
@endpush

<div class="modal fade" id="taskFilterModal" tabindex="-1" aria-labelledby="tasksFilterModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasksFilterModalLabel">
          <ol class="my-0 breadcrumb text-muted">
            <li class="breadcrumb-item">
              <a style="cursor: pointer; font-weight: bolder" data-bs-dismiss="modal">Filter Tasks</a>
            </li>
          </ol>
        </nav>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div>
          <form data-id="taskFilter" id="taskFilter" data-href="/api/project/{{$project->id}}/task/">
            @csrf
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
            <label for="dueDateInput">Due Date</label>
            <input class="form-control @error('due_date') is-invalid @enderror" id="dueDateInput" type="date"
                                                     name="due_date" value="{{ old('due_date') }}">
            <button type="submit" class="d-none"></button>
          </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-success" data-bs-dismiss="modal" id="filterSubmit">Filter</button>
      </div>
    </div>
  </div>
</div>

