@each('partials.project.memberSummary', $clients, 'client')
@if ($pagination)
  {{ $clients->links() }}
@endif
