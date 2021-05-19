@push('scripts')
  <script src="{{ asset('js/tags.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/invite.js') }}" defer></script>
@endpush
<div class="row justify-content-center mt-5">
  <div class="col-lg-3 col-md-6 col-sm-6 d-flex align-items-center justify-content-center mx-3">
    <img src="{{ url($client->avatar) }}" alt="Avatar" class="img-fluid mx-auto d-block rounded-circle">
  </div>

  <div class="col-lg-4 align-items-center justify-content-center mx-3 my-auto">
    <form>
      @csrf
      <div class="d-flex justify-content-between">
        <label for="usernameInput" class="form-label">Username</label>
        <p class="text-muted">
            <small id="editProfile">Edit profile</small>
            <span id="editActions">
              <small id="cancelEdit">Cancel</small>
              <small> | </small>
              <small id="saveEdit" data-href="/profile/{{$client->account->username}}">Save</small>
            </span>
        </p>
      </div>
      <div class="input-group mb-3">
        <input type="text" placeholder="{{$client->account->username}}" class="form-control" id="usernameInput" name='username'
               disabled>
      </div>

      <label for="nameInput" class="form-label">Full Name</label>
      <div class="input-group mb-3">
        <input type="text" placeholder="{{$client->fullname }}" class="form-control" id="nameInput" name='fullname' disabled>
      </div>

      <label for="emailInput" class="form-label">Email</label>
      <div class="input-group mb-3">
        <input type="email" placeholder="{{$client->account->email }}" class="form-control" id="emailInput" name='email'
               disabled>
      </div>

      <label for="companyInput" class="form-label">Company</label>
      <div class="input-group mb-3">
        <input type="text" placeholder="{{$client->company}}" class="form-control" id="companyInput" name='company' disabled>
      </div>
    </form>
  </div>
  <div class="col-lg-6 align-items-center justify-content-center mx-6 my-auto">
    <h2>Invites</h2>
    @foreach($client->invites as $invite)
      @include('partials.inviteSummary',['invite'=>$invite])
    @endforeach
  </div>
</div>

