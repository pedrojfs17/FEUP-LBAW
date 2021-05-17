@switch($member->pivot->member_role)
  @case('Reader')
  <i class="bi bi-eye"></i>
  @break

  @case('Editor')
  <i class="bi bi-pencil"></i>
  @break

  @case('Owner')
  <i class="bi bi-shield-lock"></i>
  @break
@endswitch
