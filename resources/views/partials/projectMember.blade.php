<div class="card my-1">
  <div class="card-body">
    <div class='d-flex flex-column flex-sm-row align-items-start justify-content-start'>
      <div class='d-flex flex-row align-items-center justify-content-start text-nowrap flex-grow-1'>
        <img class="rounded-circle d-inline-block me-3" src="{{ url($member->avatar) }}" width="50px" height="50px"
            alt="avatar">
          <div class='col flex-grow-0'>
            <h5 class="card-title mb-0">{{ $member->fullname }}</h5>
            <div class="text-muted m-0">
              {{ $member->account->username }}
              <div class="d-sm-none d-inline-block text-muted ms-1" id="role-{{ $member->account->username }}" style="z-index: 2;position: relative;">
                @include('partials.memberRoleIcon')
              </div>
            </div>
          </div>
        <h6 class="d-none d-sm-inline-block text-muted ms-3 flex-grow-1" id="role-{{ $member->account->username }}" style="z-index: 2;position: relative;">
          @include('partials.memberRoleIcon')
        </h6>
      </div>
      <a class='text-decoration-none stretched-link' target="_blank" rel="noopener noreferrer" href="/profile/{{$member->account->username}}"></a>
      <div class="d-flex flex-grow-1 w-100 justify-content-end">
        @if ($member->account->id != Auth::user()->id && $role == 'Owner' && $project->teamMembers()->where('client_id', $member->account->id)->exists())
          <button class="btn btn-danger btn-danger-red align-self-center remove-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" type="button" style="z-index: 1;position: relative;">Remove</button>
          <div class="align-self-center mx-2">
            <button type="button" class="btn btn-outline-secondary" data-bs-toggle="dropdown" aria-expanded="false" style="z-index: 1;position: relative;">
              <i class="bi bi-gear"></i>
            </button>
            <ul class="dropdown-menu" style="z-index: 4">
              <li><h6 class="dropdown-header">Change Role</h6></li>
              <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Reader</a></li>
              <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Editor</a></li>
              <li><a class="dropdown-item edit-role-button" data-href="/api/project/{{ $member->pivot->project_id }}/{{ $member->account->username }}" data-on-edit="updateUserRole">Owner</a></li>
            </ul>
          </div>
        @elseif ($member->account->id != Auth::user()->id && $role == 'Owner' && !$project->teamMembers()->where('client_id', $member->account->id)->exists())
          <button class="btn btn-danger btn-danger-red remove-invite-btn align-self-center" data-decision=0 data-href="/api/project/{{ $project->id }}/invite/{{$member->account->id}}" type="button" style="z-index: 1;position: relative;">Remove Invite</button>
        @endif
      </div>
    </div>
  </div>
</div>
