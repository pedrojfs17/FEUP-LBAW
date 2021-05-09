<div class="card my-1">
  <div class="card-body">
    <img class="rounded-circle d-inline-block mx-2" src="{{ url($member->avatar) }}" width="40px" height="40px"
         alt="avatar">
    <h5 class="card-title d-inline-block">{{ $member->account->username }}</h5>
    <h6 class="d-inline-block text-muted">{{ $member->account->email }}</h6>
    @if (Auth::user()->is_admin)
      <button class="btn btn-danger float-end remove-button" data-href="/profile/{{ $member->account->username }}" type="button">Remove</button>
    @endunless
  </div>
</div>
