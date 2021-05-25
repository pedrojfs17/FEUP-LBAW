@if (count($users) > 0)
  @each('partials.memberCard', $users, 'member')
@else
  <h6 class="text-muted">No users found!</h6>
@endif
