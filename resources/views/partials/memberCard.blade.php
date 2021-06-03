<div class="card my-1">
  <div class="card-body">
    <img class="rounded-circle d-inline-block mx-2" src="{{ url($member->avatar) }}" width="40px" height="40px"
         alt="avatar">
    <h5 class="card-title d-inline-block">{{ $member->fullname }}</h5>
    <h6 class="d-inline-block text-muted">{{ $member->account->username }}</h6>
    <a class='text-decoration-none stretched-link' target="_blank" rel="noopener noreferrer" href="/profile/{{$member->account->username}}"></a>
    @if (Auth::user()->is_admin)
      <button class="btn btn-danger btn-danger-red float-end remove-button" data-href="/profile/{{ $member->account->username }}" type="button" style="z-index: 1; position:relative;">Remove</button>
    @endunless
  </div>
</div>
