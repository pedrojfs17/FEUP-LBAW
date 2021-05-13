@each('partials.projectSummary', $projects, 'project')
@if ($pagination)
  {{ $projects->links() }}
@endif
