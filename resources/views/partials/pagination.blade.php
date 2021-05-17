@if ($paginator->hasPages())
  <div class="d-flex justify-content-end">
  <ul class="pagination my-3">
    {{-- Previous Page Link --}}
    <li><button class="paginator-link btn" data-href="{{ $paginator->previousPageUrl() }}" rel="prev" @if($paginator->onFirstPage()) disabled @endif>&lt;</button></li>

    {{-- Pagination Elements --}}
    @foreach ($elements as $element)
      {{-- "Three Dots" Separator --}}
      @if (is_string($element))
        <li class="disabled mx-1"><span>{{ $element }}</span></li>
      @endif

      {{-- Array Of Links --}}
      @if (is_array($element))
        @foreach ($element as $page => $url)
          <li>
            <button class="paginator-link btn btn-light" data-href="{{ $url }}" rel="prev" @if($page == $paginator->currentPage()) disabled @endif>
              {{ $page }}
            </button>
          </li>
        @endforeach
      @endif
    @endforeach

    {{-- Next Page Link --}}
    <li><button class="paginator-link btn" data-href="{{ $paginator->nextPageUrl() }}" rel="prev" @if(!$paginator->hasMorePages()) disabled @endif>&gt;</button></li>
  </ul>
  </div>
@endif

