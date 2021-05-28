<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\Tag;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TagController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function create(Request $request, Project $project)
  {
    $request->validate([
      'name' => 'required|string',
      'color' => 'required|string'
    ]);

    $this->authorize('createTag', $project);

    $tag = new Tag();
    $tag->project = $project->id;
    $tag->name = $request->input('name');
    $tag->color = $request->input('color');
    $tag->save();

    $result = array(
      'delete_tag' => view('partials.deleteTag', ['tag' => $tag])->render(),
      'tag' => view('partials.tag', ['tag' => $tag])->render(),
      'message' => view('partials.messages.successMessage', ['message' => 'Tag created!'])->render()
    );

    return response()->json($result);
  }

  public function delete(Project $project, Tag $tag)
  {
    $this->authorize('deleteTag', $project);
    $tag->delete();
    return response()->json($tag);
  }
}
