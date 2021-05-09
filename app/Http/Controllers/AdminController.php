<?php

namespace App\Http\Controllers;

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
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    $users = Client::get();
    return view('pages.adminDashboard', ['users' => $users]);
  }

  public function statistics(Request $request)
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    return view('pages.adminStatistics');
  }

  public function support(Request $request)
  {
    if (!Auth::user()->is_admin) return redirect(route('dashboard'));
    return view('pages.adminSupport');
  }
}
