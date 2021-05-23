<div class="delete-tag delete-button my-1" data-href="/api/project/{{ $tag->project }}/tag/{{ $tag->id }}">
  @include('partials.tag', ['tag' => $tag])
</div>
