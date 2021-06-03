<div class="modal fade" id="createProjectModal" tabindex="-1" aria-labelledby="createProjectModalLabel"
     style="display: none;" aria-hidden="true">
  <div class="modal-dialog modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title h4" id="createProjectModalLabel">New Project</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div class="container">
          <div class="row">
            <form id="msform" class="needs-validation" method="POST" action="/api/project">
              @csrf
              <div class="col-10 offset-1 mb-5">
                <div class="position-relative m-4" id="progressbar">
                  <div class="progress" style="height: 2px;">
                    <div id="ms-form-progress-bar" class="progress-bar" role="progressbar"
                         style="width: 0; background-color: #00AFB9;" aria-valuenow="25" aria-valuemin="0"
                         aria-valuemax="100"></div>
                  </div>
                  <div
                    class="progress-item position-absolute top-0 start-0 text-center translate-middle rounded-pill active"
                    style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-pencil fs-3"></i>
                  </div>
                  <div
                    class="progress-item position-absolute top-0 start-50 text-center translate-middle rounded-pill"
                    style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-gear fs-3"></i>
                  </div>
                  <div
                    class="progress-item position-absolute top-0 start-100 text-center translate-middle rounded-pill"
                    style="width: 3rem; height:3rem; background-color: white;"><i
                      class="bi bi-person-plus fs-3"></i></div>
                </div>
              </div>

              <hr>

              <fieldset>
                <div class="d-flex justify-content-between align-items-center my-3">
                  <legend class="fs-3" style="width: auto;">Basic Information</legend>
                  <h5 class="steps">Step 1 - 3</h5>
                </div>
                <div class="mb-3">
                  <label for="projectNameInput" class="form-label">Name <span class="text-muted">*</span></label>
                  <input type="text" class="form-control @error('name') is-invalid @enderror" id="projectNameInput"
                         placeholder="Add Project Title" name="name" value="{{ old('name') }}" required autofocus>
                  <div class="invalid-feedback">
                    Please choose a name.
                  </div>
                </div>
                <div class="mb-3">
                  <label for="projectDescriptionInput" class="form-label">Description <span class="text-muted">*</span></label>
                  <textarea class="form-control @error('description') is-invalid @enderror" id="projectDescriptionInput"
                            rows="3" placeholder="Describe your project" name="description"
                            required>{{ old('description') }}</textarea>
                  <div class="invalid-feedback">
                    Please provide a description.
                  </div>
                </div>
                <hr>
                <button type="button" class="next btn btn-lg btn-primary float-end">
                  Next
                </button>
                <button type="button" class="btn btn-lg btn-secondary float-end mx-3" data-bs-dismiss="modal">Cancel
                </button>
              </fieldset>

              <fieldset>
                <div class="d-flex justify-content-between align-items-center my-3">
                  <legend class="fs-3" style="width: auto;">Setup</legend>
                  <h5 class="steps">Step 2 - 3</h5>
                </div>
                <div class="mb-3">
                  <label for="dueDateInput" class="form-label">Due Date</label>
                  <input class="form-control" id="dueDateInput" type="date"
                         name="due_date" value="{{ old('due_date') }}">
                </div>
                <hr>
                <button type="button" class="next btn btn-lg btn-primary float-end">
                  Next
                </button>
                <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
              </fieldset>

              <fieldset>
                <div class="d-flex justify-content-between align-items-center my-3">
                  <legend class="fs-3" style="width: auto;">Add Members</legend>
                  <h5 class="steps">Step 3 - 3</h5>
                </div>
                <div class="input-group mb-3">
                  <input id="searchMembers" name="query" type="text" class="form-control"
                         placeholder="Username or Email"
                         aria-label="Find Members" aria-describedby="button-search">

                  <button class="btn btn-outline-secondary" type="button" id="button-search-members"><i
                      class="bi bi-search"></i></button>
                </div>
                <div class="d-flex justify-content-center my-3 d-none" id="membersSpinner">
                  <div class="spinner-border" role="status">
                    <span class="visually-hidden">Loading...</span>
                  </div>
                </div>
                <select id="selected-members" name="members[]" hidden multiple="multiple"></select>
                <div id="members" class="">
                </div>
                <div class="d-block">
                  <h6>Added Members</h6>
                  <div id="added-members">
                    <p class='text-muted'>No members added!</p>
                  </div>
                </div>
                <hr>
                <button type="submit" class="btn btn-lg btn-primary float-end">
                  Submit
                </button>
                <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
              </fieldset>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
