<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AdminController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function users(Request $request)
  {
    $this->authorize('users');
    return view('pages.usersAdmin');
  }

  public function statistics(Request $request)
  {
    $this->authorize('statistics');
    return view('pages.statisticsAdmin');
  }

  public function support(Request $request)
  {
    $this->authorize('support');
    return view('pages.supportAdmin');
  }
}
