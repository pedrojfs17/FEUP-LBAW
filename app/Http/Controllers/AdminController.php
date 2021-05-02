<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use App\Models\Client;
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
    $admin = Admin::find(Auth::user()->id);
    $this->authorize('users', $admin);
    $users = Client::get();
    return view('pages.adminDashboard', ['users' => $users]);
  }

  public function statistics(Request $request)
  {
    $admin = Admin::find(Auth::user()->id);
    $this->authorize('statistics', $admin);
    return view('pages.adminStatistics');
  }

  public function support(Request $request)
  {
    $admin = Admin::find(Auth::user()->id);
    $this->authorize('support', $admin);
    return view('pages.adminSupport');
  }
}
