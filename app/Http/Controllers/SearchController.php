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

    $projects = array();
    $tasks = array();
    $users = array();

    if ($searchQuery !== null) {
      $projects = $client->projects()->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery])
          ->limit(5)->get();

      $tasks = $client->tasks()->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery])
          ->limit(5)->get();

      $users = Client::whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery])
          ->limit(5)->get();
    }

    $result['projects'] = view('partials.dashboardProjects', ['projects' => $projects, 'pagination'=>false])->render();
    $result['tasks'] = view('partials.queriedTasks', ['tasks' => $tasks])->render();
    $result['users'] = view('partials.queriedUsers', ['users' => $users, 'pagination' => false])->render();

    return response()->json($result);
  }
}
