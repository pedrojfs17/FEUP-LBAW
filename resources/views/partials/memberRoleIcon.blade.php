@switch($member->pivot->member_role)
  @case('Reader')
  <i class="bi bi-eye" data-bs-toggle="tooltip" data-bs-placement="right" title="Reader" style="z-index: 2; position: relative;"></i>
  @break

  @case('Editor')
  <i class="bi bi-pencil" data-bs-toggle="tooltip" data-bs-placement="right" title="Editor" style="z-index: 2;"></i>
  @break

  @case('Owner')
  <i class="bi bi-shield-lock" data-bs-toggle="tooltip" data-bs-placement="right" title="Owner" style="z-index: 2;"></i>
  @break
@endswitch
