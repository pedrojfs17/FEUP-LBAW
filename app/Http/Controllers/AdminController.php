<?php

namespace App\Http\Controllers;

use App\Models\Client;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function users(Request $request)
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    $users = Client::get();
    return view('pages.adminDashboard', ['users' => $users]);
  }

  public function statistics(Request $request)
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));

    $users = Client::get();
    $total_users = count($users);
    $women = (count($users->where('client_gender', 'Female')) / $total_users) * 100;
    $men = (count($users->where('client_gender', 'Male')) / $total_users) * 100;

    $countries = [];
    foreach ($users as $user) {
      array_push($countries, $user->country()->first()->name);
    }

    $countries = array_count_values($countries);
    arsort($countries);
    $countries = array_slice($countries, 0, 5);
    foreach ($countries as $country => $n) {
      $countries[$country] = (int)($n / $total_users * 100);
    }

    $projects = Project::get();
    $total_projects = count($projects);
    $completed_projects = 0;
    $proj_progress = [];
    foreach ($projects as $project) {
      if ($project->getCompletionAttribute() == 100)
        $completed_projects++;
      array_push($proj_progress, $project->getCompletionAttribute());
    }
    $avg_progress = (int)(array_sum($proj_progress) / count($proj_progress));

    $proj_per_user = [];
    foreach ($users as $user)
      array_push($proj_per_user, count($user->projects()->get()));
    $avg_projects = (int)(array_sum($proj_per_user) / count($proj_per_user));

    return view('pages.adminStatistics', [
        'total_users' => $total_users,
        'women' => $women,
        'men' => $men,
        'countries' => $countries,
        'total_projects' => $total_projects,
        'completed_projects' => $completed_projects,
        'avg_progress' => $avg_progress,
        'avg_projects' => $avg_projects]
    );
  }

  public function support(Request $request)
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    return view('pages.adminSupport');
  }
}
