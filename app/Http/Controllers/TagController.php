<?php

namespace App\Http\Controllers;

use App\Models\Tag;
use Illuminate\Http\Request;

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
    $validated = $request->validate([
      'name' => 'required|string',
      'color' => 'required|string'
    ]);

    $tag = new Tag();
    $tag->project =$id;
    $this->authorize('create', $tag);
    $tag->name = $validated->input('name');
    $tag->color = $validated->input('color');
    $tag->save();

    return response()->json($tag);
  }

  public function delete(Request $request, $id)
  {
    $tag = Tag::find($id);
    $this->authorize('delete', $tag);
    $tag->delete();
    return response()->json($tag);
  }
}
