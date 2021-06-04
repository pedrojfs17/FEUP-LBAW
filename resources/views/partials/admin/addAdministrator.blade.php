<div class="offcanvas offcanvas-end" tabindex="-1" id="addAdministrator" aria-labelledby="addAdministratorLabel">
  <div class="offcanvas-header">
    <h5 id="addAdministratorLabel">Administrators</h5>
    <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body">
    <section id="add-administrator">
      <h5>Add Administrator</h5>
      <form class="d-flex flex-column mt-3" action="{{ route('admin.add') }}" method="POST">
        @csrf

        @if ($errors->first())
          <div class="alert alert-danger mb-3" role="alert">
            {{ $errors->first() }}
          </div>
        @endif

        <div class="mb-3">
          <label for="inputEmail" class="form-label">Email <span class="text-muted">*</span></label>
          <input type="email" class="form-control" id="inputEmail" value="{{ old('email') }}" name="email" required autofocus>
        </div>
        <div class="mb-3">
          <label for="inputUsername" class="form-label">Username <span class="text-muted">*</span></label>
          <input type="text" class="form-control" id="inputUsername" value="{{ old('username') }}" name="username" required>
        </div>
        <div class="mb-3">
          <label for="inputPassword" class="form-label">Password <span class="text-muted">*</span></label>
          <input type="password" class="form-control" id="inputPassword" name="password" required>
        </div>
        <div class="mb-3">
          <label for="inputPasswordConfirmation" class="form-label">Password Confirmation <span class="text-muted">*</span></label>
          <input type="password" class="form-control" id="inputPasswordConfirmation" name="password_confirmation" required>
        </div>
        <button type="submit" class="btn btn-outline-secondary">Add</button>
      </form>
    </section>
    <hr class="my-4">
    <section id="project-tags">
      <h5>Current Administrators</h5>
      @foreach($admins as $admin)
        <h6 class="text-muted">{{ $admin->username }} ({{ $admin->email }})</h6>
      @endforeach
    </section>
  </div>
</div>
