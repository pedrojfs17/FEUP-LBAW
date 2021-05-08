@each('partials.projectSummary', $projects, 'project')

{{ $projects->links() }}
