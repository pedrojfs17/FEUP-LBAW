@each('partials.memberSummary', $clients, 'client')
@if ($pagination)
  {{ $clients->links() }}
@endif
