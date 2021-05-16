<div class="card my-1">
  <div class="card-body">
    <img class="rounded-circle d-inline-block mx-2" src="{{ url($member->avatar) }}" width="40px" height="40px"
         alt="avatar">
    <h5 class="card-title d-inline-block">{{ $member->account->username }}</h5>
    <h6 class="d-inline-block text-muted" id="role-{{ $member->account->username }}">
      @include('partials.memberRoleIcon')
    </h6>
    @if ($member->account->id != Auth::user()->id && $role == 'Owner')
      <button class="btn btn-danger float-end remove-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" type="button">Remove</button>
      <div class="float-end mx-2">
        <button type="button" class="btn btn-outline-secondary" data-bs-toggle="dropdown" aria-expanded="false">
          <i class="bi bi-gear"></i>
        </button>
        <ul class="dropdown-menu">
          <li><h6 class="dropdown-header">Change Role</h6></li>
          <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Reader</a></li>
          <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Editor</a></li>
          <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Owner</a></li>
        </ul>
      </div>
    @endunless
  </div>
</div>
