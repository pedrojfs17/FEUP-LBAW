<div class="delete-tag delete-button my-1" data-href="/api/project/{{ $tag->project }}/tag/{{ $tag->id }}">
  <p class="d-inline-block m-0 py-1 px-3 rounded text-bg-check" type="button" style="background-color: {{ $tag->color }}">
    <small>{{ $tag->name }}</small>
  </p>
</div>
