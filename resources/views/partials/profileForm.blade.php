@push('scripts')
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/invite.js') }}" defer></script>
@endpush
<div class="row justify-content-center mt-5">
  <div class="col-lg-3 col-md-6 col-sm-6 d-flex flex-column align-items-center justify-content-center mx-3">
    <img src="{{ url($client->avatar) }}" width=100% alt="Avatar" class="img-fluid mx-auto d-block rounded-circle" id='userAvatar'>
    <div class='my-3 d-flex flex-column align-items-center justify-content-center'>
      <button type="button" class="btn btn-secondary btn-sm" id='editAvatar'>Edit image</button>
      
      <form class='d-none' id='editAvatarInput'>
        @csrf
        <div class='input-group input-group-sm'>
          <input class="form-control" type="file" accept="image/png, image/gif, image/jpeg" id='fileAvatar'>
          <button class="btn btn-outline-secondary" type="button" id='cancelAvatar'><i class="bi bi-x"></i></button>
          <button class="btn btn-outline-secondary" type="button" id='saveAvatar'><i class="bi bi-check"></i></button>
        </div>
      </form>
    </div>
  </div>

  <div class="col-lg-4 align-items-center justify-content-center mx-3 my-auto">
    <form id='editProfileForm'>
      @csrf
      <div class="d-flex justify-content-between">
        <label for="nameInput" class="form-label">Full Name</label>
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
        <input type="text" placeholder="{{$client->fullname }}" value="{{$client->fullname }}" class="form-control" id="nameInput" name='fullname' disabled>
      </div>
      
      <label for="genderInput" class="form-label">Gender</label>
      <div class="input-group mb-3">
        <select id='genderInput' class="form-select" name='client_gender' data-placeholder="{{$client->client_gender}}" disabled>
          <option value='Male' @if ($client->client_gender == 'Male') selected @endif>Male</option>
          <option value='Female' @if ($client->client_gender == 'Female') selected @endif>Female</option>
          <option value='Unspecified' @if ($client->client_gender == 'Unspecified') selected @endif>Unspecified</option>
        </select>
      </div>

      <label for="emailInput" class="form-label">Email</label>
      <div class="input-group mb-3">
        <input type="email" placeholder="{{$client->account->email }}" value="{{$client->account->email }}" class="form-control" id="emailInput" name='email'
               disabled>
      </div>

      <label for="companyInput" class="form-label">Company</label>
      <div class="input-group mb-3">
        <input type="text" placeholder="{{$client->company}}" value="{{$client->company}}" class="form-control" id="companyInput" name='company' disabled>
      </div>
      
      <label for="countryInput" class="form-label">Country</label>
      <div class="input-group mb-3">
        <select id='countryInput' class="form-select" name='country' data-placeholder="{{$client->country}}" disabled>
          @foreach($countries as $country)
            <option value='{{$country->id}}' @if ($client->country == $country->id) selected @endif>{{$country->name}}</option>
          @endforeach
        </select>
      </div>
    </form>
  </div>
  <div class="col-lg-9 align-items-center justify-content-center my-4 mx-6">
    <h2 class='px-2'>Invites</h2>
    <hr class="mt-0">
    @if (count($client->invites) > 0)
    @foreach($client->invites as $invite)
      @include('partials.inviteSummary',['invite'=>$invite])
    @endforeach
    @else
    <p class='text-muted text-center'>You have not been invited to any project</p>
    @endif
  </div>
</div>

