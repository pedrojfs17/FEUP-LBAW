<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use Illuminate\Http\Request;

class AdminController extends Controller
{
  public function users(Request $request)
  {
    if (!Auth::check()) return redirect('login');
    return view('pages.usersAdmin');
  }

  public function statistics(Request $request)
  {
    if (!Auth::check()) return redirect('login');
    return view('pages.statisticsAdmin');
  }

  public function support(Request $request)
  {
    if (!Auth::check()) return redirect('login');
    return view('pages.supportAdmin');
  }
}
