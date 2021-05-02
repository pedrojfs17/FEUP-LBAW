<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use App\Models\Client;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function show()
  {
    if (Admin::find(Auth::user()->id))
      return redirect('admin/users');

    return view('pages.dashboard', ['user' => Client::find(Auth::user()->id)]);
  }
}
