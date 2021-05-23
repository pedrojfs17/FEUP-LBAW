@if (count($projects) > 0)
  @each('partials.projectSummary', $projects, 'project')
  @if ($pagination)
    {{ $projects->links() }}
  @endif
@else
  <h6 class="text-muted">No projects found!</h6>
@endif
