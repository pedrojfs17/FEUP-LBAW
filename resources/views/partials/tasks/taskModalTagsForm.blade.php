<div id="task{{$task->id}}UpdateTag" class="collapse mb-3 multi-collapse-{{$task->id}}"
     aria-expanded="false">
  <form data-id="task{{$task->id}}Tags"
        data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/tag">
    @csrf
    <label for="tag-selection-{{$task->id}}"></label>
    <select class="form-control tag-selection" multiple="multiple" name="tag"
            id="tag-selection-{{$task->id}}">
      @foreach ($task->project()->first()->tags as $tag)
        @if($task->tags()->where('id',$tag->id)->count()!==0)
          <option value="{{$tag->id}}" selected="selected">{{$tag->name}}</option>
        @else
          <option value="{{$tag->id}}">{{$tag->name}}</option>
        @endif
      @endforeach
    </select>
    <button type="submit" class="d-none"></button>
  </form>
</div>
