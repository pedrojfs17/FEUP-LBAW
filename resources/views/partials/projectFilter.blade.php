@push('scripts')
  <script src="{{ asset('js/projectFilter.js') }}" defer></script>
@endpush

<div class="modal fade" id="projectFilterModal" tabindex="-1" aria-labelledby="projectsFilterModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Project Filters</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form data-id="projectFilter" id="projectFilter" data-href="/api/project">
          <h6 class="text-muted">Progress</h6>

          <label for="higherCompletionSelection">Higher than</label>
          <select class="form-select" name="higher_completion" id="higherCompletionSelection">
            <option value="" selected>Select a percentage</option>
            <option value="0">0%</option>
            <option value="25">25%</option>
            <option value="50">50%</option>
            <option value="75">75%</option>
            <option value="100">100%</option>
          </select>

          <label for="lowerCompletionSelection">Lower than</label>
          <select class="form-select" name="lower_completion" id="lowerCompletionSelection">
            <option value="" selected>Select a percentage</option>
            <option value="0">0%</option>
            <option value="25">25%</option>
            <option value="50">50%</option>
            <option value="75">75%</option>
            <option value="100">100%</option>
          </select>

          <hr>

          <h6 class="text-muted">Due Date</h6>

          <label for="filterProjBeforeDate">Before</label>
          <input class="form-control" id="filterProjBeforeDate" type="date" name="before_date">

          <label for="filterProjAfterDate">After</label>
          <input class="form-control" id="filterProjAfterDate" type="date" name="after_date">

          <hr>

          <label for="closedSelection">Closed</label>
          <select class="form-select" name="closed" id="closedSelection">
            <option value="" selected>Any</option>
            <option value="1">Closed</option>
            <option value="0">Open</option>
          </select>

          <button type="submit" class="d-none"></button>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-success" data-bs-dismiss="modal" id="projectFilterSubmit">Filter</button>
      </div>
    </div>
  </div>
</div>

