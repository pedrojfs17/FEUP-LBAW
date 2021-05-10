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

  public function list()
  {
    $tags = Client::find(Auth::user()->id)->projects()->tags()->orderBy('id')->get();
    return response()->json($tags);
  }

  public function create(Request $request, $id)
  {
    $request->validate([
      'name' => 'required|string',
      'color' => 'required|string'
    ]);

    $project = Project::find($id);
    $this->authorize('createTag', $project);

    $tag = new Tag();
    $tag->project = $id;
    $tag->name = $request->input('name');
    $tag->color = $request->input('color');
    $tag->save();

    return response()->json($tag);
  }

  public function delete(Request $request, $id, $tag)
  {
    $tagObj = Tag::find($tag);
    $project = Project::find($id);
    $this->authorize('deleteTag', $project);
    $tagObj->delete();
    return response()->json($tagObj);
  }
}
