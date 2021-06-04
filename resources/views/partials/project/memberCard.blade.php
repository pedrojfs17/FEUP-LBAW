<div class="card my-1">
  <div class="card-body d-flex flex-row">
    <img class="rounded-circle me-3" src="{{ url($member->avatar) }}" width="50px" height="50px"
         alt="avatar">
    <div class="flex-grow-1">
      <h5 class="card-title">{{ $member->fullname }}</h5>
      <h6 class="text-muted">{{ $member->account->username }}</h6>
    </div>
    @if (Auth::user()->is_admin)
      <button class="btn btn-danger btn-danger-red float-end remove-button" data-href="/profile/{{ $member->account->username }}" type="button" style="z-index: 1; position:relative; height: min-content">
        <span class="d-none d-sm-block">Remove</span>
        <i class="bi bi-person-x d-block d-sm-none"></i>
      </button>
    @else
    <a class='text-decoration-none stretched-link' target="_blank" rel="noopener noreferrer" href="/profile/{{$member->account->username}}"></a>
    @endif
  </div>
</div>
