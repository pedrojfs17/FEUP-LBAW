<?php

namespace App\Http\Controllers;

use App\Models\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SearchController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function show()
  {
    return view('pages.search');
  }

  public function search(Request $request)
  {
    $client = Client::find(Auth::user()->id);
    $result = array();
    $searchQuery = $request->input('query');


    $projects = $client->projects()->when(!empty($searchQuery), function ($query) use ($searchQuery) {
      return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
        ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
    })->paginate(5);

    $tasks = $client->tasks()->when(!empty($searchQuery), function ($query) use ($searchQuery) {
      return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
        ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
    })->paginate(5);

    $users = Client::when(!empty($searchQuery), function ($query) use ($searchQuery) {
      return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
        ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
    })->paginate(5);


    $result['projects'] = view('partials.dashboardProjects', ['projects' => $projects,'pagination'=>false])->render();
    $result['tasks'] = view('partials.queriedTasks', ['tasks' => $tasks])->render();
    $result['users'] = view('partials.queriedUsers', ['users' => $users])->render();

    return response()->json($result);
  }
}
