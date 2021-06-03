@if (!$project->closed)
<div class="d-grid mb-3 project-status">
    <p class="text-muted mb-2">You can always reopen it after.</p>
    <button class="btn btn-dark close-proj-btn" type="button" data-href="/api/project/{{ $project->id }}" data-value=1>Close Project</button>
</div>
@else
<div class="d-grid mb-3 project-status">
    <p class="text-muted mb-2">You can always close it after.</p>
    <button class="btn btn-success reopen-proj-btn" type="button" data-href="/api/project/{{ $project->id }}" data-value=0>Reopen Project</button>
</div>
@endif