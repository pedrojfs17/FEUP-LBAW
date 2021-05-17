@push('scripts')
  <script src="{{ asset('js/tooltip.js') }}" defer></script>
  <script src="{{ asset('js/projectFilter.js') }}" defer></script>
@endpush

<div class="modal fade" id="projectFilterModal" tabindex="-1" aria-labelledby="projectsFilterModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="projectsFilterModalLabel">
          <ol class="my-0 breadcrumb text-muted">
            <li class="breadcrumb-item">
              <a style="cursor: pointer; font-weight: bolder" data-bs-dismiss="modal">Filter Projects</a>
            </li>
          </ol>
        </nav>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div>
        <form data-id="projectFilter" id="projectFilter" data-href="/api/project">
          <label for="completion-selection">Completion</label>
          <select class="form-control tag-selection" name="completion" id="completion-selection">
            <option value="100">Completed</option>
            <option value="0">In progress</option>
          </select>
          <label for="dueDateInput">Due Date</label>
          <input class="form-control @error('due_date') is-invalid @enderror" id="dueDateProj" type="date"
                 name="due_date" value="{{ old('due_date') }}">
          <button type="submit" class="d-none"></button>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-success" data-bs-dismiss="modal" id="projectFilterSubmit">Filter</button>
      </div>
    </div>
  </div>
</div>

