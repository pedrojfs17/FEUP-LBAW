<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use App\Models\Country;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function users()
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    $users = Client::all();
    $admins = Account::where('is_admin', true)->get();
    return view('pages.adminUsers', ['users' => $users, 'countries' => Country::all(), 'admins' => $admins]);
  }

  public function statistics()
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));

    $users = Client::get();
    $total_users = count($users);
    $women = intdiv(count($users->where('client_gender', 'Female'))*100, $total_users);
    $men = intdiv(count($users->where('client_gender', 'Male'))*100, $total_users);

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

    $admins = Account::where('is_admin', true)->get();
    return view('pages.adminStatistics', [
        'total_users' => $total_users,
        'women' => $women,
        'men' => $men,
        'countries' => $countries,
        'total_projects' => $total_projects,
        'completed_projects' => $completed_projects,
        'avg_progress' => $avg_progress,
        'avg_projects' => $avg_projects,
        'admins' => $admins]
    );
  }

  public function support()
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    return view('pages.adminSupport');
  }

  public function create(Request $request) {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));

    $request->validate([
      'username' => 'required|string|max:255|unique:account',
      'email' => 'required|string|email|max:255|unique:account',
      'password' => 'required|string|min:6|confirmed',
    ]);

    Account::create([
      'username' => $request->input('username'),
      'email' => $request->input('email'),
      'password' => Hash::make($request->input('password')),
      'is_admin' => true
    ]);

    return redirect(route('admin.users'))->with([
      'message' => 'Created Administrator account with username: ' . $request->input('username'),
      'message-type' => 'Success'
    ]);
  }

  public function delete(Account $account) {
    $this->authorize('delete', $account);

    if (count(Account::where('is_admin', true)->get()) == 1)
      return back()->with([
        'message' => 'This is the only Administrator account. Create another one before deleting this one!',
        'message-type' => 'Fail'
      ]);

    $account->delete();

    return redirect(route('/'))->with([
      'message' => 'Deleted Account',
      'message-type' => 'Success'
    ]);
  }
}
