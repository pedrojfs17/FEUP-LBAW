<?php

namespace App\Http\Controllers;

use App\Models\Tag;
use Illuminate\Http\Request;

class TagController extends Controller
{
  public function list()
  {
    if (!Auth::check()) return redirect('login');
    $this->authorize('list', Tag::class);
    return Response::json(Auth::user()->projects()->tags()->orderBy('id')->get());
  }

  public function create(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'name' => 'required|string',
      'color' => 'required|string'
    ]);

    $tag = new Tag();
    $this->authorize('create', $tag);
    $tag->name = $validated->input('name');
    $tag->color = $validated->input('color');
    $tag->project =$id;
    $tag->save();
    return $tag;

  }

  public function delete(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');
    $tag = Tag::find($id);
    $this->authorize('delete', $tag);
    $tag->delete();
    return $tag;
  }
}
