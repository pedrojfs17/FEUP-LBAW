@foreach ($tags as $tag)
  <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded text-bg-check" type="button"
     style="background-color: {{ $tag->color }}">
    <small class='d-none d-sm-inline-block'>{{ $tag->name }}</small>
  </p>
@endforeach
