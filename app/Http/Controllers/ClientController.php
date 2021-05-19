<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use App\Rules\MatchOldPassword;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ClientController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  /**
   * Display the specified resource.
   *
   * @param string $username
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|\Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $username)
  {
    $account = Account::where('username', '=', $username)->first();
    if ($account == null) return view('errors.404');
    $client = Client::find($account->id);
    return view('pages.profile', ['client' => $client, 'user' => Client::find(Auth::user()->id)]);
  }

  public function list(Request $request)
  {
    $searchQuery = $request->input('query');

    if (!empty($searchQuery)) {
      $clients = Client::when(!empty($searchQuery), function ($query) use ($searchQuery) {
        return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
      })->paginate(5);
    } else {
      $clients = Client::orderBy('id', 'desc')->paginate(5);
    }

    $view = view('partials.createProjectMembers', ['clients' => $clients, 'pagination' => true])->render();

    return response()->json($view);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param string $username
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $username)
  {
    $validated = $request->validate([
      'email' => 'unique:account|email'
    ]);
    $client = Client::find($username);
    $this->authorize('update', $client);

    $client->account()->email = empty($validated->input('email')) ? $client->account()->email : $validated->input('email');
    $client->account()->password = empty($validated->input('password')) ? $client->account()->password : $validated->input('password');
    $client->fullname = empty($validated->input('fullname')) ? $client->fullname : $validated->input('fullname');
    $client->company = empty($validated->input('company')) ? $client->company : $validated->input('company');
    $client->avatar = empty($validated->input('avatar')) ? $client->avatar : $validated->input('avatar');
    $client->gender = empty($validated->input('gender')) ? $client->gender : $validated->input('gender');
    $client->country = empty($validated->input('country')) ? $client->country : $validated->input('country');
    $client->save();

    $response = array('message' => view('partials.successMessage', ['message' => 'Updated account!'])->render());

    return response()->json($response);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param string $username
   * @return
   */
  public function delete(Request $request, $username)
  {
    $account = Account::where('username', '=', $username)->first();
    $client = Client::find($account->id);
    $this->authorize('delete', [$client, Auth::user()->is_admin]);
    $client->delete();

    if (Auth::user()->is_admin)
      return response()->json($client);

    return redirect(route('/'));
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return
   */
  public function showSettings(Request $request)
  {
    $client = Client::find(Auth::user()->id);
    $this->authorize('showSettings', $client);
    return view('pages.settings', ['user' => $client]);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function updateSettings(Request $request)
  {
    $request->validate([
      'allow_noti' => 'boolean',
      'invite_noti' => 'boolean',
      'member_noti' => 'boolean',
      'assign_noti' => 'boolean',
      'waiting_noti' => 'boolean',
      'comment_noti' => 'boolean',
      'report_noti' => 'boolean',
      'hide_completed' => 'boolean',
      'simplified_tasks' => 'boolean',
      'color' => 'string',
    ]);

    $client = Client::find(Auth::id());
    $this->authorize('updateSettings', $client);

    $message = "";

    if ($request->input('allow_noti') != null) {
      $client->allow_noti = filter_var($request->input('allow_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Notifications are now " . ($client->allow_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('invite_noti') != null) {
      $client->invite_noti = filter_var($request->input('invite_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Invite notifications are now " . ($client->invite_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('member_noti') != null) {
      $client->member_noti = filter_var($request->input('member_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "New member notifications are now " . ($client->member_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('assign_noti') != null) {
      $client->assign_noti = filter_var($request->input('assign_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Assignment notifications are now " . ($client->assign_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('waiting_noti') != null) {
      $client->waiting_noti = filter_var($request->input('waiting_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Tasks waiting notifications are now " . ($client->waiting_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('comment_noti') != null) {
      $client->comment_noti = filter_var($request->input('comment_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Comment notifications are now " . ($client->comment_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('report_noti') != null) {
      $client->report_noti = filter_var($request->input('report_noti'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Report notifications are now " . ($client->report_noti ? "enabled" : "disabled") . "! ";
    }
    if ($request->input('hide_completed') != null) {
      $client->hide_completed = filter_var($request->input('hide_completed'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Completed tasks are now " . ($client->hide_completed ? "hidden" : "visible") . "! ";
    }
    if ($request->input('simplified_tasks') != null) {
      $client->simplified_tasks = filter_var($request->input('simplified_tasks'), FILTER_VALIDATE_BOOLEAN);
      $message = $message . "Showing " . ($client->simplified_tasks ? "simplified" : "complete") . " tasks! ";
    }
    if ($request->input('color') != null) {
      $client->color = $request->input('color');
      $message = $message . "Updated color! ";
    }

    $client->save();

    $response = array('message' => view('partials.successMessage', ['message' => $message])->render());

    return response()->json($response);
  }

  public function updatePassword(Request $request)
  {
    $request->validate([
      'password' => ['required', new MatchOldPassword],
      'new_password' => 'required|string|min:6|confirmed'
    ]);

    $client = Auth::user();
    $client->password = Hash::make($request->new_password);
    $client->save();

    $response = array('message' => view('partials.successMessage', ['message' => "Updated Password!"])->render());

    return response()->json($response);
  }
}
